global class MF_LoginCC {
    //if already redirect to mulodoforcepage
    public static pagereference isAlreadyLoggedIn(){
        if(MF_UserAuthentication.cookieContactId != null){
            PageReference page = new PageReference('/apex/MF_MulodoForcePage');
            page.setRedirect(true);
            return page;
        }
        return null;
    }
    
    // get List questions that display after login
	@RemoteAction
    global static List<MF_Question__c> getQuestion(){
        return [SELECT Id, Question_Text__c FROM MF_Question__c WHERE IsDisplay__c = true];
    }
    
    // get question choices
    @RemoteAction
    global static List<MF_Choice__c> getChoices(List<String> questionIds){
        return [SELECT Id,MF_Question__c ,Choice_Value__c FROM MF_Choice__c WHERE MF_Question__c IN :questionIds];
    }
    
    // check is username is exist, return contactId if existed
    @RemoteAction
    global static String checkUsernameExist(String username){
        List<Contact> checkList = [SELECT Id FROM Contact WHERE username__c  = :username];
        if(checkList.size() > 0){
            return checkList[0].Id;
        }
        return null;
    }
    
    // get pending task
    @RemoteAction
    global static List<Task> getPendingTask(String contactId){
        return [SELECT Id, WhoId, Subject, Status, Priority, CreatedDate FROM Task WHERE IsClosed = false AND WhoId = :contactId];
    }
    
    // update or insert the responese of user
    @RemoteAction
    global static Boolean updateAnswers(String contactId, Map<String, String> questionAndAnswerMap){
        System.debug(questionAndAnswerMap);
        Map<String, String> answersMap = convertToEditableMap(questionAndAnswerMap);
        List<MF_Response__c> answeredQuestion = [SELECT Id, MF_Question__c FROM MF_Response__c WHERE Contact__c = :contactId AND MF_Question__c IN :questionAndAnswerMap.keySet()];
        if(answeredQuestion.size() > 0){
            //update the question that been aswered!
            for(MF_Response__c response : answeredQuestion){
                response.Response_Text__c = answersMap.get(response.MF_Question__c);
                answersMap.remove(response.MF_Question__c);
            }
            Savepoint sp = Database.setSavepoint();
            try{
                update answeredQuestion;
                //insert the new response
                if(answersMap.size() > 0){
                   insertUserAnswer(contactId, answersMap);
                }
            }catch(System.DmlException e){
                Database.rollback(sp);
            }
            
        }else{
            insertUserAnswer(contactId, answersMap);
        }
        return true;
    }
    
    public static void insertUserAnswer(String contactId, Map<String, String> questionAndAnswerMap){
        List<MF_Response__c> listResponse = new List<MF_Response__c>();
        for(String key : questionAndAnswerMap.keySet()){
            MF_Response__c newResponse = new MF_Response__c(Contact__c = contactId, MF_Question__c = key, Response_Text__c = questionAndAnswerMap.get(key));
            listResponse.add(newResponse);
        }
        insert listResponse;
    }
    
    public static Map<String, String> convertToEditableMap(Map<String, String> readOnlyMap){
        Map<String, String> result = new Map<String, String>();
        for(String key : readOnlyMap.keySet()){
            result.put(key, readOnlyMap.get(key));
        }
        return result;
    }
}