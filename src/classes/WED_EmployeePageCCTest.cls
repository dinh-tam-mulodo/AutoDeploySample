@isTest
public class WED_EmployeePageCCTest {
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
    Test Function: redirectSurvey
    Test Case: Valid data
    */
    @isTest 
    public static void redirectSurveyTest1(){
        User u = CreateGuestUser();
        System.runAs(u){
            String token = 'abc';
            Test.startTest();
            WED_EmployeePageCC.redirectSurvey(token);
            Test.stopTest();
        }
    }

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: redirectPrint
    Test Case: Valid data
    */
    @isTest 
    public static void redirectPrintTest1(){
        User u = CreateGuestUser();
        System.runAs(u){
            String token = 'abc';
            Test.startTest();
            WED_EmployeePageCC.redirectPrint(token);
            Test.stopTest();
        }
    }

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: buildWhereStatement
    Test Case: Valid data
    */
    @isTest 
    public static void buildWhereStatementTest1(){
        //String expectedResult = ' WHERE (Name LIKE \'%Condition%\' OR Phone LIKE \'%Condition%\' OR WS_Tourokubangou__c LIKE \'%Condition%\') AND workSheetToken__c != null';
        String expectedResult = ' WHERE (WS_Tourokubangou__c LIKE \'Condition\' OR PhoneSearch__c = \'Condition\') AND workSheetToken__c != null';
        String condition = 'Condition';

        String result = WED_EmployeePageCC.buildWhereStatement(condition);

        System.assertEquals(expectedResult, result);
    }

    /*
    Created Date: 22/11/17
    Create By: Minh Tuan
    Test Function: buildWhereStatement
    Test Case: Valid data
    */
    @isTest 
    public static void buildWhereStatementTest2(){
        //String expectedResult = ' WHERE (Name LIKE \'%Cond-ition%\' OR Phone LIKE \'%Cond%ition%\' OR WS_Tourokubangou__c LIKE \'%Cond-ition%\') AND workSheetToken__c != null';
        String expectedResult = ' WHERE (WS_Tourokubangou__c LIKE \'Cond-ition\' OR PhoneSearch__c = \'Condition\') AND workSheetToken__c != null';
        String condition = 'Cond-ition';

        String result = WED_EmployeePageCC.buildWhereStatement(condition);

        System.assertEquals(expectedResult, result);
    }

    
    /*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: buildQuery
    Test Case: Valid data
    */
    @isTest 
    public static void buildQueryTest1(){
        String expectedResult = 'SELECT WS_Tourokubangou__c, Name, Phone, workSheetToken__c FROM Lead ';
        //expectedResult += ' WHERE (Name LIKE \'%Condition%\' OR Phone LIKE \'%Condition%\' OR WS_Tourokubangou__c LIKE \'%Condition%\') AND workSheetToken__c != null';
        expectedResult += ' WHERE (WS_Tourokubangou__c LIKE \'Condition\' OR PhoneSearch__c = \'Condition\') AND workSheetToken__c != null';
        expectedResult += ' LIMIT 1 OFFSET 2';
        String condition = 'Condition';

        String result = WED_EmployeePageCC.buildQuery(condition, 1 , 2);

        System.assertEquals(expectedResult, result);
    }
    
     /*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: getLeadByNameOrPhone
    Test Case: Valid data
    */
    @isTest 
    public static void getLeadByNameOrPhone1(){
        Boolean expectedResult = true;
        
        String condition = 'Condition';
        Integer paramLimit = 1;
        Integer offset = 2;

        WED_JsonResult result = WED_EmployeePageCC.getLeadByNameOrPhone(condition, paramLimit, offset);

        System.assertEquals(expectedResult, result.success);
    }
}