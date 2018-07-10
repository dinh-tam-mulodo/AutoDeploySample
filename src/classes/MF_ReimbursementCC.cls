/*
* MF_ReimbursementCC
* Show reimbursement fee list by id
* Submit to approval reimbursement receipt
*/
global with sharing class MF_ReimbursementCC extends MF_UserAuthentication {
    public Contact loggedContact{get;set;}
    public String uiTheme{get;set;}
    public MF_ReimbursementCC() {
        if (MF_UserAuthentication.cookieContactId != null){
          loggedContact = getLoggedContactInfo(MF_UserAuthentication.cookieContactId);
          //check device
          uiTheme = UserInfo.getUiThemeDisplayed();
        }
    }
    /*
    * getLoggedContactInfo
    * check to get contact of user logged
    */
    public static Contact getLoggedContactInfo(id idContact){
        Contact contactInfo = [SELECT Id, Name, Username__c, EmployeeNo__c, MF_Approver__c  FROM Contact WHERE id  = :idContact];
        return contactInfo;
    }

    /*
    * @RemoteAction
    * saveReimbursement
    */
    @RemoteAction
    global static MF_Fee__c saveReimbursement(String listobj, Id contactId, Id approverId) {
        MF_ReimbursementsListObject reimList = (MF_ReimbursementsListObject) JSON.deserialize(listobj, MF_ReimbursementsListObject.class);
        MF_Fee__c master = new MF_Fee__c();
        List<MF_Reimbursement_Detail__c> detailList = new List<MF_Reimbursement_Detail__c>();
        Double total = 0;
        for(MF_ReimbursementsObject reim : reimList.data){
            total += reim.price;
        }
        master.Amount__c = total;
        master.Fee_Status__c = '';
        master.Fee_Type__c = 'Reimbursement';
        master.Contact__c = contactId;
        master.Approver__c = approverId;
        insert master;

        for(MF_ReimbursementsObject reim : reimList.data){
            MF_Reimbursement_Detail__c detail = new MF_Reimbursement_Detail__c();
            detail.Payment_Content__c = reim.paymentContent;
            detail.Price__c = reim.price;
            String dateString = reim.paymentDate;
            detail.Payment_Date__c = Date.newInstance(Integer.valueOf(dateString.substring(0,4)),Integer.valueOf(dateString.substring(5, 7)),Integer.valueOf(dateString.substring(8, 10)));
            detail.Receipt_Image__c = '/servlet/servlet.FileDownload?file=' + reim.file;
            detail.Title__c = reim.title;
            detail.MF_Fee__c = master.Id;
            detail.Account__c = reim.account;
            detail.Remark__c = reim.remark;
            detailList.add(detail);
        }
        insert detailList;
        return master;
    }
    /*
    * @RemoteAction
    * uploadFile 
    * upload receipt image
    */
    @RemoteAction
    global static Id uploadFile(String file, Id contactId) {
        System.debug(file);
        Attachment attachment;
        if (file != ''){
            Long longtime = System.currentTimeMillis();
            attachment = new Attachment();
            attachment.Body = EncodingUtil.base64Decode(String.valueOf(file));
            attachment.Name = 'Receipt_'+contactId+'_'+longtime;
            attachment.ParentId = contactId;
            insert attachment;
        }
        return attachment.Id;
    }
    /*
    * @RemoteAction
    * uploadFile 
    * upload receipt image
    */
    @RemoteAction
    global static MF_FeeDetailsObject getDetailFee(Id feeId) {
        MF_Fee__c master = [SELECT Id, Name, Contact__c, Amount__c, Fee_Status__c, CreatedDate FROM MF_Fee__c WHERE id  = :feeId];
        Contact contact = getLoggedContactInfo(master.Contact__c);
        List <MF_Reimbursement_Detail__c> detail = [SELECT Id, Name, Title__c, Receipt_Image__c, Payment_Date__c, Payment_Content__c, Price__c, Account__r.Name, Remark__c FROM MF_Reimbursement_Detail__c WHERE MF_Fee__c = :feeId];
        MF_FeeDetailsObject result = new MF_FeeDetailsObject();
        result.master = master;
        result.detail = detail;
        result.contact = contact;
        return result;
    }
    /*
    * @RemoteAction
    * getReimbursementOfLoggedContact 
    * get all mf_fee by id contact
    */
    @RemoteAction
    global static List<MF_Fee__c> getReimbursementOfLoggedContact(Id contactId) {
        List<MF_Fee__c>  allFee = [SELECT Id, Name, Contact__c, Amount__c, Fee_Status__c, CreatedDate, Fee_Type__c FROM MF_Fee__c WHERE Contact__c  = :contactId ORDER BY CreatedDate DESC];
        return allFee;
    }
    /*
    * @RemoteAction
    * updateFeeStatus
    */
    @RemoteAction
    global static Boolean updateFeeStatus(Id feeId) {
        MF_Fee__c fee = [SELECT Id, Name, Contact__c, Amount__c,Approver__c, Fee_Status__c, CreatedDate FROM MF_Fee__c WHERE id  = :feeId];
        system.debug('Fee:'+fee);
        if (fee.Fee_Status__c == 'Pending' || fee.Approver__c == null) {
            system.debug('False');
            return false;
        } else {
            fee.Fee_Status__c = 'Pending';            
            update fee;
            return true;
        }
    }
    /*
    * @RemoteAction
    * deleteReceipt
    * delete receipt by id
    */    
    @RemoteAction
    global static Boolean deleteReceipt(Id feeId) {
        MF_Fee__c fee = [SELECT Id, Fee_Type__c, Fee_Status__c FROM MF_Fee__c WHERE id  = :feeId];
        if (fee.Fee_Status__c == 'Approved') {
            return false;
        }
        if (fee.Fee_Type__c == 'Traffic') {
            List <MF_Traffic_Fee_Detail__c> detail = [SELECT Id FROM MF_Traffic_Fee_Detail__c WHERE MF_Fee__c  = :feeId];
            try {
                delete detail;
                delete fee;
                return true;
            } catch (DmlException e) {
                return false;
            }
        } else {
            List <MF_Reimbursement_Detail__c> detail = [SELECT Id FROM MF_Reimbursement_Detail__c WHERE MF_Fee__c  = :feeId];
            try {
                delete detail;
                delete fee;
                return true;
            } catch (DmlException e) {
                return false;
            }
        }
    }
    /*
    * @RemoteAction
    * getAllUser
    */      
    @RemoteAction
    global static List<User> getAllUser() {
        List<UserLicense> ulics=[Select u.Id From UserLicense u where Name like 'Chatter Free' or Name like 'Chatter External'];
        List<User> users= [Select Name,Id from User u where u.ProfileId not in (Select Id From Profile p where p.UserLicenseId in :ulics)];
        return users;
    }
    /*
    * @RemoteAction
    * getAllAccount
    */  
    @RemoteAction
    global static List<Account> getAllAccount() {
        List<Account> accounts= [Select Name,Id from Account];
        return accounts;
    }
}