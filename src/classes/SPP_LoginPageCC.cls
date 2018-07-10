/**
 * SPP_LoginPageCC.
 * @author Mulodo VN
 * @version 1.0
 * @Description: Controller class
 */

public with sharing class SPP_LoginPageCC extends SPP_AuthenBase {
	public String username 		{get;set;}
	public String password 		{get;set;}
	public String message 		{get;set;}
	private Map<String,Integer> countLogin;

	// Constructor
	public SPP_LoginPageCC (){
	}

	public String getCssClass(){
		return String.isBlank(message) ? '' : 'error-message';
	}

	public PageReference authenLogin() {
		if(isAuthen()) {
			return SPP_Utils.returnMainPage();
		} else {
			this.countLogin = new Map<String, Integer>();
			return null;
		}
	}

	public PageReference login() {
		//System.debug('SPP_LoginPageCC.login -> start login');
		if(String.isEmpty(this.username)) {
			return null;
		}
		if(String.isEmpty(this.password)) {
			this.message = SPP_Constant.MSG_EMPTY_PASS;
			return null;
		}
		List<Contact> users = [SELECT SPP_Username__c, SPP_Password__c, SPP_IsUserLocked__c, SPP_SesssionId__c, Email 
							   FROM Contact 
							   WHERE SPP_Username__c = :this.username];
		//user is not existing
		if(users.isEmpty()) {
			//SPP_Utils.createLog(null, this.username, SPP_Constant.LOG_USER_NOT_FOUND);
			this.message = SPP_Constant.MSG_USER_NOT_FOUND;
			return null;
		}

		/*if(String.isBlank(users[0].Password__c)){ //Password empty then go to change pass page
			PageReference changePasswordpage = Page.SPP_ChangePasswordPage;
        	changePasswordpage.setRedirect(true);
        	changePasswordpage.getParameters().put('a',SPP_Utils.encryptURL(users[0].Username__c));
        	return changePasswordpage;
		}*/

		/*if(String.isNotBlank(currentUserType) && !currentUserType.containsIgnoreCase(SPP_Utils.SITEMAP.get(users[0].UserType__c))){
			message = SPP_Constant.MSG_WRONG_USER_TYPE;
			//messageType = 1;
			return null;
		}*/

		this.currentUser = null;

		/*if(users[0].SPP_IsUserLocked__c) {
			if(users[0].LastActivity__c != null &&
			 	(Datetime.now().getTime() - users[0].LastActivity__c.getTime()) >= SPP_Constant.UNLOCK_PERIOR){ // unlock user after 1 hour
				users[0].Lock__c = false;
			}else{
				SPP_Utils.createLog(users[0].Id, username, SPP_Constant.LOG_USER_LOCKED);
				message = SPP_Constant.MSG_USER_LOCKED;
				//messageType = 1;
				return null;	
			}
		}*/

		/*if(!users[0].IsValid__c) {
			SPP_Utils.createLog(users[0].Id, username, SPP_Constant.LOG_USER_INVALID);
			message = SPP_Constant.MSG_USER_NOT_FOUND;
			//messageType = 1;
			return null;
		}*/

		if(users[0].SPP_Password__c == this.password) {
			this.currentUser = users[0];
		}
		
		//there is no user mapping with password
		/*if(this.currentUser == null) {
			//count the times login
			if(this.countLogin.get(this.username) == null) {
				this.countLogin.put(username, 0);
			} else {
				Integer current = countLogin.get(username);
				if(current>=4) {
					users[0].Lock__c = true;
					users[0].LastActivity__c = Datetime.now();
					update users[0];
					message = SPP_Constant.MSG_USER_LOCKED;
					//messageType = 1;
					SPP_Utils.createLog(users[0].Id, username, SPP_Constant.LOG_LOCKED);
					return null;
				}
				countLogin.put(username, current + 1);
			}
			SPP_Utils.createLog(users[0].Id, username, SPP_Constant.LOG_LOGIN_FAILED);
			message = SPP_Constant.MSG_USER_NOT_FOUND;
			//messageType = 1;
			return null;
		}*/

		/*if(isPasswordNeedReset(currentUser.LastChangingPassword__c)){
        	PageReference changePasswordpage = Page.SPP_ChangePasswordPage;
        	changePasswordpage.setRedirect(true);
        	changePasswordpage.getParameters().put(SPP_Constant.EMPTY_PASS_URL_PAR ,SPP_Utils.encryptURL(currentUser.Username__c));
        	return changePasswordpage;
		}*/

		this.message = null;
		//messageType = null;
		//update or create session and return to main page
		return upsertSession();
	}

	private PageReference upsertSession(){
		this.currentUser.SPP_SesssionId__c = SPP_Utils.generateSessionID();
		//currentUser.LastActivity__c = Datetime.now();
		//System.debug('SPP_LoginPageCC.upsertSession -> currentUser: ' + currentUser);
		update this.currentUser;
		//message = 'SPP_LoginPageCC.upsertSession -> Login successfully';
		//messageType = 0;
		setCookie(this.currentUser.SPP_SesssionId__c, currentUserType,  this.username);
		//SPP_Utils.createLog(currentUser.Id, username, SPP_Constant.LOG_LOGIN_OK);
		return SPP_Utils.returnMainPage();
	}
}