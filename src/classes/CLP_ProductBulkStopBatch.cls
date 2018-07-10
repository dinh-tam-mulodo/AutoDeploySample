global with sharing class CLP_ProductBulkStopBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_ProductBulkStopBatch() {
        
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_ProductBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_ProductBulkStopBatch processor = new CLP_ProductBulkStopBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{
            'Id', 'StopFlg__c', 'LastModifiedById', 'ErrorMessage__c', 'IsIntegrated__c', 'IsStop__c', 'ManipulateStatus__c', 'Item_Code__c'
        };
        String fields = String.join(fieldsArray, ',');

        this.sql = String.format('Select {0} from Product2 where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = \'\'{2}\'\' and IsIntegrated__c = true order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields), 
                                String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING), 
                                String.escapeSingleQuotes(CLP_MikataConstant.FLG_STOP) }); 

        this.cntsql = String.format('Select count() from Product2 where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = \'\'{1}\'\' and IsIntegrated__c = true'
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING), 
                                String.escapeSingleQuotes(CLP_MikataConstant.FLG_STOP) });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_ProductBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            List<Product2> productsList = (List<Product2>) scope;

            //  call to api stop 
            CLP_BulkProductWrapper result = CLP_MikataProductApi.productBulkStop(productsList);

            if(result.success) {                    
                // loop Goods(product_linked) and update Product to success
                for(CLP_BulkProductWrapper.Goods p : result.goods) {
                    for(Product2 pp : productsList) {
                        // check is exist product in response
                        if(p.item_code == pp.Item_Code__c) {
                            if(String.isBlank(p.error_message)) {
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                                pp.IsStop__c = true; 
                                // IsIntegrated__c still = true
                                // StopFlg__c still = '0'
                                //createLog(pp, p, p.error_message, CLP_Logger.L_SUCCESS);
                            
                            } else if(p.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR)) {
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                                // create log
                                createLog(pp, p, p.error_message, CLP_Logger.L_ACCESS);
                                // reset stop flag
                                pp.StopFlg__c = null;
                                

                            } else {
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                                // create log
                                createLog(pp, p, p.error_message, CLP_Logger.L_OUTBOUND);
                                // reset stop flag
                                pp.StopFlg__c = null;
                            }
                            break;
                        }
                    }
                }

            // if not (result.success)    
            } else {
                for(Product2 pp : productsList) {
                    pp.ErrorMessage__c = null;
                    pp.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                    // create log
                    createLog(pp, null, result.error_message, CLP_Logger.L_ACCESS);
                     // reset stop flag
                    pp.StopFlg__c = null;
                }                  
            }

            // update products
            updateProducts(productsList);


        } catch(Exception ex){
            this.raiseError = true;
            CLP_Logger.log(ex.getMessage(), Label.CLP_ProductBulkStopBatchLabel);
        }
        CLP_Logger.flush();
    }
    
    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_ProductBulkStopBatchLabel);
        //system.debug('CLP_ProductBulkStopBatch.finish.raiseError= ' + raiseError);
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
                                          and ApexClass.Name = 'CLP_ProductBulkStopBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        }
    }  

    private void createLog(Product2 prd, CLP_BulkProductWrapper.Goods good, String errorMsg, String operation) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = prd.LastModifiedById;
        log.LK_Product__c = prd.Id;
        log.Origin__c  = Label.CLP_ProductBulkStopBatchLabel;
        log.Request__c = CLP_MikataProductApi.getApiRequest(prd, CLP_MikataApi.ApiType.F_STOP);   
        log.Response__c = CLP_MikataProductApi.getApiResponse(good);
        log.Content__c = errorMsg;                        
        log.Operation__c = operation;
        CLP_Logger.log(log);
    }

    private void updateProducts(List<Product2> productsList) {
        String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'IsStop__c', 'StopFlg__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
        && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){             
            Database.SaveResult[] saveResults = Database.update(productsList, false);
            for (Integer i=0; i<saveResults.size(); i++){
                if (!saveResults[i].isSuccess()) {
                    String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                    createLog(productsList[i], null, totalErrorMsg, CLP_Logger.L_OUTBOUND);
                }
            } 
        
        } else {
            this.raiseError = true;
            for(Product2 prd : productsList) {
                createLog(prd, null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND);
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