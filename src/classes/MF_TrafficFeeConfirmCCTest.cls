@isTest(SeeAllData=true)
public class MF_TrafficFeeConfirmCCTest {
    public static String employeeNo{get;set;}
    @isTest public static void mapJsonToObjectTest(){
        MF_Fee__c mfFee = createDataTest(true);
        MF_TrafficFeeConfirmCC mfTrafficFeeConfirmCC = new MF_TrafficFeeConfirmCC();
        ApexPages.currentPage().getParameters().put('id', mfFee.Id);
        mfTrafficFeeConfirmCC.mapJsonToObject();
    }
    
     @isTest public static void mapJsonToObjectViewPDFTest(){
        MF_Fee__c mfFee = createDataTest(true);
        MF_TrafficFeeConfirmCC mfTrafficFeeConfirmCC = new MF_TrafficFeeConfirmCC();
        ApexPages.currentPage().getParameters().put('id', mfFee.Id);
        ApexPages.currentPage().getParameters().put('view', 'pdf');
        mfTrafficFeeConfirmCC.mapJsonToObject();
    }
    
    @isTest public static void saveTrafficFeeListTest(){
        createDataTest(true);
        Contact contact = [select id, EmployeeNo__c from Contact limit 1];
        MF_TrafficFeeConfirmCC mfTrafficFeeConfirmCC = new MF_TrafficFeeConfirmCC();
       
		ApexPages.currentPage().getParameters().put('employee-name', 'cao tan');
        ApexPages.currentPage().getParameters().put('employee-no', contact.EmployeeNo__c);
        ApexPages.currentPage().getParameters().put('total-price', '12000');//list-price
        ApexPages.currentPage().getParameters().put('list-price', '{"0":12000}');
        ApexPages.currentPage().getParameters().put('list-arrive', '{"0":"Nam Định"}');
        ApexPages.currentPage().getParameters().put('list-payment-date', '{"0":"2017-01-05T17:00:00.000Z"}');
        ApexPages.currentPage().getParameters().put('list-depart', '{"0":"Lạng Sơn"}');
        ApexPages.currentPage().getParameters().put('list-remark', '{"0":"123"}');
        ApexPages.currentPage().getParameters().put('list_account', '{"0":"001N000000wN8kuIAC"}');
        ApexPages.currentPage().getParameters().put('list-vehicle', '{"0":"Bus"}');
        ApexPages.currentPage().getParameters().put('list-image', '["2313213213213123123213123213"]');
        ApexPages.currentPage().getParameters().put('list-image-name', '["test.jpg"]');
        mfTrafficFeeConfirmCC.mapJsonToObject();
        
    }
    @isTest public static void getApproveReceiptTest(){
        MF_Fee__c mfFee = createDataTest(true);
        MF_TrafficFeeConfirmCC mfTrafficFeeConfirmCC = new MF_TrafficFeeConfirmCC();
        ApexPages.currentPage().getParameters().put('id', mfFee.Id);
        mfTrafficFeeConfirmCC.mapJsonToObject();
        mfTrafficFeeConfirmCC.getApproveReceipt();
    }
    
    @isTest public static void getApproveReceiptTest2(){
        MF_Fee__c mfFee = createDataTest(false);
        MF_TrafficFeeConfirmCC mfTrafficFeeConfirmCC = new MF_TrafficFeeConfirmCC();
        ApexPages.currentPage().getParameters().put('id', mfFee.Id);
        mfTrafficFeeConfirmCC.mapJsonToObject();
        mfTrafficFeeConfirmCC.getApproveReceipt();
    }
    private static MF_Fee__c createDataTest(Boolean hasApproval){
        //insert test data account
        Account account = new Account();
        account.Name = 'caotan';
        account.Phone = '01224323232';
        account.Website = 'www.google.com.vn';
        insert account;
        
        //insert test data contact
        Contact contact = new Contact();
        contact.LastName = 'cao';
        contact.FirstName ='tan';
        contact.AccountId = account.Id;
        contact.Phone = '0122323223';
        contact.Email = 'cao.tan@mulodo.com';
        insert contact;
        //insert test data mfFee
        MF_Fee__c mfFee = new MF_Fee__c();
        mfFee.Amount__c = 12000;
        mfFee.Contact__c = contact.id;
        mfFee.Fee_Status__c = 'Approved';
        mfFee.Fee_Type__c = 'Traffic';
        if (hasApproval){
            List<User> users = [select id, Name from User];
            mfFee.Approver__c = users.get(0).id;  
        }
        insert mfFee;
        
        //insert test data mfFeeTraffic
        MF_Traffic_Fee_Detail__c mfTrafficFee = new MF_Traffic_Fee_Detail__c();
        mfTrafficFee.Account__c = account.id;
        mfTrafficFee.Arrive__c = 'hochiminh';
        mfTrafficFee.Depart__c = 'hanoi';
        mfTrafficFee.Price__c = 12000;
        mfTrafficFee.Payment_Date__c = date.newInstance(2017, 7, 15);
	    mfTrafficFee.Transportation_Vehicle__c = 'bus';
        mfTrafficFee.MF_Fee__c = mfFee.Id;
        insert mfTrafficFee;
        
        return mfFee;
    }
}