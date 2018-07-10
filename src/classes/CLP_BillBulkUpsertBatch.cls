global with sharing class CLP_BillBulkUpsertBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_BillBulkUpsertBatch() {
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_BillBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            //system.debug('CLP_BillBulkUpsertBatch.startBatch.aajList= ' + aajList);                           
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_BillBulkUpsertBatch processor = new CLP_BillBulkUpsertBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{
            'Id', 'LastModifiedById', 'number__c', 'AccountId__r.SeikyusakiCode__c', 'MessageColumn__c', 'SendingScheduledDate__c',
            'PaymentDeadlineDate__c', 'manipulateStatus__c', 'PaymentStatus__c', 'IsIntegrated__c', 'IsStop__c', 'StopFlg__c', 
            'ErrorMessage__c', 'BillingCode__c', 'AwaitingGetNewBill__c' 
        };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from Bill__c where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = null and AwaitingGetNewBill__c = False order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields), 
                                String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING) });
        
        this.cntsql = String.format('Select count() from Bill__c where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = null and AwaitingGetNewBill__c = False'
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING) });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_BillBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            List<Bill__c> listBill = (List<Bill__c>) scope;
            system.debug('CLP_BillBulkUpsertBatch.execute.listBill before= ' + listBill);

            //  call to api upsert bill
            CLP_BulkBillWrapper result = CLP_MikataBillApi.billBulkUpsert(listBill);
            system.debug('CLP_BillBulkUpsertBatch.execute.result= ' + result);

            if (result.success) {
                // loop list bill in response
                List<CLP_BulkBillWrapper.Bill> billResList = result.bill;

                for (Integer i=0; i<billResList.size(); i++) {
                    CLP_BulkBillWrapper.Bill billRes = billResList[i]; 
                    if (String.isBlank(billRes.error_message)) {
                        // loop list bill in request
                        for (Bill__c bill : listBill) {
                            // make sur that the bill number must match by request/response
                            if (billRes.number_z == bill.number__c) {
                                bill.ErrorMessage__c = null;
                                bill.IsIntegrated__c = true;
                                bill.IsStop__c = false;         // for case "Unstop"
                                bill.manipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                                //createLog(bill, billRes, billRes.error_message, CLP_Logger.L_SUCCESS); 
                                break;  
                            }
                        }
                   
                    } else {
                        Bill__c errBill = listBill[i];
                        errBill.ErrorMessage__c = null;
                        errBill.manipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                        // Create new log
                        createLog(errBill, billRes, billRes.error_message, CLP_Logger.L_OUTBOUND);   
                        // Reset StopFlg__c when "Unstop" have error 
                        if (errBill.IsStop__c) {
                            errBill.StopFlg__c = CLP_MikataConstant.FLG_STOP;    
                        } 
                    }
                }

            //  if (!result.success)
            } else {
                // case update to DEMAND_FAILED_INTERFACE 
                for(Bill__c bill : listBill){
                    bill.ErrorMessage__c = null;
                    bill.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                    // Create new log
                    createLog(bill, null, result.error_message, CLP_Logger.L_ACCESS);
                    // Reset StopFlg__c when "Unstop" have error 
                    if (bill.IsStop__c) {
                        bill.StopFlg__c = CLP_MikataConstant.FLG_STOP; 
                    }
                }
            }

            // update list bill
            updateBills(listBill);

        } catch(Exception ex) {
            this.raiseError = true;
            System.debug('CLP_BillBulkUpsertBatch.execute.exception= ' + ex.getMessage());
            CLP_Logger.log(ex.getMessage(), Label.CLP_BillBulkUpsertBatchLabel);
        }
        CLP_Logger.flush();
    }
    
    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_BillBulkUpsertBatchLabel);
        //system.debug('CLP_BillBulkUpsertBatch.finish.raiseError= ' + raiseError);
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
                                          and ApexClass.Name = 'CLP_BillBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        }
    }  

    private void createLog(Bill__c billReq, CLP_BulkBillWrapper.Bill billRes, String errorMsg, String operation) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = billReq.LastModifiedById;
        log.Origin__c  = Label.CLP_BillBulkUpsertBatchLabel;
        if (billReq.IsStop__c) {
            log.Request__c = CLP_MikataBillApi.getApiRequest(billReq, CLP_MikataApi.ApiType.F_UNSTOP); 
        } else {
            log.Request__c = CLP_MikataBillApi.getApiRequest(billReq, CLP_MikataApi.ApiType.F_UPSERT);
        }
        log.Response__c = CLP_MikataBillApi.getApiResponse(billRes);
        log.Content__c = errorMsg;                        
        log.Operation__c = operation;
        CLP_Logger.log(log);
    }   

    private void updateBills(List<Bill__c> listBill) {
        String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'IsIntegrated__c', 'IsStop__c', 'StopFlg__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
        && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){             
            Database.SaveResult[] saveResults = Database.update(listBill, false);
            for (Integer i=0; i<saveResults.size(); i++){
                if (!saveResults[i].isSuccess()) {
                    String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                    createLog(listBill[i], null, totalErrorMsg, CLP_Logger.L_OUTBOUND);
                }
            } 
        
        } else {
            this.raiseError = true;
            for (Bill__c bill : listBill) {
                createLog(bill, null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND);
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