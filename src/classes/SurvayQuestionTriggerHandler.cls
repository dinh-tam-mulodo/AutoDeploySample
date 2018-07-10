/**
 * @description: define fucntions to support for trigger of SurveyQuestion__c object
 * 
 **/
public class SurvayQuestionTriggerHandler {
	public static void checkAlreadyExistedInSurvey(List<SurveyQuestion__c> surveyQuestionList) {
        Set <String> SID = new Set <String>();
        for(SurveyQuestion__c surveyQuestion : surveyQuestionList){
            SID.add(surveyQuestion.Survey__c);
        }
        List<SurveyQuestion__c> SurveyQuestionAll = [SELECT Id, Survey__c, Question__c FROM SurveyQuestion__c WHERE Survey__c IN :SID];
        for(SurveyQuestion__c surveyQuestion : surveyQuestionList){
            for(SurveyQuestion__c surveyQuestionCond : SurveyQuestionAll){
                if (surveyQuestionCond.Survey__c == surveyQuestion.Survey__c &&
                   	surveyQuestionCond.Question__c == surveyQuestion.Question__c &&
                    surveyQuestionCond.Id != surveyQuestion.Id) {
                       surveyQuestion.addError('The Question is already existed in this Survey!');
                 }
            }
        }
    }
   
    public static void checkSurveyApproved(List<SurveyQuestion__c> surveyQuestionList) {
        Set <String> SID = new Set <String>();
        for(SurveyQuestion__c surveyQuestion : surveyQuestionList){
            SID.add(surveyQuestion.Survey__c);
        }
        List <Survey__c> SurveyList = [SELECT Id FROM Survey__c WHERE Id IN :SID AND Survey_Status__c = 'Approved'];
        for(SurveyQuestion__c surveyQuestion : surveyQuestionList){
        	for(Survey__c survey : SurveyList){
                if (surveyQuestion.Survey__c == survey.Id) {
                    surveyQuestion.addError('This survey have approved before, so can not delete');
                }
            }
        }
    }
}