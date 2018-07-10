public class SurveyParticipantCC {
	@AuraEnabled
    public static List<SurveyParticipant__c> getSurveysOfUser(){
        String userId = UserInfo.getUserId();
        List<SurveyParticipant__c> surveyParticipants = [select User__c, Survey__c, Response_Date__c, Response_Completed__c, Survey__r.Name, 
                                                         Survey__r.Survey_Expiration_Date__c, Survey__r.Survey_Welcome_Message__c, Survey__r.Survey_Exit_Message__c
                                                         from SurveyParticipant__c where User__c = :userId and Survey_Approved__c = true order by Survey__r.Survey_Expiration_Date__c desc];
        return surveyParticipants;
    }
    
    @AuraEnabled
    public static List<SurveyParticipant__c> getSurveysOfUserBySurveyID(String surveyId){
        List<SurveyParticipant__c> surveyParticipants = [select User__r.FirstName, User__r.LastName, Survey__c, Response_Date__c, Response_Completed__c, Survey__r.Name, 
                                                         Survey__r.Survey_Expiration_Date__c, Survey__r.Survey_Welcome_Message__c, Survey__r.Survey_Exit_Message__c
                                                         from SurveyParticipant__c where Survey__c = :surveyId  order by Survey__r.Survey_Expiration_Date__c desc];
        return surveyParticipants;
    }
    
    @AuraEnabled
    public static List<Survey__c> getSurveysHandleByManager(){
        String userId = UserInfo.getUserId();
        
        List<User> listUser = [select Id from User where ManagerId = :userId];
		List<Survey__c> listSurveys = [select Name, Survey_Expiration_Date__c, Survey_Status__c from Survey__c where OwnerId = :listUser and (Survey_Status__c = 'Approved' or Survey_Status__c = 'Closed')
                                       order by Survey_Expiration_Date__c desc];
        return listSurveys;
    }
}