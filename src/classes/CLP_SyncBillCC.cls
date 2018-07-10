global with sharing class CLP_SyncBillCC {
    public CLP_SyncBillCC() {
        
    }

    @RemoteAction
    webservice static String upsertBillMikata(List<Id> recordIds){
        CLP_JSONResult jsonRes;
        try {
            // Check config
            CLP_MikataApi mikataConfig = new CLP_MikataApi();
            //
            List<Bill__c> listBills = getBillRecords(recordIds);
            List<Bill__c> listBillsChoosen = new List<Bill__c>();
            List<Bill__c> listFailed = new List<Bill__c>();
            Integer countFailed = 0;

            for (Bill__c bill : listBills) {
                if (bill.IsIntegrated__c && !bill.IsStop__c && bill.manipulateStatus__c == CLP_MikataConstant.DEMAND_LINK_SUCCESS) {
                    continue;

                } else {
                    bill.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
                    bill.ErrorMessage__c = '';
                    //bill.ExternalKey__c = setExternalKey(bill);
                    listBillsChoosen.add(bill);
                }
            }

            String[] listField = new String[]{'manipulateStatus__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
            && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)) {
                Savepoint sp;
                if (!Test.isRunningTest()) {
                    sp = Database.setSavepoint();    
                }
                Database.SaveResult[] saveResults = Database.update(listBillsChoosen, false);
                for (Integer i=0; i<saveResults.size(); i++){
                    if (!saveResults[i].isSuccess()) {
                        listBillsChoosen[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
                        listBillsChoosen[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        //listBillsChoosen[i].ExternalKey__c = null;
                        listFailed.add(listBillsChoosen[i]);
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
            jobId = CLP_BillBulkUpsertBatch.startBatch(true);
            if (jobId == null){
                //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes);  

            } else {
                if (countFailed > 0) {      // show list of payment method error (cannot call to Mikata)
                    String alertMessage = buildAlertMessage(countFailed);
                    jsonRes = new CLP_JSONResult(true, null, alertMessage); 
                    return JSON.serialize(jsonRes);
                }
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes);
            } 

        } catch(Exception ex){
            System.debug('CLP_SyncBillCC.upsertBillMikata.ex= ' + ex.getMessage());
            jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
            return JSON.serialize(jsonRes); 
        }
    }

    @RemoteAction
    webservice static String stopBillMikata(List<Id> recordIds){
        CLP_JSONResult jsonRes;
        try {    
            // Check config
            CLP_MikataApi mikataConfig = new CLP_MikataApi();
            // 
            List<Bill__c> listBills = getBillRecords(recordIds);
            List<Bill__c> listFailed = new List<Bill__c>();
            Integer countFailed = 0;

            // Fill error when clicked a bill
            //  - Not yet register Mikata
            //  - already Stop Mikata
            List<Bill__c> listBillsBackup = setBackupList(listBills);
            for (Bill__c bill : listBills) {
                bill.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
                bill.StopFlg__c = CLP_MikataConstant.FLG_STOP;  
                bill.ErrorMessage__c = '';
                //bill.ExternalKey__c = setExternalKey(bill);
            }

            // update status before run batch
            String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'StopFlg__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
            && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){   
                Savepoint sp;
                if (!Test.isRunningTest()) {
                    sp = Database.setSavepoint();    
                }
                Database.SaveResult[] saveResults = Database.update(listBills, false);
                for (Integer i=0; i<saveResults.size(); i++){
                    if (!saveResults[i].isSuccess()) {
                        listBills[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
                        listBills[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        listBills[i].StopFlg__c = listBillsBackup[i].StopFlg__c;
                        //listBills[i].ExternalKey__c = null;
                        listFailed.add(listBills[i]);
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
            jobId = CLP_BillBulkStopBatch.startBatch(true);
            if (jobId == null) {
                //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes); 

            } else {
                if (countFailed > 0) {      // show list of payment method error (cannot call to Mikata)
                    String alertMessage = buildAlertMessage(countFailed);
                    jsonRes = new CLP_JSONResult(true, null, alertMessage); 
                    return JSON.serialize(jsonRes);
                }
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes);
            }
          
        } catch(Exception ex){
            System.debug('CLP_SyncBillCC.stopBillMikata.ex= ' + ex.getMessage());
            jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
            return JSON.serialize(jsonRes);
        }
    }

    @RemoteAction
    webservice static String unstopBillMikata(List<Id> recordIds){
        CLP_JSONResult jsonRes;
        try { 
            // Check config
            CLP_MikataApi mikataConfig = new CLP_MikataApi();
            //    
            List<Bill__c> listBills = getBillRecords(recordIds);
            List<Bill__c> listFailed = new List<Bill__c>();
            Integer countFailed = 0;

            // Fill error when clicked a bill
            //  - Not yet register Mikata
            //  - not yet Stop Mikata
            List<Bill__c> listBillsBackup = setBackupList(listBills);
            for (Bill__c bill : listBills) {
                if (bill.IsIntegrated__c && !bill.IsStop__c){
                    bill.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                    bill.ErrorMessage__c = 'エラー202:対象レコードは停止されていません。';
                    countFailed++;

                } else if (bill.IsIntegrated__c && bill.IsStop__c){
                    bill.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
                    bill.StopFlg__c = null;  
                    bill.ErrorMessage__c = ''; 
                    //bill.ExternalKey__c = setExternalKey(bill);  
                }
            }

            // update status before run batch
            String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'StopFlg__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
            && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){   
                Savepoint sp;
                if (!Test.isRunningTest()) {
                    sp = Database.setSavepoint();    
                }
                Database.SaveResult[] saveResults = Database.update(listBills, false);
                for (Integer i=0; i<saveResults.size(); i++){
                    if (!saveResults[i].isSuccess()) {
                        listBills[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
                        listBills[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        listBills[i].StopFlg__c = listBillsBackup[i].StopFlg__c;
                        //listBills[i].ExternalKey__c = null;
                        listFailed.add(listBills[i]);
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
            jobId = CLP_BillBulkUpsertBatch.startBatch(true);
            if (jobId == null) {
                //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes); 

            } else {
                if (countFailed > 0) {      // show list of payment method error (cannot call to Mikata)
                    String alertMessage = buildAlertMessage(countFailed);
                    jsonRes = new CLP_JSONResult(true, null, alertMessage); 
                    return JSON.serialize(jsonRes);
                }
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes);
            }
          
        } catch(Exception ex){
            System.debug('CLP_SyncBillCC.unstopBillMikata.ex= ' + ex.getMessage());
            jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
            return JSON.serialize(jsonRes);
        }
    }

    @RemoteAction
    webservice static String getBillUrl(List<Id> recordIds){
        CLP_JSONResult jsonRes;
        try {
            // Check config
            CLP_MikataApi mikataConfig = new CLP_MikataApi();
            //
            List<Bill__c> listBills = getBillRecords(recordIds);
            List<Bill__c> listFailed = new List<Bill__c>();

            for (Bill__c bill : listBills) {
                bill.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
                bill.ErrorMessage__c = '';
                //bill.ExternalKey__c = setExternalKey(bill); 
            }

            // update status before run batch
            String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
            && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){   
                Savepoint sp;
                if (!Test.isRunningTest()) {
                    sp = Database.setSavepoint();    
                }
                Database.SaveResult[] saveResults = Database.update(listBills, false);
                for (Integer i=0; i<saveResults.size(); i++){
                    if (!saveResults[i].isSuccess()) {
                        listBills[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
                        listBills[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        //listBills[i].ExternalKey__c = null;
                        listFailed.add(listBills[i]);
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
            jobId = CLP_BillBulkGetUrlBatch.startBatch(true);
            if (jobId == null){
                //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes);  

            } else {
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes);
            } 

        } catch(Exception ex){
            System.debug('CLP_SyncBillCC.getBillUrl.ex= ' + ex.getMessage());
            jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
            return JSON.serialize(jsonRes); 
        }
    }

    @RemoteAction
    webservice static String referenceBillFromMikata(String billNumber) {
        CLP_JSONResult jsonRes;
        try {
            // Check config
            CLP_MikataApi mikataConfig = new CLP_MikataApi();
            //
            Date lastRefDate = setLastReferenceDate();      
            List<LastReference__c> lastRefList = [SELECT Id, LastModifiedById, LastReferenceDate__c FROM LastReference__c];

            // LastReference__c object must exist only one record
            if (lastRefList == null || lastRefList.isEmpty()) {
                // Create new last reference record
                LastReference__c newLastRef = new LastReference__c();
                newLastRef.LastReferenceDate__c = lastRefDate;
                String[] listField = new String[] {'LastReferenceDate__c'};
                if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
                && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)) {             
                    Savepoint sp;
                    if (!Test.isRunningTest()) {
                        sp = Database.setSavepoint();    
                    }
                    try {
                        insert newLastRef;  
                        
                    } catch (DmlException dmlEx) {
                        if (!Test.isRunningTest()) {
                            Database.rollback(sp);
                        }
                        throw dmlEx;
                    }   
                }  
                
            } else {
                LastReference__c lastRef = lastRefList.get(0);
                if (lastRef.LastReferenceDate__c == null) {
                    lastRef.LastReferenceDate__c = lastRefDate; 
                    String[] listField = new String[] {'LastReferenceDate__c'};
                    if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
                    && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)) {             
                        Savepoint sp;
                        if (!Test.isRunningTest()) {
                            sp = Database.setSavepoint();    
                        }
                        try {
                            update lastRefList; 
                            
                        } catch (DmlException dmlEx) {
                            if (!Test.isRunningTest()) {
                                Database.rollback(sp);
                            }
                            throw dmlEx;
                        }    
                    } 
                }
            }

            // If billNumber != null --> Action "Get newest data bill in detail page" --> set AwaitingGetNewBill__c = true
            // update bill status AwaitingGetNewBill
            if (String.isNotBlank(billNumber)) {
                List<Bill__c> bills = [SELECT Id, AwaitingGetNewBill__c, number__c
                                       FROM Bill__c
                                       WHERE number__c = :billNumber];
                if (bills != null && !bills.isEmpty()) {
                    Bill__c bill = bills.get(0);
                    bill.AwaitingGetNewBill__c = true;
                    String[] listField = new String[] {'AwaitingGetNewBill__c'};
                    if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
                    && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)) {             
                        Savepoint sp;
                        if (!Test.isRunningTest()) {
                            sp = Database.setSavepoint();    
                        }
                        try {
                            update bills; 
                            
                        } catch (DmlException dmlEx) {
                            if (!Test.isRunningTest()) {
                                Database.rollback(sp);
                            }
                            throw dmlEx;
                        }    
                    } 
                }                         
            } 

            Id jobId = null;
            jobId = CLP_BillBulkReferenceMikataBatch.startBatch(true, billNumber, 0);
            if (jobId == null){
                //jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes);  

            } else {
                jsonRes = new CLP_JSONResult(true, null, null);
                return JSON.serialize(jsonRes);
            } 

        } catch(Exception ex){
            System.debug('CLP_SyncBillCC.referenceBillFromMikata.ex= ' + ex.getMessage());
            jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
            return JSON.serialize(jsonRes); 
        }
    }

    private static List<Bill__c> getBillRecords(List<Id> recordIds){
        try {
            List<Bill__c> bills = [SELECT Id, Name, IsIntegrated__c, IsStop__c, StopFlg__c, ManipulateStatus__c, number__c,
                                          AccountId__c, AccountId__r.SeikyusakiCode__c, AccountId__r.IsIntegrated__c, AccountId__r.IsStop__c, 
                                          Billing_Individual__c, Billing_Individual__r.IsIntegrated__c, Billing_Individual__r.IsStop__c
                                          //ExternalKey__c
                                   FROM Bill__c
                                   WHERE Id IN :recordIds];
            if (bills != null && !bills.isEmpty()){
                return bills;
            }
            return null;

        } catch(Exception ex){
            System.debug('CLP_SyncBillCC.getBillRecords.ex= ' + ex.getMessage());
            return null;
        }
    }

    private static Date setLastReferenceDate() {
        return Date.today();
    }

    private static String buildAlertMessage(Integer countFailed) {
        return 'エラー：計 ' + countFailed + ' 件の入力不備があります。';
    }

    private static List<Bill__c> setBackupList(List<Bill__c> listBills) {
        List<Bill__c> tempList = new List<Bill__c>();
        for (Bill__c bill : listBills) {
            Bill__c tempBill = new Bill__c();
            tempBill.StopFlg__c = bill.StopFlg__c;
            tempBill.number__c = bill.number__c;
            tempList.add(tempBill);  
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

    /*private static String setExternalKey(Bill__c bill) {
        if (String.isNotBlank(bill.ExternalKey__c)) {
            return bill.ExternalKey__c;
        }   
        return (bill.AccountId__r.SeikyusakiCode__c + '_' + bill.number__c); 
    }*/
}