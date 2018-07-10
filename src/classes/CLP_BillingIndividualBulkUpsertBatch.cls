/**
 * CLP_BillingIndividualBulkUpsertBatch.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_BillingIndividualBulkUpsertBatch
 */
global with sharing class CLP_BillingIndividualBulkUpsertBatch 
    implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
        
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    Set<ID> account_to_update; 
    
    global CLP_BillingIndividualBulkUpsertBatch() { 
        this.account_to_update = new Set<ID>(); 
    }
      
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning){
        if (checkRunning){
            List<AsyncApexJob> aajList = [SELECT Id FROM AsyncApexJob WHERE CompletedDate = NULL AND JobType = 'BatchApex'
                                          AND ApexClass.Name = 'CLP_BillingIndividualBulkUpsertBatch'
                                          AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing' OR Status = 'Holding')
                                          LIMIT 1];                          
            if (aajList.size() != 0) { return null ; }
        }
        CLP_BillingIndividualBulkUpsertBatch processor = new CLP_BillingIndividualBulkUpsertBatch();  
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{ 'Id', 'Name', 'Seikyusakimei__r.SeikyusakiCode__c', 'Seikyusakimei__r.IsIntegrated__c', 'Seikyusakimei__r.Name',
            'email__c','cc_email__c', 'address1__c', 'address2__c', 'address3__c', 'suspense_received_code__c', 'payment_method__c', 'Seikyusakimei__c', 'IsIntegrated__c',
            'building_name__c', 'city_address__c', 'pref__c', 'source_bank_account_name__c', 'LastModifiedById', 'tel__c',
            'billing_individual_number__c', 'StopFlg__c','IsStop__c', 'advances_received_code__c', 'ManipulateStatus__c', 'account_receivable_code__c', 'zip_code__c'   
        };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from Seikyusakibusho__c where Seikyusakimei__r.SeikyusakiCode__c != null and ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = null order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields), 
                                String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING) });
        
        this.cntsql = String.format('Select count() from Seikyusakibusho__c where Seikyusakimei__r.SeikyusakiCode__c != null and ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = null'
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING) });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_BillingIndividualBulkUpsertBatch'
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
                CLP_BulkBillingResponseWrapper result = CLP_MikataBillingApi.billingIndividualBulkUpsert(listBI);
                system.debug('result:'+ result);
                // loop all billing in response  
                for(CLP_BulkBillingResponseWrapper.Billing billing : result.billing){
                    // loop all individual in billling
                    for(CLP_BulkBillingResponseWrapper.Individual bi : billing.individual){
                        checkResponseBillIndividual(listBI, bi, billing);
                    }     
                }
            } 
        }catch(Exception ex){
            //system.debug('Upsert failed:'+ ex.getMessage());
            this.raiseError = true;
            for(Seikyusakibusho__c s : listBI){                    
                if(s.manipulateStatus__c == CLP_MikataConstant.DEMAND_LINK_AWAITING){ // recheck un-response request
                    s.manipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                    // reset stop flag
                    if(s.IsStop__c)
                        s.StopFlg__c = CLP_MikataConstant.FLG_STOP;
                    Logger__c log = createLogBillIndividual(s,null);
                    log.Content__c = ex.getMessage();
                    log.Operation__c = CLP_Logger.L_ACCESS;
                    CLP_Logger.log(log);                }
            }
        }
        //update bill individual
        updateBillIndividual(listBI);
        
        CLP_Logger.flush();
    } 

    // check exist billing in response of mikata 
    private void checkResponseBillIndividual(List<Seikyusakibusho__c> listBI, CLP_BulkBillingResponseWrapper.Individual bi , CLP_BulkBillingResponseWrapper.Billing billing){
        for(Seikyusakibusho__c sfdcSei : listBI){
            // get match record request - reponse
            if(sfdcSei.billing_individual_number__c == bi.code 
                && billing.code == sfdcSei.Seikyusakimei__r.SeikyusakiCode__c){
                Logger__c log = createLogBillIndividual(sfdcSei, bi); // create log for api

                if(String.isBlank(bi.error_code)){ // connect success
                    if(String.isBlank(billing.error_code) && sfdcSei.IsStop__c!=true){
                        this.account_to_update.add(sfdcSei.Seikyusakimei__c);
                    }
                    sfdcSei.IsIntegrated__c = true;
                    sfdcSei.IsStop__c = false; // case unstop
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
                    if(sfdcSei.IsStop__c)
                        sfdcSei.StopFlg__c = CLP_MikataConstant.FLG_STOP;
                    //sfdcSei.ErrorMessage__c = bi.error_message;
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
            String[] listField = new String[]{'ManipulateStatus__c', 'IsIntegrated__c','billing_individual_number__c'};
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
            system.debug('Error:'+ ex.getMessage());
            throw ex;
        }
    }

    // create log for BillIndividual
    private Logger__c createLogBillIndividual(Seikyusakibusho__c bi, CLP_BulkBillingResponseWrapper.Individual response_i){
        // create new log        
        Logger__c log = new Logger__c();                                
        log.LK_RelatedUser__c = bi.LastModifiedById;
        log.LK_BillingIndividual__c = bi.Id;
        log.Content__c = response_i != null ? response_i.error_message : '';
        log.Origin__c  = Label.CLP_BillingIndividualBulkUpsertBatchLabel;
        log.Request__c = (bi != null)?CLP_MikataBillingApi.getApiRequestBillIndividual(bi, CLP_MikataApi.ApiType.F_UPSERT):'';
        log.Response__c = (response_i != null)? getApiResponseBillIndividual(response_i):'';
        return log;
    }
    // get response by product detail object
    private String getApiResponseBillIndividual(CLP_BulkBillingResponseWrapper.Individual resp_i){
        MikataConfig__c mikataConfig = CLP_MikataConstant.mikataConfig;
        CLP_BulkBillingResponseWrapper billWrapper = new CLP_BulkBillingResponseWrapper(mikataConfig.ApiUserId__c,mikataConfig.ApiAccessKey__c, null);
        CLP_BulkBillingResponseWrapper.Billing billing = new CLP_BulkBillingResponseWrapper.Billing();
        billing.individual.add(resp_i);
        billWrapper.billing.add(billing);
        return JSON.serialize(billWrapper); 
    }

    // update related account
    private void updateRelatedAccount(){
        if(!this.account_to_update.isEmpty()){
            List<Account> accounts = [SELECT Id, IsIntegrated__c,ManipulateStatus__c FROM Account WHERE Id IN: this.account_to_update];
            for(Account acc : accounts){
                acc.IsIntegrated__c = true;
                acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
            }
            String[] listField = new String[]{'ManipulateStatus__c', 'IsIntegrated__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_ACCOUNT, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){             
                update accounts;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_BillingIndividualBulkUpsertBatchLabel);
        // raise error reset transaction
        if(this.raiseError){
            return;
        }
        //update account;
        updateRelatedAccount();
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
                                          and ApexClass.Name = 'CLP_BillingIndividualBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        } 
    }
}