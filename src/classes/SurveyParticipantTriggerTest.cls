@isTest
public class SurveyParticipantTriggerTest {
    @isTest public static void testCheckDoubleSurveyParticipant(){
        Survey__c survey = TestData.createSurvey();
        TestData.createSurveyParticipant(survey.Id);
        try{
            TestData.createSurveyParticipant(survey.Id);
        }catch (DmlException e){
            System.assertEquals(e.getMessage().contains('The User is already existed in this Survey!'), true);
        }
    }
    
    @isTest public static void testCheckAndUpdateSurveyStatusToClosed(){
        Survey__c survey = TestData.createSurvey();
        SurveyParticipant__c surveyParticipant = TestData.createSurveyParticipant(survey.Id);
        
        surveyParticipant.Response_Date__c = date.today();
        surveyParticipant.Response_Completed__c = true;
        update surveyParticipant;
        
        //check Survey_Status__c update to Closed or not
        Survey__c surveyCheckStatus = [select Survey_Status__c from Survey__c where Id = :surveyParticipant.Survey__c];
        System.assertEquals(surveyCheckStatus.Survey_Status__c, 'Closed');
    }
    
    @isTest public static void testCheckSurveyApproved(){
        Survey__c survey = TestData.createSurvey();
        SurveyParticipant__c surveyParticipant = TestData.createSurveyParticipant(survey.Id);
        
        //update survey status for checking delete a surveyParticipant has approved survey
        survey.Survey_Status__c = 'Approved';
        update survey;
        
        try{
            delete surveyParticipant;
        }catch (DmlException e){
            System.assertEquals(e.getMessage().contains('This survey have approved before, so can not delete'), true);
        }        
    }
}