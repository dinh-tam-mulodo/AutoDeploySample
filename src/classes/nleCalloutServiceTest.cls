@isTest
public class nleCalloutServiceTest {     
    @testSetup static void setup(){ 
        RecordType rt = [Select Id,Name From RecordType where name = 'Username-password flow'];
        Nle_Org_Config__c org = new Nle_Org_Config__c();
        org.RecordTypeId = rt.Id;
        org.Client_Id__c = '3MVG9ZL0ppGP5UrBxs_uVMgJrmoqpp6sf6gzwOOIR.01yJxcxtHWkkjQ6DaD02BGMsqHyZTK03M3HPA.b1N1_';
        org.Client_Secret__c = '5349282892986375278';
        org.Username__c = 'dinh.tam@mulodo.com';
        org.Password__c = 's09391276000';
        org.Token_Expire_On__c = system.now().addHours(-1);
        Tools_SingleRequestMock mock = new Tools_SingleRequestMock();
        mock.calloutMethod = 'up_token';
        mock.jsonBody = JSON.serialize(org);        
        Test.setMock(HttpCalloutMock.class, mock);
        nleCalloutResult result = nleCalloutService.up_getToken(org);
        //org.Access_Token__c = '00D28000001csa1!ARMAQIYTXelNlMry84folRfJRCFfkbKFX55.DZh1T4TLjO9gX.HDWMYFQqGKQ34LNPEPbHcqy1hPWVEgcW.zFhRhM4iCnjH0';
        insert org;
        system.debug(org);
    } 
    private static Nle_Org_Config__c buildOrg(){ 
       	RecordType rt = [Select Id,Name From RecordType where name = 'Username-password flow'];
        Nle_Org_Config__c org = new Nle_Org_Config__c();
        org.RecordType = rt;
        org.Client_Id__c = '3MVG9ZL0ppGP5UrBxs_uVMgJrmoqpp6sf6gzwOOIR.01yJxcxtHWkkjQ6DaD02BGMsqHyZTK03M3HPA.b1N1_';
        org.Client_Secret__c = '5349282892986375278';
        org.Username__c = 'dinh.tam@mulodo.com';
        org.Password__c = 's09391276000';
        org.Token_Expire_On__c = system.now().addHours(-1);
        //nleCalloutResult result = nleCalloutService.up_getToken(org);
		return org;
    }
    @isTest
    public static void getValidationRuleDetailTest(){
       StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ValidationRuleDetailCallOut');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);    
        Nle_Org_Config__c org = [Select Id, Name, Client_Id__c,Refresh_Token__c, Client_Secret__c, Username__c, Password__c, Redirect_URL__c,
                                                         Access_Token__c, Token_Expire_On__c, Environment_URL__c, Selected_Objects__c,Selected_Profile__c, RecordType.Name From Nle_Org_Config__c limit 1];
        org.Selected_Objects__c = 'Contact';
        org.Selected_Profile__c = 'System Administrator';
        org.Token_Expire_On__c = system.now().addHours(-1);
        update org;
        Test.startTest();        
        String endpoint = 'https://ap2.salesforce.com/services/data/v37.0/tooling/sobjects/ValidationRule/03d28000000kHGVAA2';
        nleCalloutResult rs = nleCalloutService.getValidationRuleDetail(org,endpoint);		     
        Test.stopTest();
        system.assert(!rs.hasError);
    }
}