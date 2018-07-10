public with sharing class SurveyCC {
	@AuraEnabled
    public static void insertSurveyResponses(List<SurveyResponse__c> answers, Id surveyParticipantId, String SurveyId){
        insert answers;

        //update completed date and survey status as completed
        SurveyParticipant__c surveyParticipant = [SELECT Id, Response_Completed__c, Response_Date__c  FROM SurveyParticipant__c WHERE Id= :surveyParticipantId];
        surveyParticipant.Response_Completed__c = true;
        surveyParticipant.Response_Date__c = date.today();
        update surveyParticipant;
    }
    
	@AuraEnabled
    public static String insertFreeTextChoice(Choice__c choice){
        List<Choice__c> checkingChoice = [SELECT Id,Question__c FROM Choice__c WHERE Question__c = :choice.Question__c LIMIT 1];
        if(checkingChoice.size() > 0){
            //update value for existed choice
            Choice__c updateChoice = checkingChoice[0];
            updateChoice.Choice_Value__c = choice.Choice_Value__c;
            upsert updateChoice;
            return updateChoice.Id;
        }else{
            //insert new choice
            insert choice;
        	return choice.Id;
        } 
    }
    
    @AuraEnabled
    public static List<Question__c> getQuestionsBySurvey(Id surveyId){
        List<Question__c> questions = [SELECT Id, Question_Type__c, Question_Text__c, Question_Answer_Required__c FROM Question__c WHERE Id IN (SELECT Question__c FROM SurveyQuestion__c sq WHERE sq.Survey__c = :surveyId)];
        return questions;
    }   

   @RemoteAction
   public static Integer getTotalRecord(String searchText)
   {
       String searchString = '%' + searchText + '%';
       Integer total = [SELECT count() FROM Survey__c where Name like :searchString or Survey_Code__c like :searchString];
       return total;
   }
    
   @RemoteAction
   public static List<Survey__c> getSearchRecord(String searchText, String sortBy, String sortOrder, Integer page, Integer recordPerPage)
   {
       String searchString = '\'%' + searchText + '%\'';
       //Integer recordPerPage = limit;
       Integer offsetPage = (page*recordPerPage) - recordPerPage;
       String soql = 'SELECT Id, Name, Survey_Code__c, CreatedDate FROM Survey__c WHERE (Name LIKE ' + searchString + ' OR Survey_Code__c LIKE' + searchString +') ORDER BY ' + sortBy + ' ' + sortOrder + ' LIMIT ' + recordPerPage + ' OFFSET ' + offsetPage;
       List<Survey__c> result = Database.Query(soql);
       return result;
   }
   @RemoteAction
   public static List<SurveyParticipant__c> getListSurveyParticipantOfSurvey(Id SurveyId)
   {
       List<SurveyParticipant__c> surveyParticipant = [ SELECT Id, User__r.FirstName, User__r.LastName, Survey__c, Response_Date__c, Response_Completed__c, Survey__r.Name, 
                                                         Survey__r.Survey_Expiration_Date__c, Survey__r.Survey_Welcome_Message__c, Survey__r.Survey_Exit_Message__c  
                                                  FROM SurveyParticipant__c 
                                                  WHERE Survey__c = :SurveyId];
       return surveyParticipant;
   }
}