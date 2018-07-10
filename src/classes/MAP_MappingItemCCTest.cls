@isTest
public class MAP_MappingItemCCTest {
    public static final String MAP_ACCOUNT_ITA  = '{"Name":"Shogo__c"}';
    public static final String MAP_LEAD_ITA  = '{"Company":"Shogo__c","LastName":"Name"}';

    private static void createDataSaveAction() {
    	List<MAP_ItemMapping__c> lstResult = new List<MAP_ItemMapping__c>();
    	lstResult = [SELECT Id, Account_ITA__c, Lead_ITA__c
    	               FROM MAP_ItemMapping__c];
    	if(lstResult != null && lstResult.size() > 0) {
    		delete lstResult;
    	}
    }

    @isTest
    public static void saveActionTest(){
        createDataSaveAction();
        MAP_JsonResult result = MAP_MappingItemCC.saveAction(MAP_ACCOUNT_ITA, MAP_LEAD_ITA);
        List<MAP_ItemMapping__c> lstItemMapping = [SELECT Id, Account_ITA__c, Lead_ITA__c
    	               					          FROM MAP_ItemMapping__c];
        System.assertEquals(result.success , true);

        System.assertEquals(lstItemMapping.get(0).Account_ITA__c.equalsIgnoreCase(MAP_ACCOUNT_ITA) , true);
        System.assertEquals(lstItemMapping.get(0).Lead_ITA__c.equalsIgnoreCase(MAP_LEAD_ITA) , true);
    }
}