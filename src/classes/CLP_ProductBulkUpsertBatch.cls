global with sharing class CLP_ProductBulkUpsertBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_ProductBulkUpsertBatch() {
        
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_ProductBulkUpsertBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            //system.debug('CLP_ProductBulkUpsertBatch.startBatch.aajList= ' + aajList);                           
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_ProductBulkUpsertBatch processor = new CLP_ProductBulkUpsertBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Don't use field Item_Number__c
        String[] fieldsArray = new String[]{
            'ProductCode', 'Item_Code__c', 'Name', 'DemandType__c', 'Unit__c', 'TaxCategory__c', 'SalesAccountTitleCode__c',
            'SalesSubAccountTitleCode__c', 'AccountReceivableSubAccountTitleCode__c', 'AdvanceReceivedSubAccountTitleCode__c',
            'LastModifiedById', 'Id', 'ErrorMessage__c', 'IsIntegrated__c', 'IsStop__c', 'ManipulateStatus__c', 'StopFlg__c'   
        };

        String fields = String.join(fieldsArray, ',');
        this.sql = String.format('Select {0} from Product2 where ManipulateStatus__c = \'\'{1}\'\' and StopFlg__c = null order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields), 
                                String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING) });
        
        this.cntsql = String.format('Select count() from Product2 where ManipulateStatus__c = \'\'{0}\'\' and StopFlg__c = null'
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING) });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_ProductBulkUpsertBatch'
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

            //  call to api upsert 
            CLP_BulkProductWrapper result = CLP_MikataProductApi.productBulkUpsert(productsList);
            //system.debug('CLP_ProductBulkUpsertBatch.execute.result= ' + result);

            if(result.success) {                    
                // loop Goods(product_linked) and update Product2 to success
                for(CLP_BulkProductWrapper.Goods p : result.goods) {
                    for(Product2 pp : productsList) {
                        // check is exist product in reponse
                        if(p.item_code == pp.Item_Code__c) {
                            if(String.isBlank(p.error_message)) {
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
                                //pp.Item_Number__c = String.valueOf(p.item_number);
                                pp.IsIntegrated__c = true;
                                pp.IsStop__c = false;   // for case unstop
                                //createLog(pp, p, p.error_message, CLP_Logger.L_SUCCESS);

                            } else if(p.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR)) { 
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                                // create log
                                createLog(pp, p, p.error_message, CLP_Logger.L_ACCESS);
                                // restore stop flag if cannot "unstop" product
                                if (pp.IsStop__c) {
                                    pp.StopFlg__c = CLP_MikataConstant.FLG_STOP;
                                } 

                            } else {
                                pp.ErrorMessage__c = null;
                                pp.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                                // create log
                                createLog(pp, p, p.error_message, CLP_Logger.L_OUTBOUND);
                                // restore stop flag if cannot "unstop" product
                                if (pp.IsStop__c) {
                                    pp.StopFlg__c = CLP_MikataConstant.FLG_STOP;
                                }
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
                    // restore stop flag if cannot "unstop" product
                    if (pp.IsStop__c) {
                        pp.StopFlg__c = CLP_MikataConstant.FLG_STOP;
                    }
                }
            }

            // update products 
            updateProducts(productsList);

        } catch(Exception ex){
            this.raiseError = true;
            CLP_Logger.log(ex.getMessage(), Label.CLP_ProductBulkUpsertBatchLabel);
        }
        CLP_Logger.flush();
    }
    
    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_ProductBulkUpsertBatchLabel);
        //system.debug('CLP_ProductBulkUpsertBatch.finish.raiseError= ' + raiseError);
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
                                          and ApexClass.Name = 'CLP_ProductBulkUpsertBatch'
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
        log.Origin__c  = Label.CLP_ProductBulkUpsertBatchLabel;
        if (prd.IsStop__c) {
            log.Request__c = CLP_MikataProductApi.getApiRequest(prd, CLP_MikataApi.ApiType.F_UNSTOP); 
        } else {
            log.Request__c = CLP_MikataProductApi.getApiRequest(prd, CLP_MikataApi.ApiType.F_UPSERT);   
        }
        log.Response__c = CLP_MikataProductApi.getApiResponse(good);
        log.Content__c = errorMsg;                        
        log.Operation__c = operation;
        CLP_Logger.log(log);
    }

    private void updateProducts(List<Product2> productsList) {
        String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'IsIntegrated__c', 'StopFlg__c', 'IsStop__c'};
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