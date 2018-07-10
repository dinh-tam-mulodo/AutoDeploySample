@isTest
public class MAP_ConnectionSettingsCCTest {

    @isTest
    public static void saveConnectionSettingTest() {
    	MAP_ConnectionSetting__c setting = new MAP_ConnectionSetting__c();
        setting.AuthenticationID__c = 'toBema01';
		setting.Endpoint__c = 'http://target.b2.beegle.jp/target/apist/';
		setting.TobeMEndpoint__c = 'https://mactrl.maplus.net/targetsearch/maplusTargetSearchManager.php';
		setting.IsUseCompanyInfo__c = false;
		insert setting;

        String parameter = '{"IsUseCompanyInfo__c":"true",'
                          +'"AuthenticationID__c":"toBema01",'
                          +'"Endpoint__c":"http://target.b2.beegle.jp/target/apist/",'
                          +'"TobeMEndpoint__c":"https://mactrl.maplus.net/targetsearch/maplusTargetSearchManager.php"}';
       
        MAP_JsonResult result = MAP_ConnectionSettingsCC.saveConnectionSetting(parameter);
        System.assertEquals(result.success,true);
    }

}