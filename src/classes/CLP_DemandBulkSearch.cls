/**
 * CLP_DemandBulkSearch.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_DemandBulkSearch class
 */
global with sharing class CLP_DemandBulkSearch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;

    public CLP_DemandBulkSearch() {
        
    }

    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning)
    {
        if (checkRunning)
        {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkSearch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_DemandBulkSearch processor = new CLP_DemandBulkSearch();
        Id batchprocessid=null;   
        batchprocessid = Database.executeBatch(processor, 200);  

        return batchprocessid;
    }
    /*
        Start Batch Bulk Stop Demand
        Query condition:
        1. ManipulateStatus__c = 2 (CLP_MikataConstant.DEMAND_LINK_AWAITING)
        2. StopFlg__c = 0 (CLP_MikataConstant.FLG_STOP)
        3. AwaitingGetNewInfo__c = false
    */
    global Database.querylocator start(Database.BatchableContext BC)
    {       
         //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
        return Database.getQueryLocator('Select Id,ErrorMessage__c,AwaitingGetNewInfo__c,ManipulateStatus__c' + 
                                            ' from DemandDetail__c where IsIntegrated__c = true'+
                                            ' and isStop__c = false and BillIssueDate__c !=null and AwaitingGetNewInfo__c = false');
    }
    /*
        Execute Batch Bulk Stop Demand
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
           List<DemandDetail__c> details =(List<DemandDetail__c>)scope;
           for(DemandDetail__c d: details){                
                d.ErrorMessage__c = ''; 
                d.AwaitingGetNewInfo__c = true;
                d.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
            }
         try{   
            List<DemandDetail__c> failedList = new List<DemandDetail__c>();
            // update demand List        
            String[] listField = new String[]{'ErrorMessage__c','AwaitingGetNewInfo__c','ManipulateStatus__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
                Savepoint sp;
                if(!Test.isRunningTest()){
                    sp = Database.setSavepoint();
                }
                // update demand
                Database.SaveResult[] rsList = Database.update(details,false);
                for(Integer i=0;i<rsList.size();i++){
                    if(!rsList[i].isSuccess())
                    {
                        String errMessage = '';
                        for(Database.Error e : rsList[i].getErrors()){
                            errMessage+= e.getMessage() + '\n';
                        }
                        details[i].ErrorMessage__c = errMessage;                    
                        details[i].AwaitingGetNewInfo__c = false;
                        details[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        failedList.add(details[i]);
                    }
                }
                //system.debug('failedList:' + failedList);
                if(!failedList.isEmpty())     
                {    
                    try{
                        update failedList;
                    }catch(DmlException ex){                        
                        if(!Test.isRunningTest()){
                            Database.rollback(sp);
                        }                        
                  //      system.debug('Error:' + ex.getDmlMessage(0));
                        throw ex;
                    }
                }
            }                   
        }catch(Exception ex){
             //system.debug('Error:' + ex.getMessage());
            throw ex;
        }
    }
    /*
        finish this batch send email and recall batch if was exist batch in queue
    */
    global void finish(Database.BatchableContext BC)
    {        
       CLP_DemandBulkSearchBatch.startBatch(true);  
    }    
}