/**
 * CLP_SyncProductCC.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: 
 */
   global with sharing class CLP_SyncProductCC {
   public CLP_SyncProductCC() {
        
   }

   @RemoteAction
   webservice static String registerMikata(List<Id> recordIds){
      CLP_JSONResult jsonRes;
      try {     
         // Check config
         CLP_MikataApi mikataConfig = new CLP_MikataApi();
         //
         List<Product2> listProducts = getProductRecords(recordIds);
         List<Product2> listProductsChoosen = new List<Product2>();
         List<Product2> listFailed = new List<Product2>();
         Integer countFailed = 0;

         // Fill error when clicked a product:
         // - already Stop Mikata
         // Not choose a product:
         // - already linked with success to Mikata
         for (Product2 prd : listProducts) {
            if (prd.IsIntegrated__c && prd.ManipulateStatus__c == CLP_MikataConstant.DEMAND_LINK_SUCCESS) {
               continue;

            } else {
               prd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
               prd.ErrorMessage__c = '';
               listProductsChoosen.add(prd);
            }
         }

         // update status before run batch
         String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'StopFlg__c'};
         if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
         && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){
            Savepoint sp ;
            if (!Test.isRunningTest()) {
               sp = Database.setSavepoint();    
            }
            Database.SaveResult[] saveResults = Database.update(listProductsChoosen, false);
            for (Integer i=0; i<saveResults.size(); i++){
               if (!saveResults[i].isSuccess()) {
                  String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                  listProductsChoosen[i].ErrorMessage__c = totalErrorMsg;  
                  listProductsChoosen[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                  listFailed.add(listProductsChoosen[i]);
                  countFailed++;
               }
            }
            if (!listFailed.isEmpty()) {
               try {
                  update listFailed;   

               } catch (DmlException dmlEx) {
                  if (!Test.isRunningTest()) {
                     Database.rollback(sp);
                  }
                  throw dmlEx;
               }
            } 
         }

         Id jobId = null;
         jobId = CLP_ProductBulkUpsertBatch.startBatch(true);
         if (jobId == null) {
            //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
            jsonRes = new CLP_JSONResult(true, null, null);
            return JSON.serialize(jsonRes);  

         } else {
            if (countFailed > 0) {     // show list of product error (cannot call to Mikata)
               String alertMessage = buildAlertMessage(countFailed);
               jsonRes = new CLP_JSONResult(true, null, alertMessage); 
               return JSON.serialize(jsonRes);
            }
            jsonRes = new CLP_JSONResult(true, null, null);
            return JSON.serialize(jsonRes);
         }   
        
      } catch(Exception ex){
         System.debug('CLP_SyncProductCC.registerMikata.ex= ' + ex.getMessage());
         jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
         return JSON.serialize(jsonRes); 
      }
   }

   @RemoteAction
   webservice static String stopMikata(List<Id> recordIds){
      CLP_JSONResult jsonRes;
      try {
         // Check config
         CLP_MikataApi mikataConfig = new CLP_MikataApi();
         //       
         List<Product2> listProducts = getProductRecords(recordIds);
         List<Product2> listFailed = new List<Product2>();
         Integer countFailed = 0;

         // Fill error when clicked a product:
         //  - Not yet register Mikata
         //  - already Stop Mikata
         List<Product2> listProductsBackup = setBackupList(listProducts);
         for (Product2 prd : listProducts) {
            prd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
            prd.StopFlg__c = CLP_MikataConstant.FLG_STOP;
            prd.ErrorMessage__c = '';
         }

         // update status before run batch
         String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'StopFlg__c'};
         if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
         && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){       
            Savepoint sp; 
            if (!Test.isRunningTest()) {
               sp = Database.setSavepoint();    
            }
            Database.SaveResult[] saveResults = Database.update(listProducts, false);
            for (Integer i=0; i<saveResults.size(); i++){
               if (!saveResults[i].isSuccess()) {
                  listProducts[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
                  listProducts[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                  listProducts[i].StopFlg__c = listProductsBackup[i].StopFlg__c;
                  listFailed.add(listProducts[i]);
                  countFailed++;
               }  
            }
            if (!listFailed.isEmpty()) {
               try {
                  update listFailed;   

               } catch (DmlException dmlEx) {
                  if (!Test.isRunningTest()) {
                     Database.rollback(sp);
                  }
                  throw dmlEx;
               }
            } 
         }

         Id jobId = null; 
         jobId = CLP_ProductBulkStopBatch.startBatch(true);
         if (jobId == null) {
            //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
            jsonRes = new CLP_JSONResult(true, null, null);
            return JSON.serialize(jsonRes);

         } else {
            if (countFailed > 0) {     // show list of product error (cannot call to Mikata)
               String alertMessage = buildAlertMessage(countFailed);
               jsonRes = new CLP_JSONResult(true, null, alertMessage); 
               return JSON.serialize(jsonRes);
            }
            jsonRes = new CLP_JSONResult(true, null, null);
            return JSON.serialize(jsonRes);
         }
           
      } catch(Exception ex){
         System.debug('CLP_SyncProductCC.stopMikata.ex= ' + ex.getMessage());
         jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
         return JSON.serialize(jsonRes);       
      }
   }

   @RemoteAction
   webservice static String unstopMikata(List<Id> recordIds) {
      CLP_JSONResult jsonRes;
      try {
         // Check config
         CLP_MikataApi mikataConfig = new CLP_MikataApi();
         //       
         List<Product2> listProducts = getProductRecords(recordIds);
         Integer countFailed = 0;

         // Fill error when on a product:
         //  - Not yet register Mikata
         //  - Register Mikata but not yet Stop
         for (Product2 prd : listProducts) {
            if (!prd.IsIntegrated__c) {
               prd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
               prd.ErrorMessage__c = 'エラー204:対象レコードは未連携です。';
               countFailed++;
            
            } else if (prd.IsIntegrated__c && !prd.IsStop__c) {
               prd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
               prd.ErrorMessage__c = 'エラー202:対象レコードは停止されていません。';
               countFailed++;
            
            } else if (prd.IsIntegrated__c && prd.IsStop__c){
               prd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
               prd.StopFlg__c = null;
               prd.ErrorMessage__c = '';
            }
         }
            
         // update status before run batch
         String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'StopFlg__c'};
         if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
         && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){           
            Savepoint sp;
            if (!Test.isRunningTest()) {
               sp = Database.setSavepoint();    
            }
            try {
               update listProducts;   

            } catch (DmlException dmlEx) {
               if (!Test.isRunningTest()) {
                  Database.rollback(sp);
               }
               throw dmlEx;
            }
         }

         Id jobId = null;
         jobId = CLP_ProductBulkUpsertBatch.startBatch(true);
         if (jobId == null){
            //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
            jsonRes = new CLP_JSONResult(true, null, null);
            return JSON.serialize(jsonRes);

         } else {
            if (countFailed > 0) {     // show list of product error (cannot call to Mikata)
               String alertMessage = buildAlertMessage(countFailed);
               jsonRes = new CLP_JSONResult(true, null, alertMessage); 
               return JSON.serialize(jsonRes);
            }
            jsonRes = new CLP_JSONResult(true, null, null);
            return JSON.serialize(jsonRes);
         }

      } catch(Exception ex){
         System.debug('CLP_SyncProductCC.unstopMikata.ex= ' + ex.getMessage());
         jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
         return JSON.serialize(jsonRes);
      }
   }    

   private static List<Product2> getProductRecords(List<Id> recordIds){
      try {
         List<Product2> prds = [Select Id, ProductCode, IsIntegrated__c, IsStop__c, ManipulateStatus__c, ErrorMessage__c, StopFlg__c
                                From Product2
                                Where Id In :recordIds];
        
         if (prds != null && !prds.isEmpty()){
            return prds;
         }
         return null;

      } catch(Exception ex){
         System.debug('CLP_SyncProductCC.getProductRecords.ex= ' + ex.getMessage());
         return null;
      }
   }

   private static String buildAlertMessage(Integer countFailed) {
      return 'エラー：計 ' + countFailed + ' 件の入力不備があります。';  
   }

   private static List<Product2> setBackupList(List<Product2> listPrd) {
      List<Product2> tempList = new List<Product2>();
      for (Product2 prd : listPrd) {
         Product2 tempPrd = new Product2();
         tempPrd.StopFlg__c = prd.StopFlg__c;
         tempPrd.ProductCode = prd.ProductCode;
         tempList.add(tempPrd);  
      }
      return tempList;
   }

   private static String getErrorValidationMessage(List<Database.Error> listErr) {
      String msg = '';
      Integer count = 0;
      for (Database.Error err : listErr) {
         count++;
         msg += err.getMessage() + (count == listErr.size() ? '' : '\n');
      } 
      return msg;
   }
}