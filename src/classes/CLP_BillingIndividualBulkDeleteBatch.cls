/**
 * CLP_BillingIndividualBulkDeleteBatch.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_BillingIndividualBulkDeleteBatch
 */
global with sharing class CLP_BillingIndividualBulkDeleteBatch 
implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_BillingIndividualBulkDeleteBatch() { 
    }
      
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning){
        if (checkRunning){
            List<AsyncApexJob> aajList = [SELECT Id FROM AsyncApexJob WHERE CompletedDate = NULL AND JobType = 'BatchApex'
                                          AND ApexClass.Name = 'CLP_BillingIndividualBulkDeleteBatch'
                                          AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing' OR Status = 'Holding')
                                          LIMIT 1];                          
            if (aajList.size() != 0) { return null ; }
        }
        CLP_BillingIndividualBulkDeleteBatch processor = new CLP_BillingIndividualBulkDeleteBatch();  
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{ 'Id', 'Name','AccountId__c','AccountId__r.SeikyusakiCode__c','AccountId__r.Name'
                                ,'ManipulateStatus__c','RecordCode__c','RecordID__c','SObjectType__c','LastModifiedById'
                            };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from MikataInteBuffer__c where ManipulateStatus__c = \'\'{1}\'\' and SObjectType__c = \'\'{2}\'\' order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields)
                                ,String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING)
                                ,CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL });
        
        this.cntsql = String.format('Select count() from MikataInteBuffer__c where ManipulateStatus__c = \'\'{0}\'\' and SObjectType__c = \'\'{1}\'\''
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING)
                                ,CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_BillingIndividualBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            this.shouldStop=true;
        }
        
        return Database.getQueryLocator(this.sql);
    } 

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            List<MikataInteBuffer__c> listBuffers = (List<MikataInteBuffer__c>) scope;  
            if(!listBuffers.isEmpty()){

                CLP_BulkBillingWrapper result = CLP_MikataBillingApi.billingIndividualBulkDelete(listBuffers);
                system.debug('result of billingIndividualBulkDelete= ' + result);
                if(result==null){// failed when integrated
                    for(MikataInteBuffer__c bf : listBuffers){
                        bf.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                    }
                }else{ 
                    // loop all billing in response  
                    List<MikataInteBuffer__c> copyList = listBuffers.clone();
                    List<MikataInteBuffer__c> deleteList = new List<MikataInteBuffer__c>();
                    for(CLP_BulkBillingWrapper.Billing billing : result.billing){
                        if (String.isBlank(billing.error_message)) {
                            // loop all individual in billling
                            for(CLP_BulkBillingWrapper.Individual bi : billing.individual){
                                for(Integer cnt = 0; cnt< copyList.size(); cnt++){
                                    MikataInteBuffer__c buffer = copyList[cnt];   
                                    // get match record request - reponse
                                    if(buffer.RecordCode__c == bi.code 
                                        && billing.code == buffer.AccountId__r.SeikyusakiCode__c){
                                        // create log for api
                                        Logger__c log = createLogBillIndividual(buffer, bi); 
                                        if(String.isBlank(bi.error_code)){ // connect success    
                                            // deleted buffer
                                            deleteList.add(buffer);
                                            // remove this record in listbuffers
                                            listBuffers.remove(cnt);
                                            // add log sucess
                                            //log.Operation__c = CLP_Logger.L_SUCCESS;
                                            //CLP_Logger.log(log);
                                        }else{ // connect failed    
                                            if(bi.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR)){ //INTERFACE ERROR
                                                buffer.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                                                log.Operation__c = CLP_Logger.L_ACCESS;
                                            }else{                                          
                                                buffer.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                                                log.Operation__c = CLP_Logger.L_OUTBOUND;
                                            }
                                            CLP_Logger.log(log);
                                        }
                                        break;
                                    } 
                                } 
                            }
                        }     
                    }

                    for(MikataInteBuffer__c bf : listBuffers){ 
                        if(bf.ManipulateStatus__c == CLP_MikataConstant.DEMAND_LINK_AWAITING){ // recheck un-response request
                            bf.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                            // create log for billing individual
                            Logger__c log = createLogBillIndividual(bf,null);
                            log.Operation__c = CLP_Logger.L_ACCESS;
                            CLP_Logger.log(log);        
                        }
                    }
                    Savepoint sp = Database.setSavepoint();
                    try{
                        //update listBuffers
                        Boolean isUpdate = updateBuffers(listBuffers);
                        //delete listBuffers
                        Boolean isDelete = deleteBuffers(deleteList);
                        if(isUpdate == false || isDelete == false)
                        {
                            Database.rollback(sp);
                            raiseError = true;
                        }
                    }catch(Exception ex){
                        Database.rollback(sp);
                        raiseError = true;
                    }
                }                
            } 
        }catch(Exception ex){
            this.raiseError = true;
            CLP_Logger.log(ex.getMessage(),Label.CLP_BillingIndividualBulkDeleteBatchLabel);
        }
        CLP_Logger.flush();
    }
    // update BillIndividual data 
    private Boolean updateBuffers(List<MikataInteBuffer__c> listBuffers){
        // update bill individual
        Boolean isSuccess = false;
        String[] listField = new String[]{'ManipulateStatus__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){             
            update listBuffers;
            isSuccess = true;  
        }
        return isSuccess;
    }

    private Boolean deleteBuffers(List<MikataInteBuffer__c> listBuffers){
        Boolean isSuccess = false;
        if (MikataInteBuffer__c.sObjectType.getDescribe().isDeletable()) {
            delete listBuffers;
            isSuccess = true;  
        }
        return isSuccess;
    } 

    // create log for BillIndividual
    private Logger__c createLogBillIndividual(MikataInteBuffer__c bf, CLP_BulkBillingWrapper.Individual response_i){
        // create new log
        Logger__c log = new Logger__c();                                
        log.LK_RelatedUser__c = bf.LastModifiedById;
        log.LK_MikataInteBuffer__c = bf.Id;
        log.Content__c = response_i != null ? response_i.error_message : '';
        log.Origin__c  = Label.CLP_BillingIndividualBulkDeleteBatchLabel;        
        // get billing individual from buffer record 
        log.Request__c = (bf != null)?CLP_MikataBillingApi.getApiRequestBillIndividual(bf):'';
        log.Response__c = (response_i != null)?CLP_MikataBillingApi.getApiResponseBillIndividual(response_i):'';
        return log;
    }

    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_BillingIndividualBulkDeleteBatchLabel);
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
                                          and ApexClass.Name = 'CLP_BillingIndividualBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        }
        // call empty demand in recyle bin batch
        CLP_DemandBulkEmptyRecycleBinBatch.startBatch(true,CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL);
    }
}