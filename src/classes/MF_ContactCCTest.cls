@isTest
public class MF_ContactCCTest {
    private static String generateJsonContact(String contact_Type){        
        MF_Contact con = new MF_Contact();
        con.Id = '003N000000s9N3W';
        con.FirstName = 'Test a';
        con.LastName = 'last';
        con.ContactType = contact_Type;
        con.Email = 'email@gmail.com';
        con.Username = 'test.user';
        con.Phone = '0939127600';
        con.AccountId = '001N000000wN8ku';
        String jsonString = JSON.serialize(con);
        system.debug(jsonString);
        return jsonString;
    }
    @isTest static void createInternalContactTest(){
        MF_ContactCC mf_con = new MF_ContactCC();
        mf_con.contactId = '003N000000s9N3W';
        mf_con.contactType = 'Internal';
        String jsonObject = generateJsonContact(mf_con.contactType);
        JsonResult result =  MF_ContactCC.addContact(jsonObject);
        system.assert(result.success, true);
    }
    @isTest static void createExternalContactTest(){
        MF_ContactCC mf_con = new MF_ContactCC();
        mf_con.contactId = '003N000000s9N3W';
        mf_con.contactType = 'External';
        String jsonObject = generateJsonContact(mf_con.contactType);
        JsonResult result =  MF_ContactCC.addContact(jsonObject);
        system.assert(result.success, true);
    }
    
    @isTest(SeeAllData = true) static void updateContactTest(){
        MF_ContactCC mf_con = new MF_ContactCC();
        mf_con.contactId ='003N000000s9N3W';
        mf_con.contactType = 'Internal';
        String jsonObject = generateJsonContact(mf_con.contactType);
        JsonResult result =  MF_ContactCC.updateContact(jsonObject);
        system.assert(result.success, true);
    }
    @isTest(SeeAllData=true) static void doUploadImageTest(){  
        MF_ContactCC mf_con = new MF_ContactCC();
        mf_con.contactId ='003N000000s9N3W';
        String result = MF_ContactCC.doUploadAttachment(mf_con.contactId, 'attachmentBody', 'attachmentName', '00PN0000004oC4VMAU');
        system.assert(result!=null);
    }	        
    @isTest(SeeAllData=true) static void doUploadImageWithoutAttIdTest(){  
        MF_ContactCC mf_con = new MF_ContactCC();
        mf_con.contactId ='003N000000s9N3W';
        String result = MF_ContactCC.doUploadAttachment(mf_con.contactId, 'attachmentBody', 'attachmentName', '');
        system.assert(result!=null);
    }
    @isTest(SeeAllData=true) static void getBranchTest(){
        MF_ContactCC mf_con = new MF_ContactCC();
        List<MF_Branch__c> result = mf_con.getBranchs();
        System.assert(result.size()>0);
    }
    @isTest static void getDepartmentTest(){
        List<MF_Department__c> result = MF_ContactCC.getDepartments('');
        System.assert(result.size()==0);
    }
    @isTest static void getUsersTest(){
        List<User> result = MF_ContactCC.getUsers();
        System.assert(result.size()>0);
    }
    @isTest(SeeAllData=true) static void getAccountTest(){
        List<Account> result = MF_ContactCC.getAccounts();
        System.assert(result.size()>0);
    }
    @isTest(SeeAllData=true) static void getContactsTest(){
        List<Contact> result = MF_ContactCC.getContacts();
        System.assert(result.size()>0);
    }
    @isTest(SeeAllData=true) static void getContactTest(){
        Contact result = MF_ContactCC.getContact('003N000000s9N3W');
        System.assert(result!=null);
    }
    @isTest static void clickLogoutTest(){
        MF_ContactCC mf_con = new MF_ContactCC();
        PageReference result = mf_con.logoutClick();
        System.assert(result!=null);
    }
}