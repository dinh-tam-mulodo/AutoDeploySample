/**
 * CLP_DemandBulkSearchBatch.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_DemandBulkSearchBatch class
 */
global with sharing class CLP_DemandBulkSearchBatch 
implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    public CLP_DemandBulkSearchBatch() {
        
    }

    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning)
    {
        if (checkRunning)
        {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkSearchBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            system.debug(aajList);
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_DemandBulkSearchBatch processor = new CLP_DemandBulkSearchBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }
    /*
        Start Batch Upsert Demand 
        Query codition:
        1. ManipulateStatus__c = 2 (CLP_MikataConstant.DEMAND_LINK_AWAITING)
        2. AwaitingGetNewInfo__c = true ===> avoid demand integrated demand/search
    */
    global Database.querylocator start(Database.BatchableContext BC)
    {
        String[] fieldsArray = new String[]{
            'Id','Name','Account__r.SeikyusakiCode__c','Seikyuusakibusho__r.Id','Seikyuusakibusho__r.billing_individual_number__c',
            'PaymentMethod__r.PaymentMethodCode__c','GoodsCode__c','Quantity__c','Period_Unit__c','DemandDetailCode__c',
            'Unit__c','TaxCategory__c','TaxRate__c','Repeat_Period_Number__c','Period_Value__c',
            'Period_Format__c','PaymentProcess__c','StartDate__c','Period_Criterion__c',
            'Repeat_Count__c','DemandType__c','ProductName__c','Price__c','ManipulateStatus__c',
            'SalesRecordedDate__c','BillIssueDate__c','BillSendDate__c','Bill_Template_Code__c',
            'PaymentDeadlineDate__c','Slip_Deadline__c','LastModifiedById','IsStop__c','BsOwnerCode__c',
            'BillSendScheduleCriteria_Day__c','BillSendScheduleCriteria_Month__c','TransferDeadline_Day__c',
            'TransferDeadline_Month__c','SlipDeadline_Day__c','SlipDeadline_Month__c','BillIssueCriteria_Date__c',
            'BillIssueCriteria_Month__c','AwaitingGetNewInfo__c','Item_code__c','Remark__c'
        };
        String fields = String.join(fieldsArray,',');
        this.sql = String.format('Select {0} from DemandDetail__c where ManipulateStatus__c = \'\'{1}\'\' and AwaitingGetNewInfo__c = true order by LastModifiedDate  asc'
                ,new String[]{String.escapeSingleQuotes(fields),String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING)});
        this.cntsql = String.format('Select count() from DemandDetail__c where ManipulateStatus__c = \'\'{0}\'\' and AwaitingGetNewInfo__c = true',new String[]{String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING)});
         //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_DemandBulkSearchBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }
    // execute callout bulk upsert mikata
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        try{
            List<DemandDetail__c> demandList = (List<DemandDetail__c>) scope;
            if(!demandList.isEmpty()){
                //  call to api upsert
                CLP_BulkDemandWrapper result = CLP_MikataDemandAPI.demandBulkSearch(demandList);
                system.debug('result:'+result);
                // call api success 
                if(result.success){
                     // update demand status with mapping data from api     
                    changeDemandStatus(demandList,result.demand);
                }else{ // call api failed
                    for(DemandDetail__c sfdcDemand : demandList){
                        Logger__c log = createLogger(sfdcDemand,null); 
                        log.Operation__c = CLP_Logger.L_ACCESS;                        
                        sfdcDemand.ErrorMessage__c = result.error_message;
                        sfdcDemand.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                        // if integrated failed ==> reset flag AwaitingGetNewInfo__c
                        sfdcDemand.AwaitingGetNewInfo__c = false;
                        // add log
                        CLP_Logger.log(log);
                    }
                }
                // update demand list
                updateDemandList(demandList);                
            }           
        }catch(Exception ex){
            raiseError = true;
            CLP_Logger.log(ex.getMessage(),Label.CLP_DemandBulkSearchBatchLabel);
        }
        // insert log
        CLP_Logger.flush();
    }
    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC)
    {
        CLP_MikataAPI.sendEmailComplete('CLP_SendLogEmail',Label.CLP_DemandBulkSearchBatchLabel);
        //system.debug('raiseError');
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
                                          and ApexClass.Name = 'CLP_DemandBulkSearchBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        }
    }
    // update demand status with mapping data from api
    private void changeDemandStatus(List<DemandDetail__c> demandList,List<CLP_BulkDemandWrapper.Demand> apiDemands){
        try{
            // loop demand and update demandDetail to success
            Integer i = 0;
            for(CLP_BulkDemandWrapper.Demand apiDemand : apiDemands){
                // check error when call api
                if(String.IsBlank(apiDemand.code) && String.IsBlank(apiDemand.number_Z))
                {
                    // in case raise error and do not return demand code
                    DemandDetail__c sfdcDemand = demandList[i];                              
                    sfdcDemand.ErrorMessage__c = apiDemand.error_message;
                    sfdcDemand.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                    Logger__c log = createLogger(sfdcDemand,apiDemand); 
                    CLP_Logger.log(log);
                    i++;
                    continue;
                }
                // check is exist demand in reponse
                for(DemandDetail__c sfdcDemand : demandList){                
                    if((apiDemand.code == sfdcDemand.Id || sfdcDemand.DemandDetailCode__c == apiDemand.number_Z)
                        && sfdcDemand.Account__r.SeikyusakiCode__c == apiDemand.billing_code){
                        //system.debug('come here:'+apiDemand.number_Z);
                        // create new log
                        Logger__c log = createLogger(sfdcDemand,apiDemand);
                        // register success
                        if(String.isBlank(apiDemand.error_code))
                        {
                            sfdcDemand.ErrorMessage__c = '';
                            sfdcDemand.RemainingAmount__c = apiDemand.repeat_count_limit;
                            sfdcDemand.BillIssueDate__c = CLP_CommonUtil.convertJsonDate(apiDemand.next_issue_date);
                            sfdcDemand.BillSendDate__c = CLP_CommonUtil.convertJsonDate(apiDemand.next_sending_date);
                            sfdcDemand.PaymentDeadlineDate__c = CLP_CommonUtil.convertJsonDate(apiDemand.next_deadline_date);
                            sfdcDemand.Slip_Deadline__c = CLP_CommonUtil.convertJsonDate(apiDemand.next_slip_deadline_date);
                            // update dd 23/10/2017
                            sfdcDemand.PeriodStartDate__c = CLP_CommonUtil.convertJsonDate(apiDemand.next_period_start_date);
                            sfdcDemand.PeriodEndDate__c = CLP_CommonUtil.convertJsonDate(apiDemand.next_period_end_date);
                            sfdcDemand.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                            // reset AwaitingGetNewInfo__c
                            sfdcDemand.AwaitingGetNewInfo__c = false;
                            // add log sucess
                            //log.Operation__c = CLP_Logger.L_SUCCESS;
                            //CLP_Logger.log(log);
                        }else{
                            if(apiDemand.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR)){
                                log.Operation__c = CLP_Logger.L_ACCESS;
                                sfdcDemand.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                                
                            }else{// data error                        
                                log.Operation__c = CLP_Logger.L_OUTBOUND;
                                sfdcDemand.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                            }
                            // if integrated failed ==> reset flag AwaitingGetNewInfo__c
                            sfdcDemand.AwaitingGetNewInfo__c = false;
                            //sfdcDemand.ErrorMessage__c = apiDemand.error_message;
                            CLP_Logger.log(log);
                        }                               
                        break;
                    }
                }
            }
        }catch(Exception ex){
            system.debug('error:'+ex.getMessage());
            throw ex;
        }
    }
    // create logger
    private Logger__c createLogger(DemandDetail__c sfdcDemand,CLP_BulkDemandWrapper.Demand apiDemand){
        Logger__c log = new Logger__c();                                
        log.LK_RelatedUser__c = sfdcDemand.LastModifiedById;
        log.LK_DemandDetail__c = sfdcDemand.Id;
        log.Content__c = apiDemand != null ? apiDemand.error_message : '';
        log.Origin__c  = Label.CLP_DemandBulkSearchBatchLabel;
        log.Request__c = sfdcDemand !=null ? CLP_MikataDemandAPI.getApiRequest(sfdcDemand,CLP_MikataApi.ApiType.F_UPSERT) : '';
        log.Response__c = apiDemand != null ? CLP_MikataDemandAPI.getApiResponse(apiDemand) : '';
        log.Operation__c = CLP_Logger.L_OUTBOUND;
        system.debug('log:'+log);
        return log;
    }
    // update demand detail list
    private void updateDemandList(List<DemandDetail__c> demandList){
        String[] listField = new String[]{'RemainingAmount__c','ErrorMessage__c'
                                            ,'ManipulateStatus__c','BillIssueDate__c'
                                            ,'BillSendDate__c','PaymentDeadlineDate__c','Slip_Deadline__c' };
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
            // update demand
            Database.SaveResult[] resultList = Database.update(demandList,false);
            for (Integer i=0; i<resultList.size(); i++){
                if (!resultList[i].isSuccess()) { 
                    // add log
                    Logger__c log = createLogger(demandList[i],null);
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
            for(DemandDetail__c demand : demandList){
                Logger__c log = createLogger(demand,null);
                log.Content__c = CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION;
                log.Operation__c = CLP_Logger.L_OUTBOUND;
                CLP_Logger.log(log);
            }   
        }
    }
}