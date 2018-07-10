@isTest
public class MF_LoginCCTest {
	@testSetup static void setup() {
        MF_DummyDataMaker.createDummyData();
    }
    
    @isTest static void isAlreadyLoggedIn_DidntLoggedInCaseTest() {
		MF_CookieUtil.clearCookies();
        System.assertEquals(MF_LoginCC.isAlreadyLoggedIn(), null);
    }
    
    @isTest static void isAlreadyLoggedIn_LoggedInCaseTest() {
        MF_CookieUtil.setCookieValue(MF_CookieUtil.COOKIE_CONTACT_ID, MF_DummyDataMaker.CONTACT_ID, MF_CookieUtil.COOKIE_PATH, true);
        System.assertNotEquals(MF_LoginCC.isAlreadyLoggedIn(), null);
    }
    
    @isTest static void getQuestionTest() {
        System.assertEquals(MF_LoginCC.getQuestion().size() > 0, true);
        //test
    }
    
    @isTest static void getChoicesTest() {
        List<MF_Question__c> questions =  MF_LoginCC.getQuestion();
        List<String> questionIds = new List<String>();
        for(MF_Question__c question : questions){
            questionIds.add(question.Id);
        }
        System.assertEquals(MF_LoginCC.getChoices(questionIds).size() > 0, true);
    }
    
    @isTest static void getPendingTask(){
        System.assertNotEquals(MF_LoginCC.getPendingTask(MF_DummyDataMaker.CONTACT_ID), null);
    }
    
    @isTest static void checkUsernameExist_ExistedTest(){
        System.assertNotEquals(MF_LoginCC.checkUsernameExist(MF_DummyDataMaker.CONTACT_EMAIL), null);
    }
    
    @isTest static void checkUsernameExist_NotExistedTest(){
        System.assertEquals(MF_LoginCC.checkUsernameExist('this_username_not_existed'), null);
    }
    
    @isTest static void updateAnswersTest(){
        List<MF_Question__c> questions =  MF_LoginCC.getQuestion();
        List<String> questionIds = new List<String>();
        for(MF_Question__c question : questions){
            questionIds.add(question.Id);
        }
        List<MF_Choice__c> choices = MF_LoginCC.getChoices(questionIds);
        Map<String, String> dummyTest = new Map<String, String>();
        
        for(MF_Question__c question : questions){
            for(MF_Choice__c choice : choices){
                if(choice.MF_Question__c == question.Id){
                    dummyTest.put(question.Id, choice.Id);
                    break;
                }
            }
        }
        System.assertEquals(MF_LoginCC.updateAnswers(MF_UserAuthentication.cookieContactId, dummyTest), true); //insert
        System.assertEquals(MF_LoginCC.updateAnswers(MF_UserAuthentication.cookieContactId, dummyTest), true); //update
    }
}