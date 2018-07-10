public class SurveyParticipantTriggerHelper {
    public static void checkDoubleSurveyParticipant(List<SurveyParticipant__c> surveyParticipantList){
        Set <String> SID = new Set <String>();
        for(SurveyParticipant__c surveyParticipant : surveyParticipantList){
            SID.add(surveyParticipant.Survey__c);
        }
        List <SurveyParticipant__c> surveyParticipantAll = [SELECT Id, Survey__c, User__c FROM SurveyParticipant__c WHERE Survey__c = :SID];
        for(SurveyParticipant__c surveyParticipant : surveyParticipantList){
            for(SurveyParticipant__c surveyParticipantCond : surveyParticipantAll){
                if (surveyParticipant.Survey__c == surveyParticipantCond.Survey__c &&
                   	surveyParticipant.User__c == surveyParticipantCond.User__c &&
                   	surveyParticipant.Id != surveyParticipantCond.Id) {
                    surveyParticipant.addError('The User is already existed in this Survey!');
                }
            }
        }
    }
    
    public static Boolean checkAndUpdateSurveyStatusToClosed(List<SurveyParticipant__c> surveyParticipantList){
        Set <String> SID = new Set <String>();
        for(SurveyParticipant__c surveyParticipant : surveyParticipantList){
            SID.add(surveyParticipant.Survey__c);
        }
        List <SurveyParticipant__c> surveyParticipantAll = [SELECT Id, Survey__c, User__c FROM SurveyParticipant__c WHERE Survey__c = :SID AND Response_Completed__c = false];
        Set <String> listIdFinished = new Set <String>();
        for(String ID : SID){
            Integer count = 0;
            for(SurveyParticipant__c surveyParticipantCond : surveyParticipantAll){
                if (surveyParticipantCond.Survey__c == ID) {
                    count = count + 1;
                }
            }
            if (count == 0) {
                listIdFinished.add(ID);
            }
        }
        if (listIdFinished.size() == 0) {
            return true;
        }
		
        List <Survey__c> surveyForUpdate = [SELECT Id, Survey_Status__c FROM Survey__c WHERE Id = :listIdFinished for update];
        for(Survey__c survey : surveyForUpdate){
            survey.Survey_Status__c = 'Closed';
        }

        update surveyForUpdate;
        
        return true;
    }

    public static void checkSurveyApproved(List<SurveyParticipant__c> surveyParticipantList) {
        Set <String> SID = new Set <String>();
        for(SurveyParticipant__c surveyParticipant : surveyParticipantList){
            SID.add(surveyParticipant.Survey__c);
        }
        List <Survey__c> SurveyList = [SELECT Id FROM Survey__c WHERE Id IN :SID AND Survey_Status__c = 'Approved'];
        for(SurveyParticipant__c surveyParticipant : surveyParticipantList){
        	for(Survey__c survey : SurveyList){
                if (surveyParticipant.Survey__c == survey.Id) {
                    surveyParticipant.addError('This survey have approved before, so can not delete');
                }
            }
        }
    }
}