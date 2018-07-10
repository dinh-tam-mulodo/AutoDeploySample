@RestResource(urlMapping='/MAPlusSurvey/*')
global with sharing class MAC_MAPlusSurvey {
    @HttpPost
    global static String SettingData(DataFormWrapper formData) {

        // Setting the save point
        Savepoint sp = Database.setSavepoint();
        try {
            // Create list SP_Answer for deleting
            SP_Answer__c targetAns;
            List<SP_Answer__c> lstAnswerInsert = new List<SP_Answer__c>(); 
                     
            // Get data for insert
            DataWrapper data = formData.data;
            List<Answer> lstAnswer = data.answers;

            SP_AnswerSummary__c answerSummary = new SP_AnswerSummary__c(); 
            answerSummary.SP_Email__c = data.email;
            answerSummary.SP_Fname__c = data.fname;
            answerSummary.SP_Lname__c = data.lname;

            // INSERT Answer Summary
            insert answerSummary;

            // Loop for setting data
            for(Answer item : lstAnswer){
                targetAns = new SP_Answer__c();            
                targetAns.SP_ControlSurveyId__c = data.surveyId;
                targetAns.SP_SurveyId__c = data.surveySalesforceId;
                targetAns.SP_QuestionId__c = item.questionSalesforceId;
                targetAns.SP_ControlQuestionId__c = item.questionId;
                targetAns.SP_Answer__c = item.answer;
                targetAns.SP_AnswerSummaryId__c = answerSummary.Id;

                lstAnswerInsert.add(targetAns);
            }

            List<SP_Answer_Contact__c> lstJuncContact = new List<SP_Answer_Contact__c>();
            List<SP_Answer_Lead__c> lstJuncLead = new List<SP_Answer_Lead__c>();
            SP_Answer_Contact__c juncContact;
            SP_Answer_Lead__c juncLead;
            String email = data.email;
            List<Contact> lstTarContact;
            List<Lead> lstTarLead;
       
            //TODO: Get Limit 1???
            // Get Target contact
            lstTarContact = [SELECT Id 
                               FROM Contact
                              WHERE Email =:email
                              LIMIT 1]; 

            // Get target Lead
            lstTarLead = [SELECT Id
                            FROM Lead
                           WHERE Email =:email
                           LIMIT 1];

            Integer count = 0;

            // If email is authen with contact and lead
            if(!lstTarContact.isEmpty() && !lstTarLead.isEmpty()){
                Database.SaveResult[] results = Database.insert(lstAnswerInsert, false);
                 for(Integer i = 0; i < results.size(); i++) {
                     if(results.get(i).isSuccess()){
                        // Append data junction contact
                        juncContact = new SP_Answer_Contact__c();
                        juncContact.SP_Answer__c = results.get(i).getId();
                        juncContact.Contact__c = lstTarContact.get(0).Id;
                        juncContact.SP_AnswerSummaryId__c = answerSummary.Id;
                        lstJuncContact.add(juncContact);

                        // Append data junction lead
                        juncLead = new SP_Answer_Lead__c();
                        juncLead.SP_Answer__c = results.get(i).getId();
                        juncLead.Lead__c = lstTarLead.get(0).Id;
                        juncLead.SP_AnswerSummaryId__c = answerSummary.Id;
                        lstJuncLead.add(juncLead);
                        count ++;
                     } else {
                        Database.rollback(sp);
                        return JSON.serialize(new SP_JSONResponse('903', 'Data insert fail'));
                     }
                 }                 

                 // Insert data to item junction;
                 insert lstJuncLead;
                 insert lstJuncContact;
            }            

        } catch(Exception ex){
            Database.rollback(sp);
            //TODO
            return JSON.serialize(new SP_JSONResponse('903', ex.getMessage()));
        }

        return JSON.serialize(new SP_JSONResponse('200', ''));
    }

    // Setting data form
    global class DataFormWrapper {
        String         token                       {get;set;}
        DataWrapper    data                        {get;set;}
        String         processing                  {get;set;}
    }

    global class DataWrapper {
        String          email                       {get;set;}
        String          fname                       {get;set;}
        String          lname                       {get;set;}
        String          surveyId                    {get;set;}
        String          surveySalesforceId          {get;set;}
        List<Answer>    answers                     {get;set;}
    }

    global class Answer {
        String          questionId                  {get;set;}
        String          questionSalesforceId        {get;set;}
        String          answer                      {get;set;}
    }
}