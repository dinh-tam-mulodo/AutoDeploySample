global with sharing class WED_EmployeePageCC {
	/* 
    Created Date: 31/10/17
    Create By: Minh Tuan
    Description: Get Client by Name or Phone
    */
    @RemoteAction
    global static WED_JsonResult getLeadByNameOrPhone(string condition, Integer offset, Integer size){
    	try {
            DataWrapper wrapper = new DataWrapper();
            String query = buildQuery(condition, size, offset);
            // Get client list
            List<Lead> leadList = Database.query(query);
            wrapper.records = leadList;

            // Get total record for paging
            String whereStatement = buildWhereStatement(condition);
            wrapper.total = WED_CommonUtil.countRecord('Lead', whereStatement);
            
            String result = JSON.serialize(wrapper);
	    	
	    	return new WED_JsonResult(true, result, '');
    	} catch (Exception ex) {
    		return new WED_JsonResult(false, null, ex.getMessage());
	    }
    }

    /* 
    Created Date: 13/11/17
    Create By: Minh Tuan
    Description: Redirect site to survey page
    */
    @RemoteAction
    global static PageReference redirectSurvey(String token) {
        // Saving data
        PageReference redirectPage = new PageReference(Label.WED_Site_Staff + '/WED_SurveyWeddingPage');
        redirectPage.getParameters().put('workSheetToken', token);

        return redirectPage;
    }

    @RemoteAction
    global static PageReference redirectPrint(String token) {
        PageReference redirectPage = new PageReference(Label.WED_Site_Staff + '/WED_EmployeePrintPage');
        redirectPage.getParameters().put('workSheetToken', token);
        return redirectPage;
    }

    /* 
    Created Date: 31/10/17
    Create By: Minh Tuan
    Description: Build query for paging
    */
    @TestVisible 
    private static String buildQuery(String condition, Integer size, Integer offset){
        List<String> arguments = new List<String>();
        String whereStatement = buildWhereStatement(condition);

        arguments.add(whereStatement);
        arguments.add(String.valueOf(size));
        arguments.add(String.valueOf(offset));

        String rawString = 'SELECT WS_Tourokubangou__c, Name, Phone, workSheetToken__c FROM Lead {0} LIMIT {1} OFFSET {2}';

        String query = String.format(rawString, arguments);

        return query;
    }

    /* 
    Created Date: 31/10/17
    Create By: Minh Tuan
    Description: Build query for paging
    */
    @TestVisible 
    private static String buildWhereStatement(string condition){
		List<String> arguments = new List<String>();

        String con = '\'' + condition + '\'';
        String conPhone = '\'' + condition.replace('-','') + '\'';
        arguments.add(con);
        arguments.add(conPhone);

        String rawString = ' WHERE (WS_Tourokubangou__c LIKE {0} OR PhoneSearch__c = {1}) AND workSheetToken__c != null';
        String result = String.format(rawString, arguments);

        return result;
    }

    public class DataWrapper {
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Object> records {get;set;}
    }
}