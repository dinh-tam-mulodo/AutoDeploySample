@isTest
public class SurveyParticipantCCTest {
    @isTest public static void testGetSurveysList(){
        Survey__c survey = TestData.createSurvey();
        SurveyParticipant__c surveyParticipant = TestData.createSurveyParticipant(survey.Id);        
        
        //Approved survey
        survey.Survey_Status__c = 'Approved';
        update survey;
        
        //check get list surveys of user
        System.assertEquals(SurveyParticipantCC.getSurveysOfUser().size(), 1);
        
        //check get list surveys of user by SurveyID
        System.assertEquals(SurveyParticipantCC.getSurveysOfUserBySurveyID(survey.Id).size(), 1);
        
        //check get list surveys are managed by Manager
        String userId = UserInfo.getUserId();        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  
        User staff = new User(LastName = 'LIVESTON',
                             FirstName='JASON',
                             Alias = 'jliv',
                             Email = 'jason.liveston@asdf.com',
                             Username = 'jason.liveston@asdf.com',
                             ProfileId = profileId.id,
                             TimeZoneSidKey = 'GMT',
                             LanguageLocaleKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             LocaleSidKey = 'en_US',
                             ManagerId = userId
                             );
        insert staff;
        
        Survey__c surveyOfStaff = new Survey__c(Name = 'test', OwnerId = staff.Id);
        insert surveyOfStaff;
        
        //Approved survey
        surveyOfStaff.Survey_Status__c = 'Approved';
        update surveyOfStaff;
        
        System.assertEquals(SurveyParticipantCC.getSurveysHandleByManager().size(), 1);
    }
}