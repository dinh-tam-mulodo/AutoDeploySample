global with sharing class CLP_PaymentMethodBulkDeleteBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_PaymentMethodBulkDeleteBatch() {
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_PaymentMethodBulkDeleteBatch processor = new CLP_PaymentMethodBulkDeleteBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{
            'Id', 'Name', 'LastModifiedById', 'ManipulateStatus__c', 'RecordCode__c', 'SObjectType__c',
            'AccountId__c', 'AccountId__r.SeikyusakiCode__c', 'AccountId__r.Name'
        };
        String fields = String.join(fieldsArray, ',');

        this.sql = String.format('Select {0} from MikataInteBuffer__c where ManipulateStatus__c = \'\'{1}\'\' and SObjectType__c = \'\'{2}\'\' order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields), 
                                String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING), 
                                String.escapeSingleQuotes(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD) }); 

        this.cntsql = String.format('Select count() from MikataInteBuffer__c where ManipulateStatus__c = \'\'{0}\'\' and SObjectType__c = \'\'{1}\'\' '
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING), 
                                String.escapeSingleQuotes(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD) });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            List<MikataInteBuffer__c> bufferPayMetsList = (List<MikataInteBuffer__c>) scope;
            if (bufferPayMetsList.isEmpty()) {
                return;
            }

            Set<String> bufferPayMetSetCodeToDelete = new Set<String>();
            Map<String, CLP_BulkBillingWrapper.Payment> bufferPayMetMapNotDelete = new Map<String, CLP_BulkBillingWrapper.Payment>();
            List<MikataInteBuffer__c> bufferPayMetListToDelete = new List<MikataInteBuffer__c>();
            List<MikataInteBuffer__c> bufferPayMetListNotDelete = new List<MikataInteBuffer__c>();

            //  call to api delete     
            CLP_BulkBillingWrapper result = CLP_MikataPaymentMethodApi.paymentMethodBulkDelete(bufferPayMetsList);
            system.debug('#########result= ' + result);

            if(result.success) {
                // loop list billing      
                for (CLP_BulkBillingWrapper.Billing aBilling : result.billing) {
                    if (String.isBlank(aBilling.error_message)) {
                        // loop list payment for each billing 
                        for (CLP_BulkBillingWrapper.Payment aPayment : aBilling.payment) {
                            // make sure that payment code must match with buffer record code  
                            for (MikataInteBuffer__c bufferPayMet : bufferPayMetsList) {
                                String accountCode = bufferPayMet.AccountId__r.SeikyusakiCode__c;
                                if (aPayment.code == bufferPayMet.RecordCode__c && aBilling.code == accountCode) {
                                    if (String.isBlank(aPayment.error_message)) {
                                        bufferPayMetSetCodeToDelete.add(bufferPayMet.RecordCode__c);
                                    } else {
                                        bufferPayMetMapNotDelete.put(bufferPayMet.RecordCode__c, aPayment);
                                    }
                                    break;
                                } 
                            }
                        }
                    }
                }

                for (MikataInteBuffer__c bufferPayMet : bufferPayMetsList) {
                    if (bufferPayMetSetCodeToDelete.contains(bufferPayMet.RecordCode__c)) {
                        //bufferPayMet.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS; 
                        bufferPayMetListToDelete.add(bufferPayMet);
                        //createLog(bufferPayMet, null, null, CLP_Logger.L_SUCCESS);     

                    } else if (bufferPayMetMapNotDelete.keySet().contains(bufferPayMet.RecordCode__c)) {
                        bufferPayMet.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT; 
                        bufferPayMetListNotDelete.add(bufferPayMet);
                        CLP_BulkBillingWrapper.Payment paymentResponse = bufferPayMetMapNotDelete.get(bufferPayMet.RecordCode__c);
                        // Create new log
                        createLog(bufferPayMet, paymentResponse, paymentResponse.error_message, CLP_Logger.L_OUTBOUND);     

                    } else {
                        bufferPayMet.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT; 
                        bufferPayMetListNotDelete.add(bufferPayMet);
                        // Create new log
                        createLog(bufferPayMet, null, 'エラー：請求管理ロボの連携にエラーが発生しました。', CLP_Logger.L_OUTBOUND);
                    }
                }
            
            // if(!result.success)
            } else {
                // case update to DEMAND_FAILED_INTERFACE  
                for(MikataInteBuffer__c bufferPayMet : bufferPayMetsList){
                    bufferPayMet.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                    bufferPayMetListNotDelete.add(bufferPayMet);
                    PaymentMethod__c tempPayMet = new PaymentMethod__c(PaymentMethodCode__c = bufferPayMet.RecordCode__c, StopFlg__c = CLP_MikataConstant.FLG_DELETE); 
                    // Create new log
                    createLog(bufferPayMet, null, result.error_message, CLP_Logger.L_ACCESS);
                }
            }

            system.debug('@@@@@@bufferPayMetListNotDelete= ' + bufferPayMetListNotDelete);
            system.debug('@@@@@@bufferPayMetListToDelete= ' + bufferPayMetListToDelete);

            // Create restore point 
            Savepoint sp = Database.setSavepoint();
            try {
                //update listBuffers
                Boolean isUpdate = updateBuffers(bufferPayMetListNotDelete);

                //delete listBuffers
                Boolean isDelete = deleteBuffers(bufferPayMetListToDelete);

                if(isUpdate == false || isDelete == false) {   
                    Database.rollback(sp);
                    raiseError = true;
                }

            } catch(Exception ex){
                Database.rollback(sp);
                raiseError = true;
            }

        } catch(Exception ex){
            raiseError = true;
            CLP_Logger.log(ex.getMessage(), Label.CLP_PaymentMethodBulkDeleteBatchLabel);
        }
        CLP_Logger.flush();
    }
    
    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_PaymentMethodBulkDeleteBatchLabel);
        //system.debug('CLP_PaymentMethodBulkDeleteBatch.finish.raiseError= ' + raiseError);
        if(raiseError){
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
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        }
    }  

    private void createLog(MikataInteBuffer__c buffer, CLP_BulkBillingWrapper.Payment billPm, String errorMsg, String operation) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = buffer.LastModifiedById;
        log.Origin__c  = Label.CLP_PaymentMethodBulkDeleteBatchLabel;
        log.Request__c = CLP_MikataPaymentMethodApi.getApiRequest(buffer, CLP_MikataApi.ApiType.F_DELETE);
        system.debug('@@@@@log.Request__c XXX= ' + log.Request__c);
        log.Response__c = CLP_MikataPaymentMethodApi.getApiResponse(billPm);
        log.Content__c = errorMsg;                    
        log.Operation__c = operation;
        CLP_Logger.log(log);
    }

    private Boolean updateBuffers(List<MikataInteBuffer__c> listToUpdate) {
        // update buffer cannot delete (call to Mikata failed)
        Boolean isSuccess = false;

        String[] listField = new String[]{'ManipulateStatus__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
        && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){                
            isSuccess = true;
            if (listToUpdate != null && !listToUpdate.isEmpty()) {
                update listToUpdate;         
            }     
        }
        return isSuccess; 
    }

    private Boolean deleteBuffers(List<MikataInteBuffer__c> listToDelete) {
        // delete buffer can delete (call to Mikata successfully)
        Boolean isSuccess = false;

        if (MikataInteBuffer__c.sObjectType.getDescribe().isDeletable()) {
            isSuccess = true;
            if (listToDelete != null && !listToDelete.isEmpty()) {
                delete listToDelete; 
            } 
        }
        return isSuccess;
    }
}