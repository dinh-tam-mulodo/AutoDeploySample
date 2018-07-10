@isTest
public class WED_SurveyCompleteCCTest {
	public static String strRole = '';

	/* Description: Create Lead */
	public static Lead createLead(){
		Lead leado = new Lead();
		leado.LastName = 'Test1';
		leado.Company = 'MURODO';
		leado.Status = 'アーカイブ';
		leado.workSheetToken__c = 'a3f2dde56c85123450975b46a72f286dd14fe0be';
		insert leado;

		return leado;
	}

	/*Test Function: redirectPrint
      Test Case: Check URL of PageReference return is right*/    
    @isTest 
    public static void redirectPrintTest(){
    	String token = 'thisistokentest';
    	String urlExpected = Label.WED_Site_Staff + '/WED_EmployeePrintPage?workSheetToken=thisistokentest';

    	PageReference pageReferenceReturn = WED_SurveyCompleteCC.redirectPrint(token);

        System.assertEquals(urlExpected, pageReferenceReturn.getUrl());
        System.assertEquals(token, pageReferenceReturn.getParameters().get('workSheetToken'));
    	
    }

    /*Test Constructor
      Test Case: Access without token*/
    @isTest
	public static void WED_SurveyCompleteCCTest1(){
		PageReference pageRef = Page.WED_SurveyCompletePage;
        Test.setCurrentPage(pageRef);
        WED_SurveyCompleteCC controller = new WED_SurveyCompleteCC();

        String workSheetToken = ApexPages.currentPage().getParameters().get('workSheetToken');

        System.assertEquals(null, workSheetToken);
	}

	/*Test Constructor
      Test Case: Access as a customer with token*/
    @isTest
	public static void WED_SurveyCompleteCCTest2(){
		Lead leado = createLead();
		strRole = '/survey';

		PageReference pageRef = Page.WED_SurveyCompletePage;
		pageRef.getParameters().put('workSheetToken', leado.workSheetToken__c);
        Test.setCurrentPage(pageRef);

        WED_SurveyCompleteCC controller = new WED_SurveyCompleteCC();

        System.assertEquals(Label.WED_Label_Survey,WED_SurveyCompleteCC.header);
	}

	/*Test Constructor
      Test Case: Access as a staff with token*/
    @isTest
	public static void WED_SurveyCompleteCCTest3(){
		Lead leado = createLead();
		strRole = '/contact';

		PageReference pageRef = Page.WED_SurveyCompletePage;
		pageRef.getParameters().put('workSheetToken', leado.workSheetToken__c);
        Test.setCurrentPage(pageRef);

        WED_SurveyCompleteCC controller = new WED_SurveyCompleteCC();		

        /*String format = Label.WED_Label_Header_Finish;
        String headerExpected = WED_CommonUtil.formatHeader(format, leado.LastName);*/

        System.assertEquals(Label.WED_Label_Survey,WED_SurveyCompleteCC.header);
	}
}