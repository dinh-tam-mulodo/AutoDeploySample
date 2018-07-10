/**
 * CLP_BillingIndividualBulkStopBatch.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_BillingIndividualBulkStopBatch
 */
global with sharing class CLP_BillingIndividualBulkStopBatch
    implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
        
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_BillingIndividualBulkStopBatch() { 
    }
      
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning){
        if (checkRunning){
            List<AsyncApexJob> aajList = [SELECT Id FROM AsyncApexJob WHERE CompletedDate = NULL AND JobType = 'BatchApex'
                                          AND ApexClass.Name = 'CLP_BillingIndividualBulkStopBatch'
                                          AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing' OR Status = 'Holding')
                                          LIMIT 1];                          
            if (aajList.size() != 0) { return null ; }
        }
        CLP_BillingIndividualBulkStopBatch processor = new CLP_BillingIndividualBulkStopBatch();  
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{ 'Id', 'Name', 'Seikyusakimei__r.SeikyusakiCode__c','billing_individual_number__c',
            'Seikyusakimei__r.IsIntegrated__c', 'Seikyusakimei__r.Name','StopFlg__c', 'ManipulateStatus__c',
            'IsStop__c','ErrorMessage__c', 'Seikyusakimei__c', 'IsIntegrated__c','LastModifiedById' 
        };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from Seikyusakibusho__c where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = \'\'{2}\'\' order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields)
                                ,String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING)
                                ,CLP_MikataConstant.FLG_STOP });
        
        this.cntsql = String.format('Select count() from Seikyusakibusho__c where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = \'\'{1}\'\''
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING)
                                ,CLP_MikataConstant.FLG_STOP });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_BillingIndividualBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            this.shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    } 

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Seikyusakibusho__c> listBI = (List<Seikyusakibusho__c>) scope; 
        try {
            if(!listBI.isEmpty()){
                CLP_BulkBillingWrapper result = CLP_MikataBillingApi.billingIndividualBulkStop(listBI);
                system.debug('result:'+ result);
                // loop all billing in response  
                for(CLP_BulkBillingWrapper.Billing billing : result.billing){
                    // loop all individual in billling
                    system.debug(billing.individual);
                    for(CLP_BulkBillingWrapper.Individual bi : billing.individual){
                        system.debug('bi:'+bi);
                        for(Seikyusakibusho__c s : listBI){
                            // get match record request - reponse
                            checkResponseBillIndividual(listBI,bi,billing);
                        }
                    }     
                }
            } 
        }catch(Exception ex){
            this.raiseError = true;
            for(Seikyusakibusho__c s : listBI){
                if(s.manipulateStatus__c == CLP_MikataConstant.DEMAND_LINK_AWAITING){ // recheck un-response request
                    s.manipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                    // reset stop flag
                    s.StopFlg__c = null;
                    Logger__c log = createLogBillIndividual(s,null);
                    log.Content__c = ex.getMessage();
                    log.Operation__c = CLP_Logger.L_ACCESS;
                    CLP_Logger.log(log);
                }
            }
        }
        //update bill individual
        updateBillIndividual(listBI);
        CLP_Logger.flush();
    } 

    // check exist billing in response of mikata 
    private void checkResponseBillIndividual(List<Seikyusakibusho__c> listBI, CLP_BulkBillingWrapper.Individual bi , CLP_BulkBillingWrapper.Billing billing){
        for(Seikyusakibusho__c sfdcSei : listBI){
            // get match record request - reponse
            if(sfdcSei.billing_individual_number__c == bi.code 
                && billing.code == sfdcSei.Seikyusakimei__r.SeikyusakiCode__c){
                // create log for api
                Logger__c log = createLogBillIndividual(sfdcSei, bi); 
                if(String.isBlank(bi.error_code)){ // connect success                    
                    sfdcSei.IsStop__c = true;
                    sfdcSei.manipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                    // add log sucess
                    //log.Operation__c = CLP_Logger.L_SUCCESS;
                    //CLP_Logger.log(log);
                }else{ // connect failed
                    if(bi.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR)){ //INTERFACE ERROR
                        sfdcSei.manipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                        log.Operation__c = CLP_Logger.L_ACCESS;
                    }else{
                        sfdcSei.manipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                        log.Operation__c = CLP_Logger.L_OUTBOUND;
                    }
                    // reset stop flag
                    sfdcSei.StopFlg__c = null;
                    CLP_Logger.log(log);
                }
                break;
            } 
        }
    }

    // update BillIndividual data 
    private void updateBillIndividual(List<Seikyusakibusho__c> listBI){
        try{
        // update bill individual
            String[] listField = new String[]{'ManipulateStatus__c','StopFlg__c','IsStop__c','ErrorMessage__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){             
                Database.SaveResult[] resultList = Database.update(listBI,false);
                for (Integer i=0; i<resultList.size(); i++){
                    if (!resultList[i].isSuccess()) { 
                        // add log
                        Logger__c log = createLogBillIndividual(listBI[i],null);
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
                for(Seikyusakibusho__c s : listBI){
                    Logger__c log = createLogBillIndividual(s,null);
                    log.Content__c = CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION;
                    log.Operation__c = CLP_Logger.L_OUTBOUND;
                    CLP_Logger.log(log);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }

    // create log for BillIndividual
    private Logger__c createLogBillIndividual(Seikyusakibusho__c bi, CLP_BulkBillingWrapper.Individual response_i){
        // create new log
        try{
            Logger__c log = new Logger__c();                                
            log.LK_RelatedUser__c = bi.LastModifiedById;
            log.LK_BillingIndividual__c = bi.Id;
            log.Content__c = response_i != null ? response_i.error_message : '';
            log.Origin__c  = Label.CLP_BillingIndividualBulkStopBatchLabel;
            log.Request__c = (bi != null)?CLP_MikataBillingApi.getApiRequestBillIndividual(bi, CLP_MikataApi.ApiType.F_STOP):'';
            log.Response__c = (response_i != null)?CLP_MikataBillingApi.getApiResponseBillIndividual(response_i):'';
            return log;
        }catch(Exception ex){
            system.debug('Create log error:' + ex.getMessage());
            return null;
        }
    }

    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_BillingIndividualBulkStopBatchLabel);
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
                                          and ApexClass.Name = 'CLP_BillingIndividualBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        } 
    }
}