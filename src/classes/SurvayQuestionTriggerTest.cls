@isTest
public class SurvayQuestionTriggerTest {
    @isTest public static void testCheckAlreadyExistedInSurvey (){
        Survey__c survey = TestData.createSurvey();
        Question__c question = TestData.createQuestion();
        //insert question to survey
        TestData.createSurveyQuestion(survey.Id, question.Id);
        
        //insert again this question to survey
        try{
            TestData.createSurveyQuestion(survey.Id, question.Id);
        }catch (DmlException e){
            System.assertEquals(e.getMessage().contains('The Question is already existed in this Survey!'), true);            
        }        
    }
    
    @isTest public static void testCheckSurveyApproved() {
        Survey__c survey = TestData.createSurvey();
        Question__c question = TestData.createQuestion();
        SurveyQuestion__c surveyQuestion = TestData.createSurveyQuestion(survey.Id, question.Id);
        
        //update survey status for checking delete a surveyQuestion has approved survey
        survey.Survey_Status__c = 'Approved';
        update survey;
        
        try{
            delete surveyQuestion;
        }catch (DmlException e){
            System.assertEquals(e.getMessage().contains('This survey have approved before, so can not delete'), true);
        }
    }
}