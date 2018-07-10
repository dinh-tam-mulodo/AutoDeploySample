global with sharing class CLP_PaymentMethodBulkStopBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_PaymentMethodBulkStopBatch() {
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            //system.debug('CLP_PaymentMethodBulkStopBatch.startBatch.aajList= ' + aajList);                           
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_PaymentMethodBulkStopBatch processor = new CLP_PaymentMethodBulkStopBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{
        	'Id', 'LastModifiedById', 'IsIntegrated__c', 'RegisterStatus__c', 'IsStop__c', 'StopFlg__c', 'ManipulateStatus__c', 'ErrorMessage__c',
            'Name', 'PaymentMethodCode__c', 'PaymentMethod__c', 'AccountId__r.SeikyusakiCode__c', 'AccountId__r.Name', 'ExternalKey__c'     
        };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from PaymentMethod__c where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = \'\'{2}\'\' and IsIntegrated__c = true order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields), 
                                String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING),
                                String.escapeSingleQuotes(CLP_MikataConstant.FLG_STOP) });
        
        this.cntsql = String.format('Select count() from PaymentMethod__c where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = \'\'{1}\'\' and IsIntegrated__c = true'
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING),
                	            String.escapeSingleQuotes(CLP_MikataConstant.FLG_STOP) });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            List<PaymentMethod__c> payMetsList = (List<PaymentMethod__c>) scope;
            system.debug('CLP_PaymentMethodBulkStopBatch.execute.payMetsList before= ' + payMetsList);

            Map<String, CLP_BulkBillingWrapper.Billing> payMetSetFailed = new Map<String, CLP_BulkBillingWrapper.Billing>(); 

            //  call to api stop 
            CLP_BulkBillingWrapper result = CLP_MikataPaymentMethodApi.paymentMethodBulkStop(payMetsList);
            system.debug('CLP_PaymentMethodBulkStopBatch.execute.result= ' + result);

            if(result.success) {
                // loop list billing      
                for (CLP_BulkBillingWrapper.Billing aBilling : result.billing) {
                    if (String.isBlank(aBilling.error_message)) {
                        // loop list payment for each billing 
                        for (CLP_BulkBillingWrapper.Payment aPayment : aBilling.payment) {
                            // make sure that payment code must match with payment method code  
                            for (PaymentMethod__c pm : payMetsList) {
                                String externalKeyMikata = aBilling.code + '_' + aPayment.code; 
                                if (externalKeyMikata == pm.ExternalKey__c) {
                                    // case update to DEMAND_LINK_SUCCESS
                                    if (String.isBlank(aPayment.error_message)) {
                                        pm.ErrorMessage__c = null; 
                                        pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                                        pm.IsStop__c = true;
                                        // IsIntegrated__c still = true
                                        // StopFlg__c still = '0'
                                        //createLog(pm, aPayment, aPayment.error_message, CLP_Logger.L_SUCCESS);
                                    
                                    // case update to DEMAND_FAILED_DATA_DEFECT
                                    } else {
                                        pm.ErrorMessage__c = null; 
                                        pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;                                        
                                        // Create new log
                                        createLog(pm, aPayment, aPayment.error_message, CLP_Logger.L_OUTBOUND);
                                        // Reset flag
                                        pm.StopFlg__c = ''; 
                                    }
                                    break;       
                                } 
                            }
                        }
                    
                    } else {
                        payMetSetFailed.put(aBilling.code, aBilling);
                    }
                }

                for (PaymentMethod__c pm : payMetsList) {
                    if (pm.ManipulateStatus__c == CLP_MikataConstant.DEMAND_LINK_AWAITING) {
                        // case update to DEMAND_FAILED_DATA_DEFECT
                        if (payMetSetFailed.keySet().contains(pm.AccountId__r.SeikyusakiCode__c)) {
                            pm.ErrorMessage__c = null; 
                            pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT; 
                            // Create new log
                            CLP_BulkBillingWrapper.Billing errBilling = payMetSetFailed.get(pm.AccountId__r.SeikyusakiCode__c); 
                            createLog(pm, errBilling);  
                            // Reset flag
                            pm.StopFlg__c = ''; 
                        }    
                    }
                }
            
            // if(!result.success) 
            } else { 
                // case update to DEMAND_FAILED_INTERFACE  
                for(PaymentMethod__c pm : payMetsList) {
                    pm.ErrorMessage__c = null; 
                    pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                    // Create new log
                    createLog(pm, null, result.error_message, CLP_Logger.L_ACCESS);
                    // Reset flag
                    pm.StopFlg__c = '';
                }
            }

            // update payment method 
            updatePayMets(payMetsList);

        } catch(Exception ex) {
            this.raiseError = true;
            CLP_Logger.log(ex.getMessage(), Label.CLP_PaymentMethodBulkStopBatchLabel);
        }
        CLP_Logger.flush();
    }

    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_PaymentMethodBulkStopBatchLabel);
        //system.debug('CLP_PaymentMethodBulkStopBatch.finish.raiseError= ' + raiseError);
        if(this.raiseError){
            return;
        }

        // if exist record need to register to mikata ==> call batch again
        if(Database.countQuery(this.cntsql)>0){
            // run batch again
            if(!Test.isRunningTest() && !shouldStop) {
                startBatch(true);
            }
        }

        // if more than 2 job started at the same time ==> abort all job
        if(shouldStop){
            for(AsyncApexJob aaj : [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        }
    }  

    private void createLog(PaymentMethod__c pm, CLP_BulkBillingWrapper.Payment billPm, String errorMsg, String operation) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = pm.LastModifiedById;
        log.LK_PaymentMethod__c = pm.Id;
        log.Origin__c  = Label.CLP_PaymentMethodBulkStopBatchLabel;
        log.Request__c = CLP_MikataPaymentMethodApi.getApiRequest(pm, CLP_MikataApi.ApiType.F_STOP);
        log.Response__c = CLP_MikataPaymentMethodApi.getApiResponse(billPm);
        log.Content__c = errorMsg;                        
        log.Operation__c = operation;
        CLP_Logger.log(log);
    }

    private void createLog(PaymentMethod__c pm, CLP_BulkBillingWrapper.Billing billpm) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = pm.LastModifiedById;
        log.LK_PaymentMethod__c = pm.Id;
        log.Origin__c = Label.CLP_PaymentMethodBulkStopBatchLabel;
        log.Request__c = CLP_MikataPaymentMethodApi.getApiRequest(pm, CLP_MikataApi.ApiType.F_STOP);  
        log.Response__c = CLP_MikataPaymentMethodApi.getApiResponse(billpm, true);
        log.Content__c = billpm.error_message;                        
        log.Operation__c = CLP_Logger.L_OUTBOUND;
        CLP_Logger.log(log);
    }

    private void updatePayMets(List<PaymentMethod__c> payMetsList) {
        String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'IsStop__c', 'StopFlg__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
        && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){             
            Database.SaveResult[] saveResults = Database.update(payMetsList, false);
            for (Integer i=0; i<saveResults.size(); i++){
                if (!saveResults[i].isSuccess()) {
                    String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                    createLog(payMetsList[i], null, totalErrorMsg, CLP_Logger.L_OUTBOUND);
                }
            } 
        
        } else {
            this.raiseError = true;
            for (PaymentMethod__c pm : payMetsList) {
                createLog(pm, null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND);
            }
        }
    }

    private String getErrorValidationMessage(List<Database.Error> listErr) {
        String msg = '';
        Integer count = 0;
        for (Database.Error err : listErr) {
            count++;
            msg += err.getMessage() + (count == listErr.size() ? '' : '\n');
        } 
        return msg;
    }
}