global with sharing class Test_BillBulkReferenceMikataBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    //global String cntsql;
    global String billNumber;
    global Integer indexPaging;
    private Integer totalPageCountMikata = null;
    private List<LastReference__c> lastReferenceList;
    
    global Test_BillBulkReferenceMikataBatch() {
    }

    global Test_BillBulkReferenceMikataBatch(String varBillNumber, Integer varIndexPage) {
        /*
            varBillNumber == null --> click reference button on Bill List view or by a scheduled batch
            varBillNumber != null --> click reference button on Bill detail page
            Don't update last reference date when click reference button on Bill detail page <=> varBillNumber != null
        */
        this.billNumber = varBillNumber;
        this.indexPaging = varIndexPage;
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning, String varBillNumber, Integer varIndexPage) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'Test_BillBulkReferenceMikataBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            if (aajList.size() != 0) {
                return null;
            }
        }
        String billNumber = String.isBlank(varBillNumber) ? null : varBillNumber; 
        Integer indexPage = varIndexPage == null ? 0 : varIndexPage;
        Test_BillBulkReferenceMikataBatch processor = new Test_BillBulkReferenceMikataBatch(billNumber, indexPage);
        Id batchprocessid=null;   
        batchprocessid = Database.executeBatch(processor, 50);  
        return batchprocessid;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.sql = 'Select Id, LastModifiedById, LastReferenceDate__c from LastReference__c';
        //this.cntsql = 'Select count() from LastReference__c';

        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'Test_BillBulkReferenceMikataBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            this.shouldStop = true;
        }
        return Database.getQueryLocator(this.sql);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try {
            // In fact lastRefList must exist only one LastReference__c record
            List<LastReference__c> lastRefList = (List<LastReference__c>) scope;
            this.lastReferenceList = lastRefList;
            Map<String, CLP_BulkBillWrapper.Bill> billsMikataMap = new Map<String, CLP_BulkBillWrapper.Bill>();

            // Check if exist any scheduled batch that get bill --> abort it
            checkScheduledBatch();

            //  Call to api upsert 
            CLP_BulkBillWrapper result = CLP_MikataBillApi.referenceFromMikata(lastRefList, this.billNumber, this.indexPaging);

            if (result.success) {
                // Not found any bill returned from Mikata --> go finish
                if (result.bill == null || result.bill.isEmpty() || result.total_page_count == null) {
                    this.totalPageCountMikata = null;
                    return;
                } 
                this.totalPageCountMikata = result.total_page_count;
                for (CLP_BulkBillWrapper.Bill aBill : result.bill) {
                    if (String.isBlank(aBill.error_message)) {
                        billsMikataMap.put(aBill.number_z, aBill);
                        createLog(lastRefList[0], aBill, aBill.error_message, CLP_Logger.L_SUCCESS);
                    
                    } else {
                        createLog(lastRefList[0], aBill, aBill.error_message, CLP_Logger.L_OUTBOUND);
                    }
                }

            // if(!result.success)
            } else { 
                this.raiseError = true;
                // if error maintaince --> rerun batch after 1h
                if (result.error_message.contains('Maintenance')) {
                    setScheduleBatch();

                } else {
                    createLog(lastRefList[0], null, result.error_message, CLP_Logger.L_ACCESS);   
                }
            }

            // If all bill from Mikata is error --> go finish
            if (billsMikataMap == null || billsMikataMap.isEmpty()) {
                CLP_Logger.flush();
                return;
            }

            /* ------------------------------ Start main process ------------------------------ */ 
            // Query bill__c in SFDC database
            List<Bill__c> billsSfdc = getBillRecords(billsMikataMap.keySet());
            
            // If not found any record in SFDC to update --> insert all bill returned from Mikata
            if (billsSfdc == null) {
                insertBillsAndBillsDetail(billsMikataMap);
            
            // Else, insert new bill from Mikata and update existing bill in SFDC
            } else {
                Set<String> billNumberToInsertSet = new Set<String>(billsMikataMap.keySet());
                Map<String, Bill__c> billsSfdcToUpdateMap = new Map<String, Bill__c>();

                for (Bill__c billSfdc : billsSfdc) {
                    if (billsMikataMap.keySet().contains(billSfdc.number__c)) {
                        billsSfdcToUpdateMap.put(billSfdc.number__c, billSfdc);
                        billNumberToInsertSet.remove(billSfdc.number__c);
                    }     
                }

                // Insert some new bill returned from Mikata
                if (billNumberToInsertSet != null && !billNumberToInsertSet.isEmpty()) {
                    Map<String, CLP_BulkBillWrapper.Bill> billsMikataSubMap = new Map<String, CLP_BulkBillWrapper.Bill>();
                    for (String billNumber : billNumberToInsertSet) {
                        CLP_BulkBillWrapper.Bill billMikata = billsMikataMap.get(billNumber);
                        billsMikataSubMap.put(billNumber, billMikata);               
                    }
                    insertBillsAndBillsDetail(billsMikataSubMap);
                    //
                    if (this.raiseError) {
                        CLP_Logger.flush();
                        return;   
                    }
                }

                // Update newest data from mikata of existing bill in SFDC
                if (billsSfdcToUpdateMap != null && !billsSfdcToUpdateMap.isEmpty()) {
                    updateBillsAndBillsDetail(billsSfdcToUpdateMap, billsMikataMap);
                }
            }
            /* ------------------------------ End main process ------------------------------ */ 

        } catch(Exception ex) {
            this.raiseError = true;
            System.debug('Test_BillBulkReferenceMikataBatch.execute.exception= ' + ex.getMessage());
            CLP_Logger.log(ex.getMessage(), Label.CLP_BillBulkReferenceMikataBatchLabel);
        }
        CLP_Logger.flush();
    }
    
    // Finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_BillBulkReferenceMikataBatchLabel);
        if(this.raiseError){
            return;
        }

        // If more than 2 job started at the same time ==> abort all job
        if(this.shouldStop){
            for(AsyncApexJob aaj : [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'Test_BillBulkReferenceMikataBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]) {
                                          
                System.abortJob(aaj.id);  
            }
            startBatch(true, this.billNumber, 0);  
        }

        // Pagination
        if (this.totalPageCountMikata != null && this.totalPageCountMikata > 0) {
            Integer endIndexPaging = this.totalPageCountMikata - 1;
            Boolean isStopPaging = (this.indexPaging == endIndexPaging) ? true : false;

            if (isStopPaging) {
                updateLastReference(this.lastReferenceList);  

            } else {
                if(!Test.isRunningTest()) {
                    startBatch(true, this.billNumber, this.indexPaging + 1);
                } 
            }
        }
    }  

    private void insertBillsAndBillsDetail(Map<String, CLP_BulkBillWrapper.Bill> billsMikataMap) {
        List<Bill__c> billsToInsert = new List<Bill__c>(); 
        List<BillDetail__c> billsDetailToInsert = new List<BillDetail__c>(); 
        Map<String, List<BillDetail__c>> billsDetailByBillCodeMap = new Map<String, List<BillDetail__c>>();  
        //
        for (String billNumber : billsMikataMap.keySet()) {
            CLP_BulkBillWrapper.Bill billMikata = billsMikataMap.get(billNumber);
            Bill__c billSfdc = new Bill__c();
            mappingDataBill(billSfdc, billMikata, true); 
            billsToInsert.add(billSfdc); 

            // loop list bill_detail in billMikata
            if (billMikata.bill_detail != null && !billMikata.bill_detail.isEmpty()) {          
                List<BillDetail__c> tempBillsDetail = new List<BillDetail__c>();
                for (CLP_BulkBillWrapper.BillDetail billDetailMikata : billMikata.bill_detail) {
                    BillDetail__c billDetailSfdc = new BillDetail__c();
                    mappingDataBillDetail(billDetailSfdc, billDetailMikata);
                    tempBillsDetail.add(billDetailSfdc);
                }
                billsDetailByBillCodeMap.put(billMikata.number_z, tempBillsDetail);
            }
        }

        // Insert bill
        if (billsToInsert != null && !billsToInsert.isEmpty()) {
            doInsertBills(billsToInsert, true);
        }

        // Insert bill detail
        if (billsDetailByBillCodeMap != null && !billsDetailByBillCodeMap.isEmpty()) {
            for (Bill__c bi : billsToInsert) {
                if (billsDetailByBillCodeMap.keySet().contains(bi.number__c)) {
                    List<BillDetail__c> tempList = billsDetailByBillCodeMap.get(bi.number__c);
                    for (BillDetail__c bidet : tempList) {
                        bidet.BillId__c = bi.Id; 
                        billsDetailToInsert.add(bidet);
                    }
                }    
            } 
            if (billsDetailToInsert != null && !billsDetailToInsert.isEmpty()) {
                doInsertBillsDetail(billsDetailToInsert);
            }    
        }
    }

    private void updateBillsAndBillsDetail(Map<String, Bill__c> billsSfdcMap, Map<String, CLP_BulkBillWrapper.Bill> billsMikataMap) {
        List<Bill__c> billsToUpdate = new List<Bill__c>(); 
        List<BillDetail__c> billsDetailToUpdate = new List<BillDetail__c>();
        //
        for (String billNumber : billsSfdcMap.keySet()) {
            Bill__c billSfdc = billsSfdcMap.get(billNumber);
            CLP_BulkBillWrapper.Bill billMikata = billsMikataMap.get(billNumber);
            mappingDataBill(billSfdc, billMikata, false); 
            billsToUpdate.add(billSfdc);

            // loop list bill_detail in billMikata
            if (billMikata.bill_detail != null && !billMikata.bill_detail.isEmpty()) {       
                List<BillDetail__c> tempBillsDetail = billSfdc.BillDetails__r;
                for (Integer i=0; i<billMikata.bill_detail.size(); i++) {
                    CLP_BulkBillWrapper.BillDetail billDetailMikata = billMikata.bill_detail.get(i);
                    BillDetail__c billDetailSfdc = tempBillsDetail.get(i); 
                    mappingDataBillDetail(billDetailSfdc, billDetailMikata);
                    billsDetailToUpdate.add(billDetailSfdc); 
                }
            }
        }

        // Update bill
        if (billsToUpdate != null && !billsToUpdate.isEmpty()) {
            doInsertBills(billsToUpdate, false);
        }

        // Update bill detail
        if (billsDetailToUpdate != null && !billsDetailToUpdate.isEmpty()) {
            doInsertBillsDetail(billsDetailToUpdate);
        }     
    }

    private void mappingDataBill(Bill__c billSfdc, CLP_BulkBillWrapper.Bill billMikata, Boolean isInsert) {
        if (isInsert) {
            // Status mapping
            billSfdc.IsIntegrated__c = true;
            billSfdc.StopFlg__c = null;
            billSfdc.IsStop__c = false;
            //billSfdc.manipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
            billSfdc.ErrorMessage__c = null; 

            // Lookup field mapping
            billSfdc.AccountId__r = String.isBlank(billMikata.billing_code) ? null : new Account(SeikyusakiCode__c = billMikata.billing_code);
            billSfdc.PaymentMethodId__r = String.isBlank(billMikata.payment_method_code) ? null : new PaymentMethod__c(PaymentMethodCode__c = billMikata.payment_method_code);
            billSfdc.Billing_Individual__r = String.isBlank(billMikata.billing_individual_code) ? null : new Seikyusakibusho__c(link_customer_code__c = billMikata.billing_individual_code);
            billSfdc.BillingSourceOwnerId__r = String.isBlank(billMikata.bs_owner_code) ? null : new BillingSourceOwner__c(Code__c = billMikata.bs_owner_code);        
        }

        // Data mapping
        billSfdc.Name = billMikata.number_z;
        billSfdc.number__c = billMikata.number_z;
        billSfdc.IssueDate__c = getDate(billMikata.issue_date); 
        billSfdc.sending_date__c = getDate(billMikata.sending_date);   
        billSfdc.PaymentStatus__c = (billMikata.payment_status == null) ? null : String.valueOf(billMikata.payment_status); 
        billSfdc.SubtotalBilledAmount__c = billMikata.subtotal_amount_billed;    
        billSfdc.ConsumptionTaxAmount__c = billMikata.consumption_tax_amount;    
        billSfdc.TotalBilledAmount__c = billMikata.total_amount_billed;
        billSfdc.UnclearingAmount__c = billMikata.unclearing_amount;
        billSfdc.MessageColumn__c = billMikata.message_column;
        billSfdc.Billing_Method__c = (billMikata.billing_method == null) ? null : String.valueOf(billMikata.billing_method); 
        billSfdc.PaymentDeadlineDate__c = getDate(billMikata.transfer_deadline);    
        billSfdc.TransferDate__c = getDate(billMikata.transfer_date);
        billSfdc.Update_Date__c = getDate(billMikata.update_date);
        billSfdc.SendingScheduledDate__c = getDate(billMikata.sending_scheduled_date);
        billSfdc.BillingURL__c = billMikata.download_url;
        // New field added 【SFDC-請求管理ロボ】請求書参照連携バッチジョブ_0.4
        billSfdc.BillingCode__c = billMikata.billing_code;
        billSfdc.billing_destination_name__c = billMikata.billing_name;
        billSfdc.BillingIndividualCode__c = billMikata.billing_individual_code;
        billSfdc.billing_destination_dept_name__c = billMikata.billing_individual_name;
        billSfdc.PaymentMethodCode__c = billMikata.payment_method_code;
        billSfdc.PaymentMethodName__c = billMikata.payment_method_name;

        // Reset awaiting status
        if (!isInsert) {
            if (billSfdc.AwaitingGetNewBill__c) {
                billSfdc.AwaitingGetNewBill__c = false;  
            }
        }    
    }

    private void mappingDataBillDetail(BillDetail__c billDetailSfdc, CLP_BulkBillWrapper.BillDetail billDetailMikata) {
        billDetailSfdc.Name = billDetailMikata.demand_number; 
        billDetailSfdc.GoodsCode__c = billDetailMikata.goods_code;
        billDetailSfdc.Goods_Name__c = billDetailMikata.goods_name;
        billDetailSfdc.ItemCode__c = billDetailMikata.item_code;
        billDetailSfdc.Price__c = billDetailMikata.unit_price;
        billDetailSfdc.Quantity__c = (billDetailMikata.quantity == null) ? null : Integer.valueOf(billDetailMikata.quantity); 
        billDetailSfdc.Unit__c = (billDetailMikata.unit == null) ? null : String.valueOf(billDetailMikata.unit);
        billDetailSfdc.Consumption_Tax_Amount__c = billDetailMikata.consumption_tax_amount;
        billDetailSfdc.Remark__c = billDetailMikata.remark;
        billDetailSfdc.PeriodStartDate__c = getDate(billDetailMikata.demand_start_date);
        billDetailSfdc.PeriodEndDate__c = getDate(billDetailMikata.demand_end_date);
    }

    private void doInsertBills(List<Bill__c> bills, Boolean isInsert) {
        // isInsert = true --> insert
        // isInsert = false --> update        
        String[] listField = new String[] {
            'AccountId__c', 'Billing_Individual__c', 'PaymentMethodId__c', 'BillingSourceOwnerId__c',
            'Name', 'number__c', 'IssueDate__c', 'sending_date__c', 'PaymentStatus__c', 'SubtotalBilledAmount__c', 'ConsumptionTaxAmount__c',
            'TotalBilledAmount__c', 'UnclearingAmount__c', 'MessageColumn__c', 'Billing_Method__c', 'PaymentDeadlineDate__c', 'TransferDate__c', 
            'Update_Date__c', 'manipulateStatus__c', 'SendingScheduledDate__c', 'BillingURL__c', 'IsIntegrated__c', 'ErrorMessage__c',
            'BillingCode__c', 'billing_destination_name__c', 'BillingIndividualCode__c', 'billing_destination_dept_name__c',
            'PaymentMethodCode__c', 'PaymentMethodName__c', 'StopFlg__c', 'IsStop__c', 'AwaitingGetNewBill__c' 
        };

        // Check FLS
        Boolean checkInsert = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT);
        Boolean checkUpdate = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT);
        if (!checkInsert || !checkUpdate) {
            this.raiseError = true;  
            createLog(this.lastReferenceList[0], null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND); 
            return; 
        } 

        // Case update
        if (!isInsert) {
            List<Database.SaveResult> saveResults = Database.update(bills, false);
            for (Integer i=0; i<saveResults.size(); i++) {
                if (!saveResults[i].isSuccess()) {
                    String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                    createLogBill(bills[i], totalErrorMsg);
                }
            }
        
        // Case insert
        } else {
            List<Bill__c> billsInsertFailed = new List<Bill__c>();
            List<Database.SaveResult> saveResList = Database.insert(bills, false);
            List<Database.SaveResult> saveResListFailed = new List<Database.SaveResult>();
            for (Integer i=0; i<saveResList.size(); i++) {
                if (!saveResList[i].isSuccess()) {
                    billsInsertFailed.add(bills[i]);
                    saveResListFailed.add(saveResList[i]);
                } 
            }

            if (billsInsertFailed != null && !billsInsertFailed.isEmpty()) {
                tryToInsertAgain(billsInsertFailed, saveResListFailed);
            }

            // Reset value Manipulate Status  = '3'
            List<Bill__c> tempBills = new List<Bill__c>();
            for (Bill__c bill : bills) {
                if (bill.manipulateStatus__c != CLP_MikataConstant.DEMAND_LINK_SUCCESS) {
                    bill.manipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS; 
                    tempBills.add(bill);
                }
            }
            if (tempBills != null && !tempBills.isEmpty()) {
                Savepoint sp = Database.setSavepoint();
                try {
                    update tempBills;

                } catch(DmlException ex) {
                    Database.rollback(sp);
                    throw ex;
                }
            }
        }
    }

    private void doInsertBillsDetail(List<BillDetail__c> billsDetail) {
        // isInsert = true --> insert
        // isInsert = false --> update        
        String[] listField = new String[] {
            'BillId__c', 'GoodsCode__c', 'Goods_Name__c', 'ItemCode__c', 'Price__c', 'Quantity__c', 'Unit__c', 'Consumption_Tax_Amount__c',
            'Remark__c', 'PeriodStartDate__c', 'PeriodEndDate__c'
        };

        // Check FLS
        Boolean checkInsert = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_DETAIL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT);
        Boolean checkUpdate = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_DETAIL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT);
        if (!checkInsert || !checkUpdate) {
            this.raiseError = true;  
            createLog(this.lastReferenceList[0], null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND);
            return; 
        }

        List<Database.UpsertResult> saveResults = Database.upsert(billsDetail, false);
        for (Integer i=0; i<saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                system.debug('@@@ saveResult insertBillDetail failed= ' + saveResults[i]);
                String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                system.debug('@@@ saveResult insertBillDetail errMsg= ' + totalErrorMsg);
                Bill__c billErr = billsDetail[i].BillId__r; 
                system.debug('@@@billErr= ' + billErr);
                createLogBillDetail(billErr, billsDetail[i], totalErrorMsg);
            }
        }
    }

    private void tryToInsertAgain(List<Bill__c> billsInsertFailed, List<Database.SaveResult> saveResListFailed) {
        String[] listField = new String[] {'AccountId__c', 'PaymentMethodId__c', 'Billing_Individual__c', 'BillingSourceOwnerId__c'};
            
        // Check FLS
        Boolean checkInsert = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT);
        Boolean checkUpdate = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT);
        if (!checkInsert || !checkUpdate) {
            this.raiseError = true;
            createLog(this.lastReferenceList[0], null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND);
            return;    
        }

        Boolean doNotHaveError = true;

        // Reset AccountId__r
        for (Integer i=0; i<saveResListFailed.size(); i++) {
            String errMsg = getErrorValidationMessage(saveResListFailed[i].getErrors());
            if (errMsg.contains('SeikyusakiCode__c')) {
                billsInsertFailed[i].AccountId__r = null;  

            } else if (errMsg.contains('link_customer_code__c')) {
                billsInsertFailed[i].Billing_Individual__r = null;  
            
            } else if (errMsg.contains('PaymentMethodCode__c')) {
                billsInsertFailed[i].PaymentMethodId__r = null;    

            } else if (errMsg.contains('Code__c')) {
                billsInsertFailed[i].BillingSourceOwnerId__r = null;  
            }
        }
        List<Database.SaveResult> upResList1 = Database.insert(billsInsertFailed, false);
        doNotHaveError = checkErrorInsert(upResList1);
        if (doNotHaveError) {
            return;
        }

        // Reset link_customer_code__c
        for (Integer i=0; i<upResList1.size(); i++) {
            if (!upResList1[i].isSuccess()) {
                String errMsg = getErrorValidationMessage(upResList1[i].getErrors());
                if (errMsg.contains('SeikyusakiCode__c')) {
                    billsInsertFailed[i].AccountId__r = null;  

                } else if (errMsg.contains('link_customer_code__c')) {
                    billsInsertFailed[i].Billing_Individual__r = null;  
                
                } else if (errMsg.contains('PaymentMethodCode__c')) {
                    billsInsertFailed[i].PaymentMethodId__r = null;    

                } else if (errMsg.contains('Code__c')) {
                    billsInsertFailed[i].BillingSourceOwnerId__r = null;  
                }
            }
        }
        List<Database.SaveResult> upResList2 = Database.insert(billsInsertFailed, false);
        doNotHaveError = checkErrorInsert(upResList2);
        if (doNotHaveError) {
            return;
        }

        // Reset PaymentMethodCode__c
        for (Integer i=0; i<upResList2.size(); i++) {
            if (!upResList2[i].isSuccess()) {
                String errMsg = getErrorValidationMessage(upResList2[i].getErrors());
                if (errMsg.contains('SeikyusakiCode__c')) {
                    billsInsertFailed[i].AccountId__r = null;  

                } else if (errMsg.contains('link_customer_code__c')) {
                    billsInsertFailed[i].Billing_Individual__r = null;  
                
                } else if (errMsg.contains('PaymentMethodCode__c')) {
                    billsInsertFailed[i].PaymentMethodId__r = null;    

                } else if (errMsg.contains('Code__c')) {
                    billsInsertFailed[i].BillingSourceOwnerId__r = null;  
                }
            }
        }
        List<Database.SaveResult> upResList3 = Database.insert(billsInsertFailed, false);
        doNotHaveError = checkErrorInsert(upResList3);
        if (doNotHaveError) {
            return;
        }

        // Reset Code__c
        for (Integer i=0; i<upResList3.size(); i++) {
            if (!upResList3[i].isSuccess()) {
                String errMsg = getErrorValidationMessage(upResList3[i].getErrors());
                if (errMsg.contains('SeikyusakiCode__c')) {
                    billsInsertFailed[i].AccountId__r = null;  

                } else if (errMsg.contains('link_customer_code__c')) {
                    billsInsertFailed[i].Billing_Individual__r = null;  
                
                } else if (errMsg.contains('PaymentMethodCode__c')) {
                    billsInsertFailed[i].PaymentMethodId__r = null;    

                } else if (errMsg.contains('Code__c')) {
                    billsInsertFailed[i].BillingSourceOwnerId__r = null;  
                }
            }
        }
        Database.insert(billsInsertFailed, false);
    }

    private Boolean checkErrorInsert(List<Database.SaveResult> resList) {
        for (Database.SaveResult res : resList) {
            if (!res.isSuccess()) {
                return false;
            }
        }
        return true;
    }

    private Date getDate(String stringDate) {
        // stringDate format yyyy/MM/dd or yyyy-MM-dd
        if (String.isBlank(stringDate)) {
            return null;
        }
        String usedSeparator = '';
        List<String> separators = new List<String> { '/', '-' };

        for (String sep : separators) {
            if (stringDate.contains(sep)) {
                usedSeparator = sep;
                break;    
            }   
        }

        if (String.isBlank(usedSeparator)) {
            return null;
        } else {
            String[] splitDate = stringDate.split(usedSeparator);
            String year = splitDate[0];
            String month = splitDate[1];
            String day = splitDate[2];  
            return Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
        }
    }

    private void createLog(LastReference__c lastRef, CLP_BulkBillWrapper.Bill billResponse, String errMsg, String operation) {  
        Logger__c log = new Logger__c();          
        log.LK_RelatedUser__c = lastRef.LastModifiedById;                      
        log.Origin__c  = Label.CLP_BillBulkReferenceMikataBatchLabel;
        log.Content__c = errMsg;
        log.Request__c = CLP_MikataBillApi.getApiRequest(lastRef, null, this.billNumber, this.indexPaging);
        log.Response__c = CLP_MikataBillApi.getApiResponse(billResponse);
        log.Operation__c = operation;
        CLP_Logger.log(log);
    }

    private void createLogBill(Bill__c billReq, String errorMsg) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = billReq.LastModifiedById;
        log.Origin__c  = Label.CLP_BillBulkReferenceMikataBatchLabel;
        log.Request__c = (billReq == null) ? null : CLP_MikataBillApi.getApiRequest(billReq, CLP_MikataApi.ApiType.F_UPSERT);
        log.Response__c = null;
        log.Content__c = errorMsg;                        
        log.Operation__c = CLP_Logger.L_OUTBOUND;
        CLP_Logger.log(log);
    }

    private void createLogBillDetail(Bill__c billReq, BillDetail__c billDetReq, String errorMsg) {
        Logger__c log = new Logger__c();    
        log.LK_RelatedUser__c = (billReq == null) ? billDetReq.LastModifiedById : billReq.LastModifiedById;
        log.Origin__c  = Label.CLP_BillBulkReferenceMikataBatchLabel;
        log.Request__c = (billReq == null) ? null : CLP_MikataBillApi.getApiRequest(billReq, billDetReq);
        log.Response__c = null;
        log.Content__c = errorMsg;                        
        log.Operation__c = CLP_Logger.L_OUTBOUND;
        CLP_Logger.log(log);
    }

    private void updateLastReference(List<LastReference__c> lastRefList) {
        // Don't update last reference date when click reference button on Bill detail page
        if (this.billNumber != null) {
            return;
        }
        LastReference__c lastRef = lastRefList.get(0);
        lastRef.LastReferenceDate__c = Date.today(); 
        String[] listField = new String[] {'LastReferenceDate__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
        && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)) {
            update lastRefList;  
            system.debug('@@@@@ update last reference successfully');
        
        } else {
            createLog(lastRefList[0], null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND);
            CLP_Logger.flush();
        }
    }

    private void setScheduleBatch() {
        // Run batch after 1 hour
        Integer currentMinute = Datetime.now().minute();
        Integer nextHour = Datetime.now().addHours(1).hour();
        CLP_BillBulkReferenceSchedulableBatch schBatch = new CLP_BillBulkReferenceSchedulableBatch();
        String timer = '0 ';
        timer += String.valueOf(currentMinute) + ' ';
        timer += String.valueOf(nextHour) + ' * * ?';

        // Query scheduled batch
        Integer countSchBatch = [SELECT count()
                                 FROM CronTrigger
                                 WHERE CronJobDetail.Name like 'Res_CLP_BillBulkReferenceSchedulableBatch%'];

        // Set scheduled batch with index increase start with 1 in batch name
        String nameSchBatch = 'Res_CLP_BillBulkReferenceSchedulableBatch_' + String.valueOf(countSchBatch + 1);
        System.schedule(nameSchBatch, timer, schBatch);
    }

    private void checkScheduledBatch() {
        List<CronTrigger> listSchBatch = [SELECT Id, CronJobDetail.Name
                                          FROM CronTrigger 
                                          WHERE CronJobDetail.Name like 'Res_CLP_BillBulkReferenceSchedulableBatch_%'];

        // If found any scheduled job that get bill --> abort
        if (listSchBatch != null && !listSchBatch.isEmpty()) {
            for (CronTrigger schBatch : listSchBatch) {
                System.abortJob(schBatch.Id);    
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

    private List<Bill__c> getBillRecords(Set<String> setNumber) {
        List<Bill__c> bills = [SELECT Id, LastModifiedById, Name, number__c, IssueDate__c, sending_date__c, PaymentStatus__c, SubtotalBilledAmount__c,
                                      ConsumptionTaxAmount__c, TotalBilledAmount__c, UnclearingAmount__c, MessageColumn__c,
                                      Billing_Method__c, PaymentDeadlineDate__c, TransferDate__c, Update_Date__c, manipulateStatus__c,
                                      SendingScheduledDate__c, BillingURL__c, IsIntegrated__c, StopFlg__c, IsStop__c, ErrorMessage__c,
                                      BillingCode__c, billing_destination_name__c, BillingIndividualCode__c, billing_destination_dept_name__c,
                                      PaymentMethodCode__c, PaymentMethodName__c, AwaitingGetNewBill__c,
                                      AccountId__c, PaymentMethodId__c, Billing_Individual__c, BillingSourceOwnerId__c,
                                      (SELECT LastModifiedById, Name, GoodsCode__c, Goods_Name__c, ItemCode__c, Price__c, Quantity__c, Unit__c, 
                                              Consumption_Tax_Amount__c, Remark__c, PeriodStartDate__c, PeriodEndDate__c, BillId__c
                                       FROM BillDetails__r)
                                FROM Bill__c
                                WHERE number__c IN :setNumber];
        return (bills == null || bills.isEmpty()) ? null : bills;
    }
}