/**
 * SPP_AuthenBase.
 * @author Mulodo VN
 * @version 1.0
 * @Description: Base class
 */
global without sharing virtual class SPP_AuthenBase {
    public String currentUserName	{get;set;}
    public String currentUserType	{get;set;}        // = pathPrefix: spp for example
    public Contact currentUser 		{get;set;}

    public Boolean isAuthen(){
        this.currentUserType = SPP_Utils.SITE_TYPE;
        system.debug('@@@ this.currentUserType= ' + this.currentUserType);
        try {
            User user = [Select Profile.UserLicense.Name from User where Id=: UserInfo.getUserId()];
            //System.debug('SPP_AuthenBase.isAuthen -> user: ' + user.Profile.UserLicense.Name);
            
            // If not profile guest --> Access with custom user admin
            String userLicense = user.Profile.UserLicense.Name;
            if(userLicense != 'Guest User License') {
            	List<Contact> users = [SELECT FirstName, LastName, Email, SPP_Username__c, SPP_Password__c
            						   FROM Contact
            						   WHERE SPP_Username__c = :UserInfo.getUserEmail()];
			  	if (users.isEmpty()) {
			  		Contact newAdminUser = new Contact();
			  		newAdminUser.FirstName = UserInfo.getFirstName();
			  		newAdminUser.LastName = UserInfo.getLastName();
			  		newAdminUser.SPP_Username__c = UserInfo.getUserEmail();
                    newAdminUser.SPP_Password__c = '12345678';
			  		newAdminUser.Email = UserInfo.getUserEmail();
			  		insert newAdminUser;
			  		this.currentUser = newAdminUser;
			  		this.currentUserName = newAdminUser.SPP_Username__c;

			  	} else {
			  		this.currentUser = users[0];
			  		this.currentUserName = users[0].SPP_Username__c;
			  	}
			  	return true;
            }
    
    		// Else, access with custom user (Contact)
            // Load data from cookies
            Cookie usernameCookie = ApexPages.currentPage().getCookies().get('SPP_Username');
            Cookie sessionCookie = ApexPages.currentPage().getCookies().get('SPP_SessionId');
                
            //System.debug('SPP_AuthenBase.isAuthen -> usernameCookie: ' + usernameCookie);
            if(usernameCookie != null && sessionCookie != null){
                this.currentUserName = usernameCookie.getValue();
                String currentSession = sessionCookie.getValue();
                if(String.isEmpty(currentSession)){
                    return false;
                }

                List<Contact> users = [SELECT FirstName, LastName, SPP_SesssionId__c, SPP_Username__c 
                					   FROM Contact 
                					   WHERE SPP_Username__c = :this.currentUserName 
            					       AND SPP_SesssionId__c = :currentSession 
            					       AND SPP_IsUserLocked__c = false];
                //System.debug('SPP_AuthenBase.isAuthen -> users: ' + users);
                if(users.isEmpty()) {
                    return false;
                }

                this.currentUser = users[0];
                //System.debug('SPP_AuthenBase.isAuthen -> currentUser.LastActivity__c: ' + currentUser.LastActivity__c);
                //currentUser.LastActivity__c = Datetime.now();
                //currentUser.IsTimeout__c = true;
                //update currentUser;
                return true;

            } else {
                //System.debug('SPP_AuthenBase.isAuthen -> usernameCookie null or sessionCookie null');
                return false;
            }

        } catch(Exception ex) {
            System.debug('SPP_AuthenBase.isAuthen -> Ex: ' + SPP_Utils.getExcMsg(ex));
            return false;
        }
    }

    public PageReference authen() {
        PageReference pr = null;
        system.debug('@@@ isAuthen= ' + isAuthen());
        if(isAuthen()){
            /*if(isPasswordNeedReset(currentUser.LastChangingPassword__c)){
                pr = Page.SPP_ChangePasswordPage;
                pr.setRedirect(true);
                pr.getParameters().put(SPP_Constant.EMPTY_PASS_URL_PAR , SPP_Utils.encryptURL(currentUser.Username__c));
            }*/
        } else {
            pr = SPP_Utils.returnLoginPage();
        }
        return pr;
    }

    public PageReference logout() {
        if(this.currentUser != null) {
            this.currentUser.SPP_SesssionId__c = null;
            update this.currentUser;
            //SPP_Utils.createLog(currentUser.Id, currentUserName, SPP_Constant.LOG_LOGOUT);
            SPP_Utils.removeCookie();
        }
        return SPP_Utils.returnLoginPage();
    }

    public void setCookie(String sessionId, String userType, String userName){
        Cookie usernameCookie = new Cookie('SPP_Username', userName, null, -1, false);
        Cookie sessionIdCookie = new Cookie('SPP_SessionId', sessionId, null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie, sessionIdCookie});
    }

    /*public Boolean isPasswordNeedReset(Datetime timeMark){
        Boolean isReset = false;
        if(timeMark !=null && timeMark.addMonths(SPP_Constant.RESET_PASS_MONTH) < Datetime.now()){
            isReset = true;
        }
        return isReset;
    }*/
}