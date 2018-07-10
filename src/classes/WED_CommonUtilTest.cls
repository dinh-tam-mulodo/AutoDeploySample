@isTest
public class WED_CommonUtilTest {
    public static User CreateGuestUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' or Name='システム管理者'];
        User u = new User(Alias = 'WGWeb', Email='test@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='WatabeGuestUser', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='watabe-test@testorg.com');
        return u;
    }

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: getPrefix
    Test Case: Valid data
    */
    @isTest 
    public static void getPrefixTest1(){
        User u = CreateGuestUser();
        System.runAs(u){
            String result = WED_CommonUtil.getPrefix();
            String expectedString = '';
            System.assertEquals(expectedString, result);
        }
    }

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: getPrefix
    Test Case: Valid data
    */
    @isTest 
    public static void getPrefixTest2(){
        User u = CreateGuestUser();
        System.runAs(u){
            String result = WED_CommonUtil.getPrefix();
            String expectedString = '';
            System.assertEquals(expectedString, result);
        }
    }

    /*
    Create By: Tuan
    Test Function: checkFLS
    Test Case: Standard field - Create permission - Invalid
    */
    @isTest 
    public static void checkFLSTest1() {
        User u = CreateGuestUser();
        System.runAs(u){
            String[] listUpdatedFields = new String[]{'Id'};
            String objectName = 'Lead';

            Boolean result = WED_CommonUtil.checkFLS(listUpdatedFields, WED_CommonUtil.FLSType.CREATE_OBJECT, objectName);
            System.assertEquals(false, result);
        }
    }

    /*
    Create By: Tuan
    Test Function: checkFLS
    Test Case: Standard field - Create permission - Valid
    */
    @isTest 
    public static void checkFLSTest2() {
        User u = CreateGuestUser();
        System.runAs(u){
            String[] listUpdatedFields = new String[]{'OwnerId'};
            String objectName = 'Lead';

            Boolean result = WED_CommonUtil.checkFLS(listUpdatedFields, WED_CommonUtil.FLSType.CREATE_OBJECT, objectName);
            System.assertEquals(true, result);
        }
    }

    /*
    Create By: Tuan
    Test Function: checkFLS
    Test Case: Standard field - Update permission - Invalid
    */
    @isTest 
    public static void checkFLSTest3() {
        User u = CreateGuestUser();
        System.runAs(u){
            String[] listUpdatedFields = new String[]{'Id'};
            String objectName = 'Lead';

            Boolean result = WED_CommonUtil.checkFLS(listUpdatedFields, WED_CommonUtil.FLSType.UPDATE_OBJECT, objectName);
            System.assertEquals(false, result);
        }
    }

    /*
    Create By: Tuan
    Test Function: checkFLS
    Test Case: Standard field - Update permission - Valid
    */
    @isTest 
    public static void checkFLSTest4() {
        User u = CreateGuestUser();
        System.runAs(u){
            String[] listUpdatedFields = new String[]{'OwnerId'};
            String objectName = 'Lead';

            Boolean result = WED_CommonUtil.checkFLS(listUpdatedFields, WED_CommonUtil.FLSType.UPDATE_OBJECT, objectName);
            System.assertEquals(true, result);
        }
    }

    /*
    Create By: Dung
    Test Function: checkFLS
    Test Case: Custom field - Create permission - Valid
    */
    @isTest
    public static void checkFLSTest5() {
        User u = CreateGuestUser();
        System.runAs(u){
            String[] listUpdatedFields = new String[]{'WED_IsLock__c'};
            String objectName = 'Lead';
            
            Boolean result = WED_CommonUtil.checkFLS(listUpdatedFields, WED_CommonUtil.FLSType.CREATE_OBJECT, objectName);
            System.assertEquals(true, result);
        }
    }

    /*
    Create By: Dung
    Test Function: checkFLS
    Test Case: Custom field - Update permission - Valid
    */
    @isTest
    public static void checkFLSTest6() {
        User u = CreateGuestUser();
        System.runAs(u){
            String[] listUpdatedFields = new String[]{'WED_IsLock__c'};
            String objectName = 'Lead';
            
            Boolean result = WED_CommonUtil.checkFLS(listUpdatedFields, WED_CommonUtil.FLSType.UPDATE_OBJECT, objectName);
            System.assertEquals(true, result);
        }
    }

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: countRecord(String objectName, string whereStatement)
    Test Case: Valid data
    */
    /*
    @isTest
    public static void countRecordTest1(){
        Account account = new Account(Name = 'Test');
        insert account;
        string whereStatement = ' WHERE Name = \'Test\'';

        Integer intRet = WED_CommonUtil.countRecord('Account', whereStatement);
        System.assertNotEquals(0, intRet);
    }*/

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: countRecord(String objectName, string whereStatement)
    Test Case: invalid condition
    */
    /*
    @isTest
    public static void countRecordTest2(){
        Account account = new Account(Name = 'Test');
        insert account;
        string whereStatement = 'this is not a valid statement';

        Integer intRet = WED_CommonUtil.countRecord('Account', whereStatement);
        System.assertEquals(0, intRet);
    }*/

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: countRecord(String objectName, string whereStatement)
    Test Case: invalid object
    */
    /*
    @isTest
    public static void countRecordTest3(){
        Account account = new Account(Name = 'Test');
        insert account;
        string whereStatement = ' WHERE Name = \'Test\'';

        Integer intRet = WED_CommonUtil.countRecord('This is not an object', whereStatement);
        System.assertEquals(0, intRet);
    }*/

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: formatHeader(String format, String name)
    Test Case: valid data
    */
    @isTest
    public static void formatHeaderTest1(){
        String format = 'This {0} test';
        String name = 'is a';
        String result = WED_CommonUtil.formatHeader(format, name);
        String expectedString = 'This is a test';
        System.assertEquals(expectedString, result);
    }

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: formatHeader(String format, String name)
    Test Case: invalid data
    */
    @isTest
    public static void formatHeaderTest2(){
        String format;
        String name = 'is a';
        String result = WED_CommonUtil.formatHeader(format, name);
        String expectedString = '';
        System.assertEquals(expectedString, result);
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingPicklistToMap(String dataPicklist)
    Test Case:  1 value
    */
    @isTest
    public static void settingPicklistToMapTest1(){
        String dataPicklist = 'strValue';
        Map<String, String> mapExpected = new Map<String, String>();
        mapExpected.put('0', 'strValue');

        Map<String, String> mapActual = WED_CommonUtil.settingPicklistToMap(dataPicklist);

        System.assertEquals(mapExpected.get('0'), mapActual.get('0'));
    }

     /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingPicklistToMap(String dataPicklist)
    Test Case:  Multiple value
    */
    @isTest
    public static void settingPicklistToMapTest2(){
        String dataPicklist = 'strValue1;strValue2';
        Map<String, String> mapExpected = new Map<String, String>();
        mapExpected.put('0', 'strValue1');
        mapExpected.put('1', 'strValue2');

        Map<String, String> mapActual = WED_CommonUtil.settingPicklistToMap(dataPicklist);

        System.assertEquals(mapExpected.get('0'), mapActual.get('0'));
        System.assertEquals(mapExpected.get('1'), mapActual.get('1'));
    }


    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingMapTopickList(Map<String, String> mapOption)
    Test Case:  Map just has one
    */
    @isTest
    public static void settingMapTopickListTest1(){
        Map<String, String> mapInput = new Map<String, String>();
        mapInput.put('strKey1', 'strValue1');

        String strPicklistExpected = 'strValue1';

        String strPicklistActual = WED_CommonUtil.settingMapTopickList(mapInput);

        System.assertEquals(strPicklistExpected, strPicklistActual);
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingMapTopickList(Map<String, String> mapOption)
    Test Case:  Map has multiple
    */
    @isTest
    public static void settingMapTopickListTest2(){
        Map<String, String> mapInput = new Map<String, String>();
        mapInput.put('strKey1', 'strValue1');
        mapInput.put('strKey2', 'strValue2');

        String strPicklistExpected = 'strValue1;strValue2';

        String strPicklistActual = WED_CommonUtil.settingMapTopickList(mapInput);

        System.assertEquals(strPicklistExpected, strPicklistActual);
    }


    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getPicklistField(String objectName, String fieldName, KeyType typ)
    Test Case:  
    */
    @isTest
    public static void getPicklistFieldTest(){
        User u = CreateGuestUser();
        System.runAs(u){
            String objectName = 'Lead';
            String fieldName = 'Gosoudan_Jyoukyou__c';
            Map<String, String> mapExpected = new Map<String, String>();
            mapExpected.put('0', 'value:ワタベウェディングが初めて');
            mapExpected.put('1', 'value:2件目');
            mapExpected.put('2', 'value:3件目');
            mapExpected.put('3', 'value:4件以上');

            Map<String, String> mapActual = WED_CommonUtil.getPicklistField(objectName, fieldName, WED_CommonUtil.KeyType.VALUE);
            System.assertEquals(mapExpected.get('0'), mapActual.get('0'));
            System.assertEquals(mapExpected.get('1'), mapActual.get('1'));
            System.assertEquals(mapExpected.get('2'), mapActual.get('2'));
            System.assertEquals(mapExpected.get('3'), mapActual.get('3'));
        }
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getPicklistFieldForHybridType(String objectName, String fieldName, KeyType typ)
    Test Case:   TODO
    */
    /*@isTest
    public static void getPicklistFieldForHybridTypeTest1(){
        User u = CreateGuestUser();
        System.runAs(u){
            String objectName = 'Lead';
            String fieldName = 'Eturan_Zassi__c';
            List<String> imageIndex = new List<String>();
            imageIndex.add('ゼクシィ海外ウェディング');
            imageIndex.add('ゼクシィ国内リゾートウェディング');
            imageIndex.add('ゼクシィプレミア');
            imageIndex.add('その他（全国紙・その他）');

            Map<String, String> mapReturn = WED_CommonUtil.getPicklistFieldForHybridType(objectName, fieldName, WED_CommonUtil.KeyType.HYBRID);
            
            for(String key : mapReturn.keySet()){
                System.debug('mapReturn: ' + key + ' : ' + mapReturn.get(key));
            }
            
            System.assertEquals('0:ゼクシィ海外ウェディング', mapReturn.get('0'));
            System.assertEquals('1:ゼクシィ国内リゾートウェディング', mapReturn.get('1'));
            System.assertEquals('2:ゼクシィプレミア', mapReturn.get('2'));
            System.assertEquals('item1:その他（全国紙・その他）', mapReturn.get('9'));
        }
    }*/


    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: isCheckBoxType(String label)
    Test Case:  
    */
     @isTest
    public static void isCheckBoxTypeTest1(){

        String lable = WED_Constants.ANS20_ITEM3;
        Boolean valRet = WED_CommonUtil.isCheckBoxType(lable);

        System.assertEquals(true, valRet);
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: isCheckBoxType(String label)
    Test Case:  
    */
     @isTest
    public static void isCheckBoxTypeTest2(){

        String lable = 'WRONGVALUE';
        Boolean valRet = WED_CommonUtil.isCheckBoxType(lable);

        System.assertEquals(false, valRet);
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getStringByKeyType(KeyType typ, Integer index)
    Test Case:  PARENT
    */
     @isTest
    public static void getStringByKeyTypeTest1(){

        User u = CreateGuestUser();
        System.runAs(u){
            Integer intIn = 1;
            String expected = 'parent';

            //Boolean result = WED_CommonUtil.checkFLS(listUpdatedFields, WED_CommonUtil.FLSType.CREATE_OBJECT, objectName);
            String actual = WED_CommonUtil.getStringByKeyType(WED_CommonUtil.KeyType.PARENT, intIn);
            System.assertEquals(expected, actual);
        }
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getStringByKeyType(KeyType typ, Integer index)
    Test Case:  CHILD
    */
     @isTest
    public static void getStringByKeyTypeTest2(){

        User u = CreateGuestUser();
        System.runAs(u){
            Integer intIn = 1;
            String expected = 'child';

            //Boolean result = WED_CommonUtil.checkFLS(listUpdatedFields, WED_CommonUtil.FLSType.CREATE_OBJECT, objectName);
            String actual = WED_CommonUtil.getStringByKeyType(WED_CommonUtil.KeyType.CHILD, intIn);
            System.assertEquals(expected, actual);
        }
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getStringByKeyType(KeyType typ, Integer index)
    Test Case:  VALUE
    */
     @isTest
    public static void getStringByKeyTypeTest3(){

        User u = CreateGuestUser();
        System.runAs(u){
            Integer intIn = 1;
            String expected = 'value';

            String actual = WED_CommonUtil.getStringByKeyType(WED_CommonUtil.KeyType.VALUE, intIn);
            System.assertEquals(expected, actual);
        }
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getStringByKeyType(KeyType typ, Integer index)
    Test Case:  INDEX
    */
     @isTest
    public static void getStringByKeyTypeTest4(){

        User u = CreateGuestUser();
        System.runAs(u){
            Integer intIn = 1;
            String expected = '1';

            String actual = WED_CommonUtil.getStringByKeyType(WED_CommonUtil.KeyType.INDEX, intIn);
            System.assertEquals(expected, actual);
        }
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getStringByKeyType(KeyType typ, Integer index)
    Test Case:  else
    */
     @isTest
    public static void getStringByKeyTypeTest5(){

        User u = CreateGuestUser();
        System.runAs(u){
            Integer intIn = 1;
            String expected = 'item2';

            String actual = WED_CommonUtil.getStringByKeyType(WED_CommonUtil.KeyType.HYBRID, intIn);
            System.assertEquals(expected, actual);
        }
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: formatPicklistMap(Map<String, String> pickListMap, Map<String,String> answerMap)
    Test Case:  
    */
     @isTest
    public static void formatPicklistMapTest1(){

        Map<String, String> mapInput = new Map<String, String>();
        mapInput.put('0', 'item1:value1');
        mapInput.put('1', 'item2:value2');
        mapInput.put('2', 'item3:value3');

        Map<String, String> mapRaw = new Map<String, String>();
        mapRaw.put('0', 'value1');
        mapRaw.put('1', 'value2');
        mapRaw.put('2', 'value4');

        Map<String, String> mapExpected = new Map<String, String>();
        mapExpected.put('item1', 'value1');
        mapExpected.put('item2', 'value2');

        Map<String, String> mapActual = WED_CommonUtil.formatPicklistMap(mapInput, mapRaw);

        System.assertEquals(mapExpected.get('item1'), mapActual.get('item1'));
        System.assertEquals(mapExpected.get('item2'), mapActual.get('item2'));

    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getIndexFromList(List<String> container, String value)
    Test Case:  Contain
    */
     @isTest
    public static void getIndexFromListTest1(){
        List<String> container = new List<String>();
        container.add('value1');
        container.add('value2');
        container.add('value3');
        String value = 'value1';

        Integer actual = WED_CommonUtil.getIndexFromList(container, value);
        System.assertEquals(0, actual);
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getIndexFromList(List<String> container, String value)
    Test Case:  Not Contain
    */
     @isTest
    public static void getIndexFromListTest2(){
        List<String> container = new List<String>();
        container.add('value1');
        container.add('value2');
        container.add('value3');
        String value = 'value4';

        Integer actual = WED_CommonUtil.getIndexFromList(container, value);
        System.assertEquals(-1, actual);
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getFormatString(List<String> values, String rawString)
    Test Case:  Data is not empty
    */
     @isTest
    public static void getFormatStringTest1(){

        List<String> lstInput = new List<String>();
        lstInput.add('dataInput');
        lstInput.add('key:data');
        lstInput.add('daInput');

        String rawString = 'data';
        String expected = 'key:data';

        String actual = WED_CommonUtil.getFormatString(lstInput, rawString);

        System.assertEquals(expected, actual);
    }

    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getFormatString(List<String> values, String rawString)
    Test Case:  
    */
     @isTest
    public static void getFormatStringTest2(){

        List<String> lstInput = new List<String>();
        lstInput.add('dataInput');
        lstInput.add('Input');
        lstInput.add('daInput');

        String rawString = 'dataNotExist';
        String expected = '';

        String actual = WED_CommonUtil.getFormatString(lstInput, rawString);

        System.assertEquals(expected, actual);
    }
   
    /*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: getImageList()
    Test Case:  
    */
    @isTest(SeeAllData=true)
    public static void getListImageTest1(){
        String strFolderName = 'WatabeWedding';
        List<Document> currentPictures = [SELECT ID,URL,Name FROM Document 
                                              WHERE Folder.Name =: strFolderName
                                              LIMIT 2000];
        Document document = currentPictures.get(0);

        List<String> lstImageReturn = WED_CommonUtil.getImageList();

        System.assertEquals(currentPictures.size(), lstImageReturn.size());
        System.assertEquals(document.Name, lstImageReturn.get(0));
    }    
}