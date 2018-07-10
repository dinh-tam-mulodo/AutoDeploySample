@isTest
public class TestData {
    public static Survey__c createSurvey(){
        Survey__c survey = new Survey__c(Name='test Survey');
        insert survey;
        return survey;
    }
    
    public static Question__c createQuestion(){
        Question__c question = new Question__c (Question_Text__c = 'Is this test question?', Question_Type__c = 'Yes/No');
        insert question;
        return question;
    }
    
    public static Choice__c createChoiceForQuestion(String questionId){
        Choice__c choice = new Choice__c (Question__c = questionId, Choice_Value__c = 'Yes');
        insert choice;
        return choice;
    }
    
    public static SurveyParticipant__c createSurveyParticipant(String surveyId){
        String userId = UserInfo.getUserId();
        SurveyParticipant__c surveyParticipant = new SurveyParticipant__c(Survey__c = surveyId, User__c = userId);
        insert surveyParticipant;
        return surveyParticipant;
    }
        
    public static SurveyResponse__c createSurveyResponse(String choiceId, String surveyParticipantId){        
        SurveyResponse__c surveyResponse = new SurveyResponse__c(Choice__c = choiceId, Survey_Participant__c = surveyParticipantId);
        insert surveyResponse;
        return surveyResponse;
    }
    
    public static SurveyQuestion__c createSurveyQuestion(String surveyId, String questionId){
        SurveyQuestion__c surveyQuestion = new SurveyQuestion__c(Survey__c = surveyId, Question__c = questionId);
        insert surveyQuestion;
        return surveyQuestion;
    }
}