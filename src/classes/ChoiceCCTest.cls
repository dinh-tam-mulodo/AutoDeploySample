@isTest
public class ChoiceCCTest {
	@isTest public static void testGetChoices(){    
        Survey__c survey = TestData.createSurvey();
        Question__c question = TestData.createQuestion();
        Choice__c choice = TestData.createChoiceForQuestion(question.Id);
        SurveyParticipant__c surveyParticipant = TestData.createSurveyParticipant(survey.Id);        
        SurveyResponse__c surveyResponse = TestData.createSurveyResponse(choice.Id, surveyParticipant.Id);
        List<Choice__c> listChoices1;
        List<Choice__c> listChoices2;
        
        //Check list choice has been answered
        listChoices1 = ChoiceCC.getChoices(question.Id, surveyParticipant.Id, 'true');
        System.assertEquals(listChoices1.get(0).Is_Choice_By_User__c, true);
        
        //Check list choice has not been answered
        listChoices2 = ChoiceCC.getChoices(question.Id, surveyParticipant.Id, 'false');        
        System.assertEquals(listChoices2.get(0).Is_Choice_By_User__c, false);
    }
}