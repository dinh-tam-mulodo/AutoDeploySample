@isTest
public class SurveyCCTest {
	@isTest public static void testInsertSurveyResponses(){
        Survey__c survey = TestData.createSurvey();
        Question__c question = TestData.createQuestion();
        Choice__c choice = new Choice__c (Question__c = question.Id, Choice_Value__c = 'Yes');
        SurveyParticipant__c surveyParticipant = TestData.createSurveyParticipant(survey.Id); 
        SurveyResponse__c surveyResponse = new SurveyResponse__c(Choice__c = choice.Id, Survey_Participant__c = surveyParticipant.Id);
        
        List<SurveyResponse__c> listSurveyResponse = new List<SurveyResponse__c>();
        listSurveyResponse.add(surveyResponse);
        SurveyCC.insertSurveyResponses(listSurveyResponse, surveyParticipant.Id, survey.Id);
        
        //Check insert SurveyResponses success
        SurveyParticipant__c checkCompleted = [select Response_Completed__c from SurveyParticipant__c where Id = :surveyParticipant.Id];
        System.assertEquals(checkCompleted.Response_Completed__c, true);
    }
    
    @isTest public static void testInsertFreeTextChoice(){
        Question__c question = TestData.createQuestion();
        Choice__c choice1 = TestData.createChoiceForQuestion(question.Id);
        Choice__c choice2 = new Choice__c(Choice_Value__c = 'This is new choice for free text');
        
        //Check update Choices success
        Choice__c result1 = [select Id from Choice__c where Id = :choice1.Id limit 1];          
        System.assertEquals(SurveyCC.insertFreeTextChoice(choice1), result1.Id);
        
        //Check insert Choices success
        Id choiceId = SurveyCC.insertFreeTextChoice(choice2);
        Choice__c result2 = [select Id from Choice__c where Id = :choice2.Id limit 1];     
        System.assertEquals(choiceId, result2.Id);
    }
    
    @isTest public static void testGetQuestionsBySurvey(){
        Survey__c survey = TestData.createSurvey();
        Question__c question = TestData.createQuestion();
        SurveyQuestion__c surveyQuestion = TestData.createSurveyQuestion(survey.Id, question.Id);
        
        //Check get list Questions success
        System.assertEquals(SurveyCC.getQuestionsBySurvey(survey.Id).size(), 1);
    }
}