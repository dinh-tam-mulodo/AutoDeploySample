global with sharing class CLP_BillBulkReferenceMikataBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global Boolean shouldStop = false;  
    global Boolean raiseError = false;
    global String sql;
    //global String cntsql;
    global String billNumber;
    global Integer indexPaging;
    private Integer totalPageCountMikata; 
    private Integer limitCount;
    private List<LastReference__c> lastReferenceList;
    
    global CLP_BillBulkReferenceMikataBatch() {
    }

    global CLP_BillBulkReferenceMikataBatch(String varBillNumber, Integer varIndexPage) {
        /*
            varBillNumber == null --> click reference button on Bill List view or by a scheduled batch
            varBillNumber != null --> click reference button on Bill detail page
            Don't update last reference date when click reference button on Bill detail page <=> varBillNumber != null
        */
        this.billNumber = varBillNumber;
        this.indexPaging = varIndexPage;
        this.limitCount = 20;
    }
    
    // start batch with check duplicate running 
    public static Id startBatch(Boolean checkRunning, String varBillNumber, Integer varIndexPage) {
        if (checkRunning) {
            List<AsyncApexJob> aajList = [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_BillBulkReferenceMikataBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')
                                          limit 1];
            if (aajList.size() != 0) {
                return null;
            }
        }
        String billNumber = (String.isBlank(varBillNumber)) ? null : varBillNumber; 
        Integer indexPage = (varIndexPage == null) ? 0 : varIndexPage;
        CLP_BillBulkReferenceMikataBatch processor = new CLP_BillBulkReferenceMikataBatch(billNumber, indexPage);
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.sql = 'Select Id, LastModifiedById, LastReferenceDate__c from LastReference__c';
        //this.cntsql = 'Select count() from LastReference__c';

        //In case there are many same batch run at same times reject all
        Integer cntJob = [select count() from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_BillBulkReferenceMikataBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding') ];                     
        if(cntJob>=2){
            this.sql = this.sql + ' LIMIT 0';      
            this.shouldStop=true;
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
            CLP_BulkBillWrapper result = CLP_MikataBillApi.referenceFromMikata(lastRefList, this.billNumber, this.indexPaging, this.limitCount);
            system.debug('@@@@ CLP_BillBulkReferenceMikataBatch result= ' + result);

            if (result.success) {
                // Not found any bill returned from Mikata --> go finish
                if ((result.bill == null || result.bill.isEmpty()) && result.total_page_count == null) {
                    if (String.isNotBlank(this.billNumber)) {
                        // update field AwaitingGetNewBill__c when not found any latest bill data
                        updateAwaitingStatus(this.billNumber);
                    }
                    this.totalPageCountMikata = null;
                    return;
                } 
                this.totalPageCountMikata = result.total_page_count;
                for (CLP_BulkBillWrapper.Bill aBill : result.bill) {
                    if (String.isBlank(aBill.error_message)) {
                        billsMikataMap.put(aBill.number_z, aBill);
                        //createLog(lastRefList[0], aBill, aBill.error_message, CLP_Logger.L_SUCCESS);
                    } else {
                        this.raiseError = true;
                        createLog(lastRefList[0], aBill, aBill.error_message, CLP_Logger.L_OUTBOUND);
                    }
                }

            // if(!result.success)
            } else { 
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
            List<Bill__c> listBillInSFDC = getBillRecords(billsMikataMap.keySet());

            // If not found any record in SFDC to update --> insert all bill returned from Mikata
            if (listBillInSFDC == null) {
                upsertBillAndBillDetail(null, billsMikataMap);
            
            // Else, insert new bill from Mikata and update existing bill in SFDC
            } else {
                Set<String> billNumberToInsertSet = new Set<String>(billsMikataMap.keySet());
                Map<String, Bill__c> billsSfdcToUpdateMap = new Map<String, Bill__c>();

                for (Bill__c billInSFDC : listBillInSFDC) {
                    if (billsMikataMap.keySet().contains(billInSFDC.number__c)) {
                        billsSfdcToUpdateMap.put(billInSFDC.number__c, billInSFDC);
                        billNumberToInsertSet.remove(billInSFDC.number__c);
                    }     
                }

                // Insert some new bill returned from Mikata
                if (billNumberToInsertSet != null && !billNumberToInsertSet.isEmpty()) {
                    Map<String, CLP_BulkBillWrapper.Bill> billsMikataSubMap = new Map<String, CLP_BulkBillWrapper.Bill>();
                    for (String billNumber : billNumberToInsertSet) {
                        CLP_BulkBillWrapper.Bill billMikata = billsMikataMap.get(billNumber);
                        billsMikataSubMap.put(billNumber, billMikata);               
                    }
                    upsertBillAndBillDetail(null, billsMikataSubMap);
                    if (this.raiseError) {
                        //CLP_Logger.flush();
                        return;  
                    }
                }

                // Update newest data from mikata of existing bill in SFDC
                if (billsSfdcToUpdateMap != null && !billsSfdcToUpdateMap.isEmpty()) {
                    upsertBillAndBillDetail(billsSfdcToUpdateMap, billsMikataMap);
                }
            }
            /* ------------------------------ End main process ------------------------------ */ 

        } catch(Exception ex) {
            this.raiseError = true;
            System.debug('CLP_BillBulkReferenceMikataBatch.execute.exception= ' + ex.getMessage());
            CLP_Logger.log(ex.getMessage(), Label.CLP_BillBulkReferenceMikataBatchLabel);
        }
        CLP_Logger.flush();
    }
    
    // Finish this batch send email and recall batch if was exist batch in queue
    global void finish(Database.BatchableContext BC) {
        // Send email
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_BillBulkReferenceMikataBatchLabel);
        
        // If more than 2 job started at the same time ==> abort all job
        if(this.shouldStop){
            for(AsyncApexJob aaj : [select Id from AsyncApexJob where CompletedDate = null and JobType = 'BatchApex'
                                          and ApexClass.Name = 'CLP_BillBulkReferenceMikataBatch'
                                          and (Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' or Status = 'Holding')]) {
                System.abortJob(aaj.id);  
            }
            startBatch(true, this.billNumber, 0);  
        }

        // Finish step
        if(!this.raiseError) {
            if (this.totalPageCountMikata != null && this.totalPageCountMikata > 0) {
                Integer endIndexPaging = this.totalPageCountMikata - 1;
                Boolean isStopPaging = (this.indexPaging == endIndexPaging) ? true : false;

                if (isStopPaging) {
                    updateLastReference(this.lastReferenceList);  

                } else {
                    // Run batch again (next page Mikata)
                    if(!Test.isRunningTest()) {
                        startBatch(true, this.billNumber, this.indexPaging + 1);
                    } 
                }
            }
        }
        CLP_Logger.flush();
        // Send email again if error happen when manipulating on object LastReference__c
        CLP_MikataApi.sendEmailComplete('CLP_SendLogEmail', Label.CLP_BillBulkReferenceMikataBatchLabel);
    }  

    private void upsertBillAndBillDetail(Map<String, Bill__c> billSfMap, Map<String, CLP_BulkBillWrapper.Bill> billMikataMap) {
        List<Bill__c> listBillToUpsert = new List<Bill__c>();
        List<BillDetail__c> listBillDetailToUpsert = new List<BillDetail__c>();
        Map<String, List<BillDetail__c>> billDetailByBillCodeMap = new Map<String, List<BillDetail__c>>();

        /* ------------------------------- Case insert new bill/bill detail ------------------------------- */
        if (billSfMap == null) {
            for (String billNumber : billMikataMap.keySet()) {
                CLP_BulkBillWrapper.Bill billMikata = billMikataMap.get(billNumber);
                Bill__c newBill = new Bill__c();
                mappingBillData(newBill, billMikata, true); 
                listBillToUpsert.add(newBill); 
                
                // loop list bill_detail in billMikata
                if (billMikata.bill_detail != null) {          
                    List<BillDetail__c> tempListBillDetail = new List<BillDetail__c>();
                    for (CLP_BulkBillWrapper.BillDetail billDetMikata : billMikata.bill_detail) {
                        BillDetail__c billDetSfdc = new BillDetail__c();
                        mappingBillDetailData(billDetSfdc, billDetMikata);
                        tempListBillDetail.add(billDetSfdc);
                    }
                    billDetailByBillCodeMap.put(billMikata.number_z, tempListBillDetail);
                }
            }

            // Insert bill
            if (listBillToUpsert != null && !listBillToUpsert.isEmpty()) {
                doUpsertBill(listBillToUpsert, true);
            }

            if (this.raiseError) {
                return;
            }

            // Insert bill detail
            if (billDetailByBillCodeMap != null && !billDetailByBillCodeMap.isEmpty()) {
                for (Bill__c bi : listBillToUpsert) {
                    if (billDetailByBillCodeMap.keySet().contains(bi.number__c)) {
                        List<BillDetail__c> tempList = billDetailByBillCodeMap.get(bi.number__c);
                        for (BillDetail__c bidet : tempList) {
                            bidet.BillId__c = bi.Id; 
                            listBillDetailToUpsert.add(bidet);
                        }
                    }    
                } 
                if (listBillDetailToUpsert != null && !listBillDetailToUpsert.isEmpty()) {
                    doUpsertBillDetail(listBillDetailToUpsert);
                }    
            }
        
        /* ------------------------------- Case update existing bill/bill detail ------------------------------- */
        } else {
            for (String billNumber : billSfMap.keySet()) {
                Bill__c billSf = billSfMap.get(billNumber);
                CLP_BulkBillWrapper.Bill billMikata = billMikataMap.get(billNumber);
                mappingBillData(billSf, billMikata, false); 
                listBillToUpsert.add(billSf); 
                
                // loop list bill_detail in billMikata
                if (billMikata.bill_detail != null) {          
                    List<BillDetail__c> tempListBillDetail = billSf.BillDetails__r;
                    if (tempListBillDetail != null && (billMikata.bill_detail.size() == tempListBillDetail.size())) {
                        for (Integer i=0; i<billMikata.bill_detail.size(); i++) {
                            CLP_BulkBillWrapper.BillDetail billDetMikata = billMikata.bill_detail[i];
                            BillDetail__c billDetSfdc = tempListBillDetail[i];
                            mappingBillDetailData(billDetSfdc, billDetMikata);
                            listBillDetailToUpsert.add(billDetSfdc);
                        }
                    }
                }
            }

            // Update bill
            if (listBillToUpsert != null && !listBillToUpsert.isEmpty()) {
                doUpsertBill(listBillToUpsert, false);
            }
            
            if (this.raiseError) {
                return;
            }

            // Update bill detail
            if (listBillDetailToUpsert != null && !listBillDetailToUpsert.isEmpty()) {
                doUpsertBillDetail(listBillDetailToUpsert);
            }     
        }
    }

    private void mappingBillData(Bill__c billSfdc, CLP_BulkBillWrapper.Bill billMikata, Boolean isInsert) {
        // Data mapping
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

        if (isInsert) {
            billSfdc.Name = billMikata.number_z;
            // Status mapping
            billSfdc.IsIntegrated__c = true;
            billSfdc.StopFlg__c = null;
            billSfdc.IsStop__c = false;
            //billSfdc.manipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
            billSfdc.ErrorMessage__c = null; 

            // Lookup field mapping
            billSfdc.AccountId__r = String.isBlank(billMikata.billing_code) ? null : new Account(SeikyusakiCode__c = billMikata.billing_code);
            billSfdc.PaymentMethodId__r = linkWithPayment(billMikata);
            billSfdc.Billing_Individual__r = linkWithSeikyusakibusho(billMikata);
            billSfdc.BillingSourceOwnerId__r = String.isBlank(billMikata.bs_owner_code) ? null : new BillingSourceOwner__c(Code__c = billMikata.bs_owner_code);        
        
        } else {
            billSfdc.manipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;  
            // Reset awaiting status  
            if (billSfdc.AwaitingGetNewBill__c) {
                billSfdc.AwaitingGetNewBill__c = false;  
            } 
        }
    }

    private PaymentMethod__c linkWithPayment(CLP_BulkBillWrapper.Bill billMikata) {
        if (String.isBlank(billMikata.billing_code)) {
            return null;   
        } else if (String.isBlank(billMikata.payment_method_code)) {
            return null;   
        } else {
            String paymentExternalKey = billMikata.billing_code + '_' + billMikata.payment_method_code;
            return new PaymentMethod__c(ExternalKey__c = paymentExternalKey);  
        }       
    }

    private Seikyusakibusho__c linkWithSeikyusakibusho(CLP_BulkBillWrapper.Bill billMikata) {
        if (String.isBlank(billMikata.billing_code)) {
            return null;   
        } else if (String.isBlank(billMikata.billing_individual_code)) {
            return null;   
        } else {
            String seiExternalKey = billMikata.billing_code + '_' + billMikata.billing_individual_code;
            return new Seikyusakibusho__c(ExternalKey__c = seiExternalKey);  
        }       
    }

    private void mappingBillDetailData(BillDetail__c billDetSfdc, CLP_BulkBillWrapper.BillDetail billDetMikata) {
        billDetSfdc.Name = billDetMikata.demand_number; 
        billDetSfdc.GoodsCode__c = billDetMikata.goods_code;
        billDetSfdc.Goods_Name__c = billDetMikata.goods_name;
        billDetSfdc.ItemCode__c = billDetMikata.item_code;
        billDetSfdc.Price__c = billDetMikata.unit_price;
        billDetSfdc.Quantity__c = (billDetMikata.quantity == null) ? null : Integer.valueOf(billDetMikata.quantity); 
        billDetSfdc.Unit__c = billDetMikata.unit;
        billDetSfdc.Consumption_Tax_Amount__c = billDetMikata.consumption_tax_amount;
        billDetSfdc.Remark__c = billDetMikata.remark;
        billDetSfdc.PeriodStartDate__c = getDate(billDetMikata.demand_start_date);
        billDetSfdc.PeriodEndDate__c = getDate(billDetMikata.demand_end_date);
        billDetSfdc.Total_Amount_Billed__c = billDetMikata.total_amount_billed;
        billDetSfdc.Sub_Total_Amout_Billed__c = billDetMikata.subtotal_amount_billed;
    }

    private void doUpsertBill(List<Bill__c> listBill, Boolean isInsert) {
        // Create restore point 
        Savepoint sp = Database.setSavepoint();

        String[] listField = new String[] {
            'AccountId__c', 'Billing_Individual__c', 'PaymentMethodId__c', 'BillingSourceOwnerId__c',
            'Name', 'number__c', 'IssueDate__c', 'sending_date__c', 'PaymentStatus__c', 'SubtotalBilledAmount__c', 'ConsumptionTaxAmount__c',
            'TotalBilledAmount__c', 'UnclearingAmount__c', 'MessageColumn__c', 'Billing_Method__c', 'PaymentDeadlineDate__c', 'TransferDate__c', 
            'Update_Date__c', 'manipulateStatus__c', 'SendingScheduledDate__c', 'BillingURL__c', 'IsIntegrated__c', 'ErrorMessage__c',
            'BillingCode__c', 'billing_destination_name__c', 'BillingIndividualCode__c', 'billing_destination_dept_name__c',
            'PaymentMethodCode__c', 'PaymentMethodName__c', 'StopFlg__c', 'IsStop__c', 'AwaitingGetNewBill__c' 
        };

        Boolean checkInsert = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT);
        Boolean checkUpdate = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT);
        if (!checkInsert || !checkUpdate) {
            this.raiseError = true;  
            createLog(this.lastReferenceList[0], null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND); 
            return;
        }

        // ----------------- Case update -----------------
        if (!isInsert) {
            List<Database.SaveResult> saveResults = Database.update(listBill, false);
            for (Integer i=0; i<saveResults.size(); i++) {
                if (!saveResults[i].isSuccess()) {
                    String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                    createLogBill(listBill[i], totalErrorMsg);
                }
            }
        
        // ----------------- Case insert -----------------
        } else {
            List<Bill__c> listBillFailed = new List<Bill__c>();
            List<Database.UpsertResult> saveResListFailed = new List<Database.UpsertResult>();
            List<Database.UpsertResult> saveResList = Database.upsert(listBill, false);
            for (Integer i=0; i<saveResList.size(); i++) {
                if (!saveResList[i].isSuccess()) {
                    listBillFailed.add(listBill[i]);
                    saveResListFailed.add(saveResList[i]);
                } 
            }

            if (listBillFailed != null && !listBillFailed.isEmpty()) {
                tryToUpsertAgain(listBillFailed, saveResListFailed, sp);
            }

            // Reset value Manipulate Status  = '3'
            List<Bill__c> tempBills = new List<Bill__c>();
            for (Bill__c bill : listBill) {
                if (bill.manipulateStatus__c != CLP_MikataConstant.DEMAND_LINK_SUCCESS) {
                    bill.manipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;     
                    tempBills.add(bill);
                }
            }
            //
            if (tempBills != null && !tempBills.isEmpty()) {
                try {
                    update tempBills;

                } catch (DmlException ex) {
                    this.raiseError = true;
                    Database.rollback(sp);
                    throw ex;       
                }
            }
        }
    }

    private void doUpsertBillDetail(List<BillDetail__c> listBillDetail) {
        String[] listField = new String[] {
            'BillId__c', 'GoodsCode__c', 'Goods_Name__c', 'ItemCode__c', 'Price__c', 'Quantity__c', 'Unit__c', 'Consumption_Tax_Amount__c',
            'Remark__c', 'PeriodStartDate__c', 'PeriodEndDate__c', 'Total_Amount_Billed__c', 'Sub_Total_Amout_Billed__c'
        };

        Boolean checkInsert = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_DETAIL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT);
        Boolean checkUpdate = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_DETAIL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT);
        if (!checkInsert || !checkUpdate) {
            this.raiseError = true;
            createLog(this.lastReferenceList[0], null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND);
            return;
        }
        
        List<Database.UpsertResult> saveResults = Database.upsert(listBillDetail, false);
        for (Integer i=0; i<saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
                Bill__c billErr = listBillDetail[i].BillId__r; 
                createLogBillDetail(billErr, listBillDetail[i], totalErrorMsg);
            }
        }  
    }

    private void tryToUpsertAgain(List<Bill__c> listBill, Database.UpsertResult[] upResList, Savepoint svpoint) {
        String[] listField = new String[] {
            'AccountId__c', 'PaymentMethodId__c', 'Billing_Individual__c', 'BillingSourceOwnerId__c' 
        };

        Boolean checkInsert = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT);
        Boolean checkUpdate = CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT);
        if (!checkInsert || !checkUpdate) {
            this.raiseError = true;  
            createLog(this.lastReferenceList[0], null, CLP_MikataConstant.ERROR_DONTHAVE_PERMISSION, CLP_Logger.L_OUTBOUND); 
            return;
        }

        Boolean dontHaveError = true;

        // -------------- Reset AccountId__r --------------
        List<Bill__c> tempList = new List<Bill__c>();
        for (Integer i=0; i<upResList.size(); i++) {
            String errMsg = getErrorValidationMessage(upResList[i].getErrors());
            Bill__c errBill = listBill[i]; 
            errBill = checkAndResetLookupField(errMsg, errBill);
            tempList.add(errBill);
        }
        if (tempList.isEmpty()) {
            return;
        }
        Database.UpsertResult[] upResList1 = Database.upsert(tempList, false);
        dontHaveError = checkErrorUpsert(upResList1);
        if (dontHaveError) {
            return;
        }

        // -------------- Reset link_customer_code__c --------------
        List<Bill__c> tempList1 = new List<Bill__c>();
        for (Integer i=0; i<upResList1.size(); i++) {
            if (!upResList1[i].isSuccess()) {
                String errMsg = getErrorValidationMessage(upResList1[i].getErrors());
                Bill__c errBill = tempList[i]; 
                errBill = checkAndResetLookupField(errMsg, errBill);
                tempList1.add(errBill);
            }
        }
        if (tempList1.isEmpty()) {
            return;
        }
        Database.UpsertResult[] upResList2 = Database.upsert(tempList1, false);
        dontHaveError = checkErrorUpsert(upResList2);
        if (dontHaveError) {
            return;
        }

        // -------------- Reset PaymentMethodCode__c --------------
        List<Bill__c> tempList2 = new List<Bill__c>();
        for (Integer i=0; i<upResList2.size(); i++) {
            if (!upResList2[i].isSuccess()) {
                String errMsg = getErrorValidationMessage(upResList2[i].getErrors());
                Bill__c errBill = tempList1[i];
                errBill = checkAndResetLookupField(errMsg, errBill);
                tempList2.add(errBill);
            }
        }
        if (tempList2.isEmpty()) {
            return;
        }
        Database.UpsertResult[] upResList3 = Database.upsert(tempList2, false);
        dontHaveError = checkErrorUpsert(upResList3);
        if (dontHaveError) {
            return;
        }

        // -------------- Reset Code__c --------------
        List<Bill__c> tempList3 = new List<Bill__c>();
        for (Integer i=0; i<upResList3.size(); i++) {
            if (!upResList3[i].isSuccess()) {
                String errMsg = getErrorValidationMessage(upResList3[i].getErrors());
                Bill__c errBill = tempList2[i];
                errBill = checkAndResetLookupField(errMsg, errBill);
                tempList3.add(errBill);
            }
        }
        if (tempList3.isEmpty()) {
           return; 
        } 
        //
        try {
            upsert tempList3;

        } catch (DmlException ex) {
            this.raiseError = true;
            Database.rollback(svpoint);
            throw ex;       
        }
    }

    private Bill__c checkAndResetLookupField(String errMsg, Bill__c errBill) {
        if (errMsg.contains('SeikyusakiCode__c') && errMsg.contains('Account')) {
            errBill.AccountId__r = null;
            return errBill;
        } 
        //
        if (errMsg.contains('ExternalKey__c') && errMsg.contains('Seikyusakibusho__c')) {
            errBill.Billing_Individual__r = null;
            return errBill; 
        }  
        //
        if (errMsg.contains('ExternalKey__c') && errMsg.contains('PaymentMethod__c')) {
            errBill.PaymentMethodId__r = null;    
            return errBill; 
        }
        //
        if (errMsg.contains('Code__c') && errMsg.contains('BillingSourceOwner__c')) {
            errBill.BillingSourceOwnerId__r = null;  
            return errBill;
        }   
        return errBill;
    }

    private Boolean checkErrorUpsert(Database.UpsertResult[] resList) {
        for (Database.UpsertResult res : resList) {
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
        log.Request__c = CLP_MikataBillApi.getApiRequest(lastRef, null, this.billNumber, this.indexPaging, this.limitCount);
        log.Response__c = (operation == CLP_Logger.L_SUCCESS) ? null : CLP_MikataBillApi.getApiResponse(billResponse);
        log.Operation__c = operation;
        CLP_Logger.log(log);
        system.debug('@@@ createLog.log= ' + log);
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
        system.debug('@@@ createLogBill.log= ' + log);
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
        system.debug('@@@ createLogBillDetail.log= ' + log);
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
            //CLP_Logger.flush();
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
                                 WHERE CronJobDetail.Name LIKE 'Res_CLP_BillBulkReferenceSchedulableBatch%'];

        // Set scheduled batch with index increase start with 1 in batch name
        String nameSchBatch = 'Res_CLP_BillBulkReferenceSchedulableBatch_' + String.valueOf(countSchBatch + 1);
        System.schedule(nameSchBatch, timer, schBatch);
    }

    private void checkScheduledBatch() {
        List<CronTrigger> listSchBatch = [SELECT Id, CronJobDetail.Name
                                          FROM CronTrigger 
                                          WHERE CronJobDetail.Name LIKE 'Res_CLP_BillBulkReferenceSchedulableBatch_%'];

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

    private List<Bill__c> getBillRecords(Set<String> billNumberSet) {
        try {
            List<Bill__c> bills = new List<Bill__c>();
            for (List<Bill__c> tempBills : [SELECT Id, LastModifiedById, Name, number__c, IssueDate__c, sending_date__c, PaymentStatus__c, SubtotalBilledAmount__c,
                                                   ConsumptionTaxAmount__c, TotalBilledAmount__c, UnclearingAmount__c, MessageColumn__c,
                                                   Billing_Method__c, PaymentDeadlineDate__c, TransferDate__c, Update_Date__c, manipulateStatus__c,
                                                   SendingScheduledDate__c, BillingURL__c, IsIntegrated__c, StopFlg__c, IsStop__c, ErrorMessage__c,
                                                   BillingCode__c, billing_destination_name__c, BillingIndividualCode__c, billing_destination_dept_name__c,
                                                   PaymentMethodCode__c, PaymentMethodName__c, AwaitingGetNewBill__c,
                                                   AccountId__c, PaymentMethodId__c, Billing_Individual__c, BillingSourceOwnerId__c,
                                                   (SELECT LastModifiedById, Name, GoodsCode__c, Goods_Name__c, ItemCode__c, Price__c, Quantity__c, Unit__c, Consumption_Tax_Amount__c, Remark__c, 
                                                           PeriodStartDate__c, PeriodEndDate__c, BillId__c, Total_Amount_Billed__c, Sub_Total_Amout_Billed__c 
                                                    FROM BillDetails__r)
                                            FROM Bill__c
                                            WHERE number__c IN :billNumberSet]) {
                bills.addAll(tempBills);
            }
            return (bills == null || bills.isEmpty()) ? null : bills;  

        } catch (Exception ex) {
            throw ex;
        }
    }

    private void updateAwaitingStatus(String billNumber) {
        List<Bill__c> bills = [SELECT AwaitingGetNewBill__c
                               FROM Bill__c
                               WHERE number__c = :billNumber];
        if (!bills.isEmpty()) {
            Bill__c bill = bills[0];
            if (bill.AwaitingGetNewBill__c) {
                bill.AwaitingGetNewBill__c = false;
            } 
            String[] listField = new String[] {'AwaitingGetNewBill__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)) {             
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
}