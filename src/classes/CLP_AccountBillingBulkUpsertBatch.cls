/**
 * CLP_AccountBillingBulkUpsertBatch.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_AccountBillingBulkUpsertBatch
 */
global with sharing class CLP_AccountBillingBulkUpsertBatch 
    implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_AccountBillingBulkUpsertBatch() { 
    }

    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning){
        if (checkRunning){
            List<AsyncApexJob> aajList = [SELECT Id FROM AsyncApexJob WHERE CompletedDate = NULL AND JobType = 'BatchApex'
                                          AND ApexClass.Name = 'CLP_AccountBillingBulkUpsertBatch'
                                          AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing' OR Status = 'Holding')
                                          LIMIT 1];                          
            if (aajList.size() != 0) { return null ; }
        }
        CLP_AccountBillingBulkUpsertBatch processor = new CLP_AccountBillingBulkUpsertBatch();  
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{ 'Id', 'Name', 'SeikyusakiCode__c','StopFlg__c',
                         'ManipulateStatus__c','IsStop__c', 'IsIntegrated__c','LastModifiedById' };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from Account where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = null order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields)
                                ,String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING)});
        
        this.cntsql = String.format('Select count() from Account where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = null'
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING)});
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_AccountBillingBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            this.shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> listAcc = (List<Account>) scope; 
        try {           
            if(!listAcc.isEmpty()){
                //  call to api upsert 
                CLP_BulkBillingWrapper result = CLP_MikataBillingApi.billingAccountBulkUpsert(listAcc);
                for(CLP_BulkBillingWrapper.Billing bill : result.billing){
                    assignAccountStatus(bill, listAcc);
                }
            }
        }catch(Exception ex){
            this.raiseError = true;
            for(Account acc : listAcc){
                if(acc.ManipulateStatus__c==CLP_MikataConstant.DEMAND_LINK_AWAITING)
                {
                    Logger__c log = createLogUpsertBillAccount(acc, null);
                    acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                     // reset stop flag
                    if(acc.IsStop__c)
                       acc.StopFlg__c = CLP_MikataConstant.FLG_STOP;
                    log.Content__c = ex.getMessage();
                    log.Operation__c = CLP_Logger.L_ACCESS;
                    CLP_Logger.log(log);
                }
            }
        }
        //update list account
        updateBillAccount(listAcc);

        CLP_Logger.flush();
    }

    private void assignAccountStatus(CLP_BulkBillingWrapper.Billing bill, list<Account> listAcc){
        for(Account acc : listAcc){
            if(acc.SeikyusakiCode__c == bill.code){
                // create log
                Logger__c log = createLogUpsertBillAccount(acc, bill);
                if(String.isBlank(bill.error_code)){
                    acc.IsStop__c = false;
                    acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                    // add log sucess
                    //log.Operation__c = CLP_Logger.L_SUCCESS;
                    //CLP_Logger.log(log);
                }else{
                    if(acc.IsStop__c) // if stop failed set flagStop to priod value
                    {
                        acc.StopFlg__c = CLP_MikataConstant.FLG_STOP;
                    }                   
                    if(bill.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR))
                    {                        
                        acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                        log.Operation__c = CLP_Logger.L_ACCESS;
                    }else{                       
                        acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                        log.Operation__c = CLP_Logger.L_OUTBOUND;
                    }
                    CLP_Logger.log(log);
                }
                
            }
        }
    }

    // create log for BillIndividual
    private Logger__c createLogUpsertBillAccount(Account acc, CLP_BulkBillingWrapper.Billing response_i){
        MikataConfig__c mikataApi = CLP_MikataConstant.mikataConfig;
        // create new log
        Logger__c log = new Logger__c();                                
        log.LK_RelatedUser__c = acc.LastModifiedById;
        log.LK_Account__c = acc.Id;
        log.Origin__c  = Label.CLP_AccountBillingBulkUpsertBatchLabel;
        log.Content__c = (response_i != null)?response_i.error_message:'';

        CLP_BulkBillingWrapper request = new CLP_BulkBillingWrapper(mikataApi.ApiUserId__c, mikataApi.ApiAccessKey__c, null);
        request.getBillingByCodeName(acc.SeikyusakiCode__c, acc.Name);
        log.Request__c = JSON.serialize(request);
        
        CLP_BulkBillingWrapper response = new CLP_BulkBillingWrapper(mikataApi.ApiUserId__c, mikataApi.ApiAccessKey__c, null);
        response.billing.add(response_i);
        log.Response__c = JSON.serialize(response);
        return log;
    }

    private void updateBillAccount(List<Account> listAcc){
        // update bill individual
        String[] listField = new String[]{'ManipulateStatus__c','ErrorMessage__c', 'IsStop__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_ACCOUNT, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){             
            Database.SaveResult[] resultList = Database.update(listAcc,false);
            for (Integer i=0; i<resultList.size(); i++){
                if (!resultList[i].isSuccess()) { 
                    // add log
                    Logger__c log = createLogUpsertBillAccount(listAcc[i],null);
                    String errMessage = '';
                    for(Database.Error e : resultList[i].getErrors()){
                        errMessage+= e.getMessage() + '\n';
                    }
                    log.Content__c = errMessage;
                    log.Operation__c = CLP_Logger.L_OUTBOUND;
                    CLP_Logger.log(log);               
                }  
            }  
        }else{
            raiseError = true;
            for(Account acc : listAcc){
                Logger__c log = createLogUpsertBillAccount(acc,null);
                log.Content__c = CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION;
                log.Operation__c = CLP_Logger.L_OUTBOUND;
                CLP_Logger.log(log);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_AccountBillingBulkUpsertBatchLabel);
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
        if(this.shouldStop){
            for(AsyncApexJob aaj : [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_AccountBillingBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        } 
    }

}