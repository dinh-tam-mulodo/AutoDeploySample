global with sharing class CLP_PaymentMethodBulkUpsertBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_PaymentMethodBulkUpsertBatch() {
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            //system.debug('CLP_PaymentMethodBulkUpsertBatch.startBatch.aajList= ' + aajList);                           
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_PaymentMethodBulkUpsertBatch processor = new CLP_PaymentMethodBulkUpsertBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{
            'Id', 'LastModifiedById', 'IsIntegrated__c', 'IsStop__c', 'StopFlg__c', 'ManipulateStatus__c', 'ErrorMessage__c',
            'AccountId__c', 'AccountId__r.SeikyusakiCode__c', 'AccountId__r.Name', 'AccountId__r.IsIntegrated__c', 
            'source_bank_account_name__c', 'Bank_Transfer_Pattern_Code__c', 'bank_check_bank_code__c', 'bank_check_bank_name__c',
            'bank_check_branch_code__c', 'bank_check_branch_name__c', 'bank_check_bank_account_number__c', 'bank_check_kind__c',
            'BankName__c', 'BranchName__c', 'BankAccountType__c', 'BankAccountName__c', 'CustomerNumber__c', 'RegisterStatus__c',  
            'PaymentMethodCode__c', 'Name', 'PaymentMethod__c', 'BranchCode__c', 'BankCode__c', 'BankAccountNumber__c',
            'ExternalKey__c'
        };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from PaymentMethod__c where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = null order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields), 
                                String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING) });
        
        this.cntsql = String.format('Select count() from PaymentMethod__c where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = null'
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING) });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try 
        {
            List<PaymentMethod__c> payMetsList = (List<PaymentMethod__c>) scope;
            Map<String, List<PaymentMethod__c>> accCodeListPmMap = createListPmByAccountCode(payMetsList);
            Map<String, CLP_BulkBillingWrapper.Billing> payMetMapSuccess = new Map<String, CLP_BulkBillingWrapper.Billing>();
            Map<String, CLP_BulkBillingWrapper.Billing> payMetMapFailed = new Map<String, CLP_BulkBillingWrapper.Billing>();
            Set<Id> accountIdSetSuccess = new Set<Id>();

            //  call to api upsert 
            CLP_BulkBillingWrapper result = CLP_MikataPaymentMethodApi.paymentMethodBulkUpsert(payMetsList);
            system.debug('CLP_PaymentMethodBulkUpsertBatch.execute.result= ' + result);

            if(result.success) {
                // loop list billing      
                for (CLP_BulkBillingWrapper.Billing aBilling : result.billing) {
                    if (String.isBlank(aBilling.error_message)) {
                        payMetMapSuccess.put(aBilling.code, aBilling);  
                    } 
                    else {
                        payMetMapFailed.put(aBilling.code, aBilling);
                    }
                }

                for (PaymentMethod__c pm : payMetsList) {
                    // Error occured at level billing (Account)
                    if (payMetMapFailed.keySet().contains(pm.AccountId__r.SeikyusakiCode__c)) { 
                        pm.ErrorMessage__c = null; 
                        pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                        // Create new log
                        CLP_BulkBillingWrapper.Billing errBilling = payMetMapFailed.get(pm.AccountId__r.SeikyusakiCode__c); 
                        createLog(pm, errBilling);
                        // restore stop flag if cannot "unstop" product
                        if (pm.IsStop__c) {
                            pm.StopFlg__c = CLP_MikataConstant.FLG_STOP; 
                        }
 
                    // Error occured at level payment or don't have any error
                    } else {
                        CLP_BulkBillingWrapper.Billing billingAccMikata = payMetMapSuccess.get(pm.AccountId__r.SeikyusakiCode__c);
                        String accCodeMikata = billingAccMikata.code;
                        List<CLP_BulkBillingWrapper.Payment> pmsMikata = billingAccMikata.payment;
                        List<PaymentMethod__c> pmsSfdc = accCodeListPmMap.get(pm.AccountId__r.SeikyusakiCode__c);

                        // Sort order of list payment method (request) <=> list billing payment (response)
                        String errMsg = getMessageError(pm, pmsSfdc, pmsMikata, accCodeMikata);
                        CLP_BulkBillingWrapper.Payment paymentResponse = getPaymentResponse(pm, pmsSfdc, pmsMikata, accCodeMikata);

                        // case update to DEMAND_LINK_SUCCESS     
                        if (String.isBlank(errMsg)) {
                            // come from action UNSTOP --> set IsStop__c = false and NOT update related account  
                            if (pm.IsStop__c) {
                                pm.IsStop__c = false;

                            // come from action UPSERT --> Update related account         
                            } else {                  
                                accountIdSetSuccess.add(pm.AccountId__c);    
                            }
                            pm.ErrorMessage__c = null; 
                            pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                            pm.IsIntegrated__c = true;
                            pm.RegisterStatus__c = paymentResponse.register_status;
                            if (pm.PaymentMethod__c == CLP_MikataConstant.PM_BANK_CHECK) {
                                updateDataBankCheck(pm, paymentResponse);
                            }
                            //createLog(pm, paymentResponse, errMsg, CLP_Logger.L_SUCCESS);    

                        // case update to DEMAND_FAILED_DATA_DEFECT  
                        } else {
                            pm.ErrorMessage__c = null; 
                            pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                            // Create new log
                            createLog(pm, paymentResponse, errMsg, CLP_Logger.L_OUTBOUND);    
                            // restore stop flag if cannot "unstop" product
                            if (pm.IsStop__c) {
                                pm.StopFlg__c = CLP_MikataConstant.FLG_STOP; 
                            }
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
                    // restore stop flag if cannot "unstop" product
                    if (pm.IsStop__c) {
                        pm.StopFlg__c = CLP_MikataConstant.FLG_STOP; 
                    }
                }
            } 

            // update payment method 
            updatePayMets(payMetsList);

            // update account related to payment method
            List<Account> listAccountToUpdate = [Select Id, IsIntegrated__c, ManipulateStatus__c
                                                 From Account
                                                 where Id In :accountIdSetSuccess];

            if (listAccountToUpdate != null && !listAccountToUpdate.isEmpty()) {
                for (Account acc : listAccountToUpdate) {
                    acc.IsIntegrated__c = true;   
                    acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                }

                String[] listField1 = new String[]{'IsIntegrated__c', 'ManipulateStatus__c'};
                if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_ACCOUNT, listField1, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
                && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_ACCOUNT, listField1, CLP_CommonUtil.FLSType.CREATE_OBJECT)){             
                    update listAccountToUpdate;  
                }    
            }                                       

        } catch(Exception ex){
            this.raiseError = true;
            System.debug('CLP_PaymentMethodBulkUpsertBatch.execute.exception= ' + ex.getMessage());
            CLP_Logger.log(ex.getMessage(), Label.CLP_PaymentMethodBulkUpsertBatchLabel);
        }
        CLP_Logger.flush();
    }
    
    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_PaymentMethodBulkUpsertBatchLabel);
        //system.debug('CLP_PaymentMethodBulkUpsertBatch.finish.raiseError= ' + raiseError);
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
                                          and ApexClass.Name = 'CLP_PaymentMethodBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        }
    }  

    private void createLog(PaymentMethod__c pm, CLP_BulkBillingWrapper.Payment billpm, String errorMsg, String operation) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = pm.LastModifiedById;
        log.LK_PaymentMethod__c = pm.Id;
        log.Origin__c = Label.CLP_PaymentMethodBulkUpsertBatchLabel;
        if (pm.IsStop__c) {
            log.Request__c = CLP_MikataPaymentMethodApi.getApiRequest(pm, CLP_MikataApi.ApiType.F_UNSTOP);
        } else {
            log.Request__c = CLP_MikataPaymentMethodApi.getApiRequest(pm, CLP_MikataApi.ApiType.F_UPSERT);  
        } 
        log.Response__c = CLP_MikataPaymentMethodApi.getApiResponse(billpm);
        log.Content__c = errorMsg;                        
        log.Operation__c = operation;
        CLP_Logger.log(log);
    }   

    private void createLog(PaymentMethod__c pm, CLP_BulkBillingWrapper.Billing billpm) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = pm.LastModifiedById;
        log.LK_PaymentMethod__c = pm.Id;
        log.Origin__c = Label.CLP_PaymentMethodBulkUpsertBatchLabel;
        if (pm.IsStop__c) {
            log.Request__c = CLP_MikataPaymentMethodApi.getApiRequest(pm, CLP_MikataApi.ApiType.F_UNSTOP);
        } else {
            log.Request__c = CLP_MikataPaymentMethodApi.getApiRequest(pm, CLP_MikataApi.ApiType.F_UPSERT);  
        } 
        log.Response__c = CLP_MikataPaymentMethodApi.getApiResponse(billpm, true);
        log.Content__c = billpm.error_message;                        
        log.Operation__c = CLP_Logger.L_OUTBOUND;
        CLP_Logger.log(log);
    }

    private Map<String, List<PaymentMethod__c>> createListPmByAccountCode(List<PaymentMethod__c> listPm) {
        Map<String, List<PaymentMethod__c>> maps = new Map<String, List<PaymentMethod__c>>();
        Integer cnt = 0;
        for (PaymentMethod__c pm : listPm) {
            cnt++;
            if (cnt == 1) {
                maps.put(pm.AccountId__r.SeikyusakiCode__c, new List<PaymentMethod__c>{pm});
            
            } else {
                if (maps.keySet().contains(pm.AccountId__r.SeikyusakiCode__c)) {
                    List<PaymentMethod__c> tempList = maps.get(pm.AccountId__r.SeikyusakiCode__c);
                    tempList.add(pm); 
                    maps.put(pm.AccountId__r.SeikyusakiCode__c, tempList);       
                
                } else {
                    maps.put(pm.AccountId__r.SeikyusakiCode__c, new List<PaymentMethod__c>{pm});           
                }
            }      
        }
        return maps;  
    }

    private String getMessageError(PaymentMethod__c pm, List<PaymentMethod__c> pmsSfdc, 
                                   List<CLP_BulkBillingWrapper.Payment> pmsMikata, String accCodeMikata) {
        Integer index = getIndexByPayMetCode(pm, pmsSfdc);
        String defaultErrorMsg = 'エラー：請求管理ロボの連携にエラーが発生しました。';
        if (index < 0) {
            return defaultErrorMsg;
        } 
        
        // If error has occured
        if (String.isNotBlank(pmsMikata[index].error_message)) {
            return pmsMikata[index].error_message;

        // Else check that external key is matched between Sfdc and Mikata
        } else {
            String externalKeyMikata = accCodeMikata + '_' + pmsMikata[index].code;
            if (pm.ExternalKey__c == externalKeyMikata) {
                return pmsMikata[index].error_message;
            } else {
                return defaultErrorMsg;
            }
        }
    }

    private CLP_BulkBillingWrapper.Payment getPaymentResponse(PaymentMethod__c pm, List<PaymentMethod__c> pmsSfdc, 
                                                              List<CLP_BulkBillingWrapper.Payment> pmsMikata, String accCodeMikata) {
        Integer index = getIndexByPayMetCode(pm, pmsSfdc);
        if (index < 0) {
            return null;
        }

        // If error has occured
        if (String.isNotBlank(pmsMikata[index].error_message)) {
            return pmsMikata[index];

        // Else check that external key is matched between Sfdc and Mikata
        } else {
            String externalKeyMikata = accCodeMikata + '_' + pmsMikata[index].code;
            if (pm.ExternalKey__c == externalKeyMikata) {
                return pmsMikata[index];
            } else {
                return null;
            }
        }
    }

    private Integer getIndexByPayMetCode(PaymentMethod__c pm, List<PaymentMethod__c> pmsSfdc) {
        for (Integer i=0; i<pmsSfdc.size(); i++) {
            if (pm.PaymentMethodCode__c == pmsSfdc[i].PaymentMethodCode__c) {
                return i;        
            }    
        }
        return -1;            
    }

    private void updateDataBankCheck(PaymentMethod__c pmReq, CLP_BulkBillingWrapper.Payment pmRes) {
        pmReq.bank_check_kind__c = pmRes.bank_check_kind;
        pmReq.bank_check_bank_code__c = pmRes.bank_check_bank_code;
        pmReq.bank_check_bank_name__c = pmRes.bank_check_bank_name;
        pmReq.bank_check_branch_code__c = pmRes.bank_check_branch_code;
        pmReq.bank_check_branch_name__c = pmRes.bank_check_branch_name;
        pmReq.bank_check_bank_account_number__c = pmRes.bank_check_bank_account_number;
    }

    private void updatePayMets(List<PaymentMethod__c> payMetsList) {
        String[] listField = new String[]{
            'ErrorMessage__c', 'ManipulateStatus__c', 'IsIntegrated__c', 'IsStop__c', 'StopFlg__c', 
            'bank_check_bank_code__c', 'bank_check_bank_name__c', 'bank_check_branch_code__c', 
            'bank_check_branch_name__c', 'bank_check_bank_account_number__c', 'bank_check_kind__c'
        };
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