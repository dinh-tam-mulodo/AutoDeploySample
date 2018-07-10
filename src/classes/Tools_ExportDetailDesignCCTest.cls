@isTest
public class Tools_ExportDetailDesignCCTest {
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
    // org test data 
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
    public static void testConstructor(){
        Nle_Org_Config__c org = [Select id From Nle_Org_Config__c limit 1];
        Test.setCurrentPageReference(new PageReference('Page.NleExportDetailDesign'));
		System.currentPageReference().getParameters().put('state', org.Id);
        Tools_ExportDetailDesignCC ctrl = new Tools_ExportDetailDesignCC();
        // set value field
        ctrl.BLANKVALUE = '';
        String temp = ctrl.HEADER_1;
        ctrl.HEADER_1 = '';
        temp = ctrl.HEADER_2;
        ctrl.HEADER_2 = '';
        temp = ctrl.HEADER_3;
        ctrl.HEADER_3 = '';
        temp = ctrl.xlsHeader;
        ctrl.jObjects = new List<JObject>();        
        ctrl.jProfiles = new List<JProfile>();
        //ctrl.jProfileDetails = new List<Tools_calloutJSONProfile>();
        ctrl.currentSelectedObjects = new Set<String>();
        ctrl.validationRuleDetails = new List<Tools_ValidationRuleDetail>();
        ctrl.defaultUserPermissions = new Set<String>();
        ctrl.profilePermissions = new List<Map_Object.ProfileUserPermission>();
        ctrl.standardObjectPermissons = new List<Map_Object.ObjectPermission>();
        ctrl.customObjectPermissons = new List<Map_Object.ObjectPermission>();
        ctrl.getOrgs();
    }
    @isTest 
    public static void conectToOrgTest(){
        Nle_Org_Config__c org = [Select Id From Nle_Org_Config__c limit 1 ];
        Tools_SingleRequestMock mock = new Tools_SingleRequestMock();
        mock.jsonBody = JSON.serialize(org);        
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Tools_JsonResult rs = Tools_ExportDetailDesignCC.connectToOrg(org.Id);
        Test.stopTest();
        system.assert(!rs.isError);
    }
     @isTest 
    public static void getObjectsTest(){
        Nle_Org_Config__c org = buildOrg();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ObjectsCallOut');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);         
        Test.startTest();
        List<JObject> rs = Tools_ExportDetailDesignCC.getObjects(org);
		//system.debug('debug:' + rs);        
        Test.stopTest();
        system.assertEquals(rs.size(), 334);
    }
    @isTest
    public static void getValidationRulesTest(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ValidationRulesCallOut');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Nle_Org_Config__c org = [Select Id,Selected_Objects__c,Selected_Profile__c,Token_Expire_On__c From Nle_Org_Config__c limit 1];
        org.Selected_Objects__c = 'Contact';
        org.Selected_Profile__c = 'System Administrator';
        org.Token_Expire_On__c = system.now().addHours(-1);
        update org;
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.NleExportDetailDesign'));
		System.currentPageReference().getParameters().put('state', org.Id);
        Tools_ExportDetailDesignCC ctrl = new Tools_ExportDetailDesignCC();
        ctrl.getValidationRuleDetail();
		//system.debug('debug:' + rs);        
        Test.stopTest();
        system.assertEquals(ctrl.validationRuleDetails.size(),0);
    }
     @isTest 
    public static void getObjectDetailTest(){        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ObjectDetailCallOut');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);    
        Nle_Org_Config__c org = [Select Id,Selected_Objects__c,Selected_Profile__c,Token_Expire_On__c From Nle_Org_Config__c limit 1];
        org.Selected_Objects__c = 'Contact';
        org.Selected_Profile__c = 'System Administrator';
        org.Token_Expire_On__c = system.now().addHours(-1);
        update org;
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.NleExportDetailDesign'));
		System.currentPageReference().getParameters().put('state', org.Id);
        Tools_ExportDetailDesignCC ctrl = new Tools_ExportDetailDesignCC();
        List<nleCalloutJSONObject> rs = ctrl.getJObjectDetails();		     
        Test.stopTest();
        nleCalloutJSONObject obj = rs[0];
        system.assertEquals(rs.size(), 1);
    }
     @isTest 
    public static void saveConfigTest(){
        Nle_Org_Config__c org = [Select Id from Nle_Org_Config__c limit 1];
        Test.startTest();
        Tools_JsonResult rs = Tools_ExportDetailDesignCC.saveConfig(org.Id,'Contact', 'System Administrator');
        Test.stopTest();
        system.assert(!rs.isError);
    }
    @isTest 
    public static void getProfilesTest(){
        Nle_Org_Config__c org = buildOrg();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ProfilesCallOut');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);       
        Test.startTest();
        List<JProfile> rs = Tools_ExportDetailDesignCC.getProfiles(org);   
        //system.debug(rs);
        Test.stopTest();
        system.assertEquals(rs.size(), 37);
    }
    @isTest 
    public static void getProfileDetailTest(){        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ProfileDetailCallOut');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);    
        Nle_Org_Config__c org = [Select Id,Selected_Objects__c,Selected_Profile__c,Token_Expire_On__c From Nle_Org_Config__c limit 1];
        org.Selected_Objects__c = 'Contact';
        org.Selected_Profile__c = 'System Administrator';
        org.Token_Expire_On__c = system.now().addHours(-1);
        update org;
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.NleExportDetailDesign'));
		System.currentPageReference().getParameters().put('state', org.Id);
        Tools_ExportDetailDesignCC ctrl = new Tools_ExportDetailDesignCC();
        List<Tools_calloutJSONProfile> rs = ctrl.getJProfileDetails();		     
        Test.stopTest();
        system.assertEquals(rs.size(), 1);
    }
    
    @isTest
    public static void getProfileObjectPermissionTest(){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ProfileObjectPermissionCallOut');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);    
        Profile p = [Select Id From Profile Where Name = 'System Administrator' or Name='システム管理者' limit 1];
        Nle_Org_Config__c org = [Select Id,Selected_Objects__c,Selected_Profile__c,Token_Expire_On__c From Nle_Org_Config__c limit 1];
        org.Selected_Objects__c = 'Contact';
        org.Selected_Profile__c = p.Id;
        org.Token_Expire_On__c = system.now().addHours(-1);
        update org;
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.NleExportDetailDesign'));
		System.currentPageReference().getParameters().put('state', org.Id);
        Tools_ExportDetailDesignCC ctrl = new Tools_ExportDetailDesignCC();
        ctrl.getProfileObjectPermission();
        Test.stopTest();
        system.assertEquals(ctrl.standardObjectPermissons.size(), 1);
    }
    
    @isTest
    public static void connectToOrgRaiseErrorTest(){
        Nle_Org_Config__c org = [Select Id From Nle_Org_Config__c limit 1 ];
        update org;
        Tools_SingleRequestMock mock = new Tools_SingleRequestMock();
        mock.jsonBody = JSON.serialize(org);        
        Test.setMock(HttpCalloutMock.class, mock);
        Tools_JsonResult rs = Tools_ExportDetailDesignCC.connectToOrg(org.Id);
        system.assert(rs.isError);
    }
}