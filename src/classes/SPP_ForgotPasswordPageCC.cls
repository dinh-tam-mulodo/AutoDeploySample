/**
 * SPP_ForgotPasswordPageCC.
 * @author Mulodo VN
 * @version 1.0
 * @Description: Controller class
 */
global with sharing class SPP_ForgotPasswordPageCC {
    public String username 				{get;set;}
    public String message 				{get;set;}
    public String messageType 			{get;set;}
    public String currentUserType 		{get;set;}

    public SPP_ForgotPasswordPageCC(){
        this.currentUserType = SPP_Utils.SITE_TYPE;
    }

    public PageReference validateUsername(){
        /* Workflow rule to sent email will be run when:
            - SPP_ForgotPassURL__c <> null
            - SPP_Password__c = true
        */
        try {
            List<Contact> users = [SELECT Firstname, Lastname, Email, SPP_Username__c, SPP_Password__c, SPP_IsUserLocked__c, 
                                          SPP_SesssionId__c, SPP_ForgotPassURL__c, SPP_ForgotPassFlag__c
            					   FROM Contact 
            					   WHERE SPP_Username__c = :this.username];
            // If username/email not exist --> create new user and send email to set password
            if (users.isEmpty()) {   
                Contact user = new Contact();
                user.SPP_Username__c = this.username;
                user.Email = this.username;
                user.LastName = 'MulodoVN';
                user.FirstName = createFirstName();        
                String randomKey = SPP_Utils.genRandomKey(user.SPP_Username__c);
                user.SPP_ForgotPassURL__c = SPP_Utils.SITE_DOMAIN + this.currentUserType + '/SPP_ChangePasswordPage?'+ SPP_Constant.RESET_PASS_URL_PAR + '=' +  SPP_Utils.encryptURL(randomKey);
                user.SPP_ForgotPassFlag__c = true;
                user.SPP_Password__c = '';
                insert user;
                //this.message = SPP_Constant.MSG_EMAIL_SENT;
                this.message = 'Mail sent. Please check your email inbox to perform next step 01';
                this.messageType = 'info-message';
                //return null;
                return redirectToChangePassword(SPP_Constant.RESET_PASS_URL_PAR, SPP_Utils.encryptURL(randomKey));

           // Else retrieve existed user and send email to update password   
            } else {
                Contact user = users[0];
                //SPP_Utils.createLog(user.Id,username, SPP_Constant.LOG_RESET_PASS);
                //user.TimeMark__c = Datetime.now();
                String randomKey = SPP_Utils.genRandomKey(user.SPP_Username__c);
                user.SPP_ForgotPassURL__c = SPP_Utils.SITE_DOMAIN + this.currentUserType + '/SPP_ChangePasswordPage?'+ SPP_Constant.RESET_PASS_URL_PAR + '=' +  SPP_Utils.encryptURL(randomKey);
                user.SPP_ForgotPassFlag__c = true;
                user.SPP_Password__c = '';
                update user;
                //this.message = SPP_Constant.MSG_EMAIL_SENT;
                this.message = 'Mail sent. Please check your email inbox to perform next step 02';
                this.messageType = 'info-message';
                //return null;
                return redirectToChangePassword(SPP_Constant.RESET_PASS_URL_PAR, SPP_Utils.encryptURL(randomKey));
            }        

        } catch(Exception ex) {
            this.message = SPP_Utils.getExcMsg(ex);
            this.messageType = 'error-message';
            return null;
        }
    }

    /*webService static Boolean callResetingPassword(String userId){
        //System.debug('SPP_ForgotPasswordPageCC.callResetingPassword -> into callResetingPassword');
        try {
        	List<Contact> users = [SELECT Firstname, Lastname, Email, SPP_Username__c, SPP_Password__c, SPP_IsUserLocked__c, SPP_SesssionId__c 
            					   FROM Contact 
            					   WHERE Id = :userId];
            if (users.isEmpty()) {
            	return false;
            }
            Contact user = users[0];
            //user.TimeMark__c = Datetime.now();
            //String randomKey = SPP_Utils.genRandomKey(user.Username__c);
            //user.TemplateUrl__c = SPP_Utils.SITE_DOMAIN + SPP_Utils.SITEMAP.get(user.UserType__c)+'/SPP_changepasswordpage?'+SPP_Constant.RESET_PASS_URL_PAR+'=' + SPP_Utils.encryptURL(randomKey);
            //user.IsReset__c = true;
            //user.SPP_Password__c = '';
            update user;
            //SPP_Utils.createLog(user.Id,user.Username__c, SPP_Constant.LOG_RESET_PASS);
            return true;
        } catch(Exception ex) {
            System.debug('SPP_ForgotPasswordPageCC.callResetingPassword -> exception: ' + SPP_Utils.getExcMsg(ex));
            return false;
        }
    }*/

    private String createFirstName() {
        List<Contact> contactList = [SELECT FirstName FROM Contact WHERE FirstName like 'SPPTestUser_%'];
        if (contactList.isEmpty()) {
            return 'SPPTestUser_1';
        } else {
            String tmpUserFName = contactList[0].FirstName;
            List<String> fNameSplit = tmpUserFName.split('_');
            String index = fNameSplit[1];
            Integer nextIndex = Integer.valueOf(index) + 1;
            return 'SPPTestUser_' + String.valueOf(nextIndex);
        }
    }

    private PageReference redirectToChangePassword(String param, String paramValue) {
        PageReference changePassPage = Page.SPP_ChangePasswordPage;
        changePassPage.getParameters().put(param, paramValue);
        changePassPage.setRedirect(true);
        return changePassPage;
    }
}