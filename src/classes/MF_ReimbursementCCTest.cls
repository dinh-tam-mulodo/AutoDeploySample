@isTest(SeeAllData=true)
public class MF_ReimbursementCCTest {
	@isTest
    public static void constructorTest(){
        Contact contact = new Contact();
        contact = createDataTest();
        MF_CookieUtil.setCookieValue(MF_CookieUtil.COOKIE_CONTACT_ID, contact.Id, MF_CookieUtil.COOKIE_PATH, true);
        MF_ReimbursementCC mfReimbursementCC = new MF_ReimbursementCC();
    }
    
    @isTest public static void saveReimbursementTest(){
        String listobj = '{"data":[{"show":true,"paymentDate":"2017-01-08T17:00:00.000Z","title":"title","paymentContent":"paument","price":213,"file":"00PN0000004wMG7MAM","account":"001N000000wN8kuIAC","remark":"das","$$hashKey":"object:3"}]}';
    	Contact contact = createDataTest();
        User user = [select id from User limit 1];
        MF_ReimbursementCC.saveReimbursement(listobj, contact.id, user.id);
    }
    
    @isTest public static void uploadFileTest(){
    	Contact contact = createDataTest();
        system.assertNotEquals(MF_ReimbursementCC.uploadFile('dsadsa21321321321dsadsadas434354gfdbfdbvdhghgewrwef', contact.id), null);
    }
    
    @isTest public static void getDetailFeeTest1(){
        MF_Fee__c mfFee = createFeeApprovedTest();
        system.assert(MF_ReimbursementCC.getDetailFee(mfFee.id) != null);
    }
    
    @isTest public static void getReimbursementOfLoggedContactTest(){
       Contact contact = createDataTest();
       system.assert(MF_ReimbursementCC.getReimbursementOfLoggedContact(contact.id).size() == 0);
    }
    
    @isTest public static void updateFeeStatusTest(){
       MF_Fee__c mfFee = createFeeApprovedTest();
       system.assertEquals(MF_ReimbursementCC.updateFeeStatus(mfFee.id), true);
    }
    
    @isTest public static void updateFeeStatusTest2(){
       MF_Fee__c mfFee = createFeePendingTest();
       system.assertEquals(MF_ReimbursementCC.updateFeeStatus(mfFee.id), false);
    }
    
    @isTest public static void deleteReceiptTest1(){
       MF_Fee__c mfFee = createFeeApprovedTest();
       system.assertEquals(MF_ReimbursementCC.deleteReceipt(mfFee.id), false);
    }
    
    @isTest public static void deleteReceiptTest2(){
       MF_Fee__c mfFee = createFeePendingTest();
       system.assertEquals(MF_ReimbursementCC.deleteReceipt(mfFee.id), true);
    }
    
    @isTest public static void deleteReceiptTest3(){
       MF_Fee__c mfFee = createFeePendingReimbursementTest();
      system.assertEquals(MF_ReimbursementCC.deleteReceipt(mfFee.id), true);
    }
    
    @isTest public static void getAllUserTest(){
       system.assert(MF_ReimbursementCC.getAllUser().size() > 0);
    }
    
    @isTest public static void getAllAccountTest(){
       system.assert(MF_ReimbursementCC.getAllAccount().size() > 0);
    }
    
    //getAllUser
    private static MF_Fee__c createFeeApprovedTest(){
        Contact contact = createDataTest();
        MF_Fee__c mfFee = new MF_Fee__c();
        mfFee.Amount__c = 12000;
        mfFee.Contact__c = contact.id;
        mfFee.Fee_Status__c = 'Approved';
        mfFee.Fee_Type__c = 'Traffic';
        List<User> users = [select id, Name from User];
        mfFee.Approver__c = users.get(0).id;
        insert mfFee;
        return mfFee;
    }
    
    private static MF_Fee__c createFeePendingTest(){
        Contact contact = createDataTest();
        MF_Fee__c mfFee = new MF_Fee__c();
        mfFee.Amount__c = 12000;
        mfFee.Contact__c = contact.id;
        mfFee.Fee_Status__c = 'Pending';
        mfFee.Fee_Type__c = 'Traffic';
        List<User> users = [select id, Name from User];
        mfFee.Approver__c = users.get(0).id;
        insert mfFee;
        return mfFee;
    }
    
     private static MF_Fee__c createFeePendingReimbursementTest(){
        Contact contact = createDataTest();
        MF_Fee__c mfFee = new MF_Fee__c();
        mfFee.Amount__c = 12000;
        mfFee.Contact__c = contact.id;
        mfFee.Fee_Status__c = 'Pending';
        mfFee.Fee_Type__c = 'Reimbursement';
        List<User> users = [select id, Name from User];
        mfFee.Approver__c = users.get(0).id;
        insert mfFee;
        return mfFee;
    }
    
    private static Contact createDataTest(){
        Account account = new Account();
        account.Name = 'caotan';
        account.Phone = '01224323232';
        account.Website = 'www.google.com.vn';
        insert account;
        Contact contact = new Contact();
        contact.LastName = 'cao';
        contact.FirstName ='tan';
        contact.AccountId = account.Id;
        contact.Phone = '0122323223';
        contact.Email = 'cao.tan@mulodo.com';
        insert contact;  
        return contact;
    }
}