@isTest
public class MAP_CommonUtilTest {

	public static final String URL_CALL_OUT_VALID  = 'xxxxx';
	public static final String URL_CALL_OUT_IN_VALID  = 'xxxxx';

    @isTest
    public static void getObjectFieldsTest1() {
    	Map<String, String> mapResult = MAP_CommonUtil.getObjectFields('Account');
    	System.assertEquals(mapResult.size() > 0, true);
    }

    @isTest
    public static void getObjectFieldsTest2() {
    	Map<String, String> mapResult = MAP_CommonUtil.getObjectFields('MAP_ItemMapping__c');
    	System.assertEquals(mapResult.size() > 0, true);
    }
    
    @isTest
    public static void getObjectTypeFieldsTest1() {
		Map<String, String> mapResult = MAP_CommonUtil.getObjectTypeFields('Account');
    	System.assertEquals(mapResult.size() > 0, true);
	}

	@isTest
    public static void getObjectTypeFieldsTest2() {
		Map<String, String> mapResult = MAP_CommonUtil.getObjectTypeFields('MAP_ItemMapping__c');
    	System.assertEquals(mapResult.size() > 0, true);
	}

	@isTest
    public static void checkFLSTest1() {
		String[] listUpdatedFields = new String[]{'Id'};
		Map<String,Schema.SObjectField> fieldMaps = Schema.SObjectType.MAP_ItemMapping__c.fields.getMap();
    	Boolean result = MAP_CommonUtil.checkFLS(listUpdatedFields, MAP_CommonUtil.FLSType.CREATE_OBJECT, fieldMaps);
    	System.assertEquals(result, false);
    }

    @isTest
    public static void checkFLSTest2() {
		String[] listUpdatedFields = new String[]{'CreatedBy'};
		Map<String,Schema.SObjectField> fieldMaps = Schema.SObjectType.MAP_ItemMapping__c.fields.getMap();
    	Boolean result = MAP_CommonUtil.checkFLS(listUpdatedFields, MAP_CommonUtil.FLSType.UPDATE_OBJECT, fieldMaps);
    	System.assertEquals(result, false);
    }

    // Custom fields
    @isTest
    public static void checkFLSTest3() {

    }

    @isTest
    public static void checkFLSTest4() {
    	
    }

    @isTest
    public static void calloutRESTApiTest1(){
    	String strRet = MAP_CommonUtil.calloutRESTApi(URL_CALL_OUT_IN_VALID);
    	System.assertEquals(null, strRet);
    }

    @isTest
    public static void calloutRESTApiTest2(){
    	String strRet = MAP_CommonUtil.calloutRESTApi(URL_CALL_OUT_VALID);
    	System.assertNotEquals(null, strRet);
    }

    @isTest
    public static void calloutRESTApiMethodPostTest1(){
    	String body = 'xxx';
    	String strRet = MAP_CommonUtil.calloutRESTApiMethodPost(URL_CALL_OUT_IN_VALID, body);
    	System.assertEquals(null, strRet);
    }

    @isTest
    public static void calloutRESTApiMethodPostTest2(){
    	String body = 'yyy';
    	String strRet = MAP_CommonUtil.calloutRESTApiMethodPost(URL_CALL_OUT_VALID, body);
    	System.assertNotEquals(null, strRet);
    }

    @isTest
    public static void countRecordTest1(){
    	Account account = new Account(Name = 'Test');
    	insert account;

    	Integer intRet = MAP_CommonUtil.countRecord('Account');
    	System.assertNotEquals(0, intRet);
    }

    @isTest
    public static void countRecordTest2(){
    	Integer intRet = MAP_CommonUtil.countRecord('Test_CCC');
    	System.assertEquals(0, intRet);
    }
}