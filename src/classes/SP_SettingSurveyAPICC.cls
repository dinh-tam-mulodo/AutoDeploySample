/**
 * Class: SP_SettingSurveyAPICC
 * Author: tran.binh
 * Description: process register data token and ip address
 */
global with sharing class SP_SettingSurveyAPICC {

    @RemoteAction
    public static String toRegister ( String  token,
                                      String  ipAddress
                                    ) {
        SP_SettingSurveyAPI__c settingSurveyAPI = new SP_SettingSurveyAPI__C();
        SP_SettingSurveyAPI__c surveyAPI = [SELECT Id, SP_Token__c FROM SP_SettingSurveyAPI__c];

        settingSurveyAPI.Id = surveyAPI.Id;
        settingSurveyAPI.SP_Token__c     = token;
        settingSurveyAPI.SP_IPAddress__c = ipAddress;
        //declare variable Savepoint for rollback data when the problem occurred
        Savepoint sp = Database.setSavepoint();

        try {
            upsert settingSurveyAPI;
        } catch ( DmlException ex ) {
            //rollback data when upsert error.
            Database.rollback(sp);
            return ex.getMessage();
        }

        return surveyAPI.Id;
    }

    @RemoteAction
    public static SP_SettingSurveyAPI__c getSettingSurveyAPI() {
        //select SP_Token__c, SP_IPAddress__c
        SP_SettingSurveyAPI__c settingSurveyAPIResult = [SELECT SP_Token__c, SP_IPAddress__c FROM SP_SettingSurveyAPI__c];
        return settingSurveyAPIResult;
    }

}