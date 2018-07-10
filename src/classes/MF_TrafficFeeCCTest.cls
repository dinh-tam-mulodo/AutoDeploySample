@isTest
public class MF_TrafficFeeCCTest {
	@isTest
    public static void constructorTest(){
        Contact contact = new Contact();
        contact = createDataTest();
        MF_CookieUtil.setCookieValue(MF_CookieUtil.COOKIE_CONTACT_ID, contact.Id, MF_CookieUtil.COOKIE_PATH, true);
        MF_TrafficFeeCC mfTrafficFeeCC = new MF_TrafficFeeCC();
    }
    
    @isTest
    public static void constructorFailTest(){
        Id id = '001N000000wN8ku';
        system.assertEquals(MF_TrafficFeeCC.checkUsernameExist(id), null);
    }
    
    @isTest
    public static void getListVehicleTest(){
        system.assertEquals(MF_TrafficFeeCC.getListVehicle().size(), 0);
    }
    
    @isTest
    public static void getListPlaceTest(){
        system.assertEquals(MF_TrafficFeeCC.getListPlace().size(), 0);
    }
    
    @isTest
    public static void getAllAccountTest(){
        system.assertEquals(MF_TrafficFeeCC.getAllAccount().size(), 0);
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