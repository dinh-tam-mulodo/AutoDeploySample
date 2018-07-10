public with sharing class ChoiceCC {
    @AuraEnabled
    public static List<Choice__c> getChoices(Id questionId, Id surveyParticipantId, String isSurveyCompleted){
        List<Choice__c> suggestedChoices;
        if(isSurveyCompleted == 'true'){
            suggestedChoices = [SELECT Id, Choice_Value__c, Is_Choice_By_User__c FROM Choice__c WHERE Question__c = :questionId ORDER BY Choice_Order__c ASC];
            //get choice and answer
            List<SurveyResponse__c> answered = [SELECT Choice__c FROM SurveyResponse__c WHERE Survey_Participant__c = :surveyParticipantId AND Choice__r.Question__c = :questionId ];
            
            for(Integer i=0;i<suggestedChoices.size();i++) {
                for(SurveyResponse__c check : answered){
                    if(check.Choice__c == suggestedChoices[i].Id){
                        suggestedChoices[i].Is_Choice_By_User__c = true;
                    }
                }
            }
            
        }else{
            suggestedChoices = [SELECT Id, Choice_Value__c, Is_Choice_By_User__c FROM Choice__c WHERE Question__c = :questionId ORDER BY Choice_Order__c ASC];
        }
         
        return suggestedChoices;
    }    
}