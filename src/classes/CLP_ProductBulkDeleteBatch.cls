global with sharing
 class CLP_ProductBulkDeleteBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    global String cntsql;
    
    global CLP_ProductBulkDeleteBatch() {
        
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_ProductBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            if (aajList.size() != 0) {
                return null;
            }
        }
        
        CLP_ProductBulkDeleteBatch processor = new CLP_ProductBulkDeleteBatch();
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String[] fieldsArray = new String[]{
            'Id', 'Name', 'LastModifiedById', 'ManipulateStatus__c', 'SObjectType__c', 'RecordCode__c'
        };
        String fields = String.join(fieldsArray, ',');

        this.sql = String.format('Select {0} from MikataInteBuffer__c where ManipulateStatus__c = \'\'{1}\'\' and SObjectType__c = \'\'{2}\'\' order by LastModifiedDate asc'
                , new String[]{ String.escapeSingleQuotes(fields), 
                                String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING), 
                                String.escapeSingleQuotes(CLP_MikataConstant.SOBJECT_PRODUCT) }); 

        this.cntsql = String.format('Select count() from MikataInteBuffer__c where ManipulateStatus__c = \'\'{0}\'\' and SObjectType__c = \'\'{1}\'\' '
                , new String[]{ String.escapeSingleQuotes(CLP_MikataConstant.DEMAND_LINK_AWAITING), 
                                String.escapeSingleQuotes(CLP_MikataConstant.SOBJECT_PRODUCT) });
        
        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_ProductBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            shouldStop=true;
        }
        return Database.getQueryLocator(this.sql);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            List<MikataInteBuffer__c> bufferProductsList = (List<MikataInteBuffer__c>) scope;
            List<MikataInteBuffer__c> bufferProductsListToDelete = new List<MikataInteBuffer__c>(); 
            List<MikataInteBuffer__c> bufferProductsListNotDelete = new List<MikataInteBuffer__c>(); 

            //  call to api delete
            CLP_BulkProductWrapper result = CLP_MikataProductApi.productBulkDelete(bufferProductsList);
            system.debug('@@@@CLP_ProductBulkDeleteBatch.execute.result= ' + result);

            if(result.success) {                    
                // loop Goods(product_linked) and update Product to success
                for(CLP_BulkProductWrapper.Goods p : result.goods) {
                    for(MikataInteBuffer__c bufferPrd : bufferProductsList) {                             
                        // check is exist product in response
                        if(p.item_code == bufferPrd.RecordCode__c) {
                            if (String.isBlank(p.error_message)) {
                                bufferProductsListToDelete.add(bufferPrd);
                                //createLog(bufferPrd, p, p.error_message, CLP_Logger.L_SUCCESS);    
                            
                            } else if (p.error_message.toLowerCase().contains(CLP_MikataApi.HTTP_CONNECTION_ERROR)) {
                                bufferPrd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE; 
                                bufferProductsListNotDelete.add(bufferPrd);
                                // create log
                                createLog(bufferPrd, p, p.error_message, CLP_Logger.L_ACCESS);
                            
                            } else {
                                bufferPrd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT;
                                bufferProductsListNotDelete.add(bufferPrd);   
                                // create log
                                createLog(bufferPrd, p, p.error_message, CLP_Logger.L_OUTBOUND);
                            }
                            break;
                        }
                    }
                }

            // if not (result.success)    
            } else {
                for(MikataInteBuffer__c bufferPrd : bufferProductsList){
                    bufferPrd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_FAILED_INTERFACE;
                    bufferProductsListNotDelete.add(bufferPrd);
                    // create log
                    createLog(bufferPrd, null, result.error_message, CLP_Logger.L_ACCESS);
                }                  
            }

            // Create restore point 
            Savepoint sp = Database.setSavepoint();
            try {
                //update listBuffers
                Boolean isUpdate = updateBuffers(bufferProductsListNotDelete);

                //delete listBuffers
                Boolean isDelete = deleteBuffers(bufferProductsListToDelete);

                if(isUpdate == false || isDelete == false) {   
                    Database.rollback(sp);
                    raiseError = true;
                }

            } catch(Exception ex){
                Database.rollback(sp);
                raiseError = true;
            }

        } catch(Exception ex){
            raiseError = true;
            CLP_Logger.log(ex.getMessage(), Label.CLP_ProductBulkDeleteBatchLabel);
        }
        CLP_Logger.flush();
    }
    
    // finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_ProductBulkDeleteBatchLabel);
        //system.debug('CLP_ProductBulkDeleteBatch.finish.raiseError= ' + raiseError);
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
                                          and ApexClass.Name = 'CLP_ProductBulkDeleteBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]
                                          ){
                                            System.abortJob(aaj.id);  
                                        }
                startBatch(true);  
        }
    }

    private void createLog(MikataInteBuffer__c buf, CLP_BulkProductWrapper.Goods good, String errorMsg, String operation) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = buf.LastModifiedById;
        log.Origin__c  = Label.CLP_ProductBulkDeleteBatchLabel;
        Product2 prd = new Product2(Item_Code__c = buf.RecordCode__c, StopFlg__c = CLP_MikataConstant.FLG_DELETE);
        log.Request__c = CLP_MikataProductApi.getApiRequest(prd, CLP_MikataApi.ApiType.F_DELETE); 
        log.Response__c = CLP_MikataProductApi.getApiResponse(good);
        log.Content__c = errorMsg;                        
        log.Operation__c = operation;
        CLP_Logger.log(log);
    }  

    private Boolean updateBuffers(List<MikataInteBuffer__c> listToUpdate) {
        Boolean isSuccess = false;

        String[] listField = new String[]{'ManipulateStatus__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
        && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){
            isSuccess = true;              
            if (listToUpdate != null && !listToUpdate.isEmpty()) {
                update listToUpdate;   
            }
        }
        return isSuccess;
    }

    private Boolean deleteBuffers(List<MikataInteBuffer__c> listToDelete) {
        Boolean isSuccess = false;

        if (MikataInteBuffer__c.sObjectType.getDescribe().isDeletable()) {
            isSuccess = true;
            if (listToDelete != null && !listToDelete.isEmpty()) {
                delete listToDelete; 
            } 
        }
        return isSuccess;
    }

}