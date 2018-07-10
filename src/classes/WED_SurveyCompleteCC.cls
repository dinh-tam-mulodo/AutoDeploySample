global with sharing class WED_SurveyCompleteCC {
    public static String  surveyToken {get;set;}
    public static Boolean authorized {get;set;}
    public static String  header {get;set;}

    public WED_SurveyCompleteCC(){
        surveyToken = ApexPages.currentPage().getParameters().get('workSheetToken');

        // Check the URL accessed
        String baseURL = Site.getBaseUrl();
        if(Test.isRunningTest()){
            baseUrl = 'https://c.testing.visual.force.com' + WED_SurveyCompleteCCTest.strRole;
        }

        if(baseUrl.contains(Label.WED_Site_Customer)){
            authorized = false;
        } else if(baseUrl.contains(Label.WED_Site_Staff)){
            authorized = true;
        }

        /*List<Lead> surveyAnswer =  [SELECT Name
                                     FROM Lead
                                    WHERE workSheetToken__c =: surveyToken
                                    LIMIT 1];

        if(!surveyAnswer.isEmpty() && authorized) {
            String format = Label.WED_Label_Header_Finish;
            header = WED_CommonUtil.formatHeader(format, surveyAnswer[0].Name);
        } else {
            header = Label.WED_Label_Survey;
        }*/

        header = Label.WED_Label_Survey;
    }

    /* 
    Created Date: 17/11/17
    Create By: Minh Tuan
    Description: Redirect to print page
    */
    @RemoteAction
    global static PageReference redirectPrint(String token) {
        PageReference redirectPage = new PageReference(Label.WED_Site_Staff + '/WED_EmployeePrintPage');
        redirectPage.getParameters().put('workSheetToken',token);
        return redirectPage;
    }
}