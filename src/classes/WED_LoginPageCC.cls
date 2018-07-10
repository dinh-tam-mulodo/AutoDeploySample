global with sharing class WED_LoginPageCC extends WED_AuthenticationBase  {
	public String username{get;set;}
	public String password{get;set;}
	public String message{get;set;}
	public Integer messageType{get;set;} //0: info, 1: warning, 2: error, 3: exception
	//public WED_LoginPageCC(){
	//	username = 'hoho';
	//	password ='wut';
	//	authentication();
	//}

	/* 
    Created Date: 26/10/17
    Create By: Minh Tuan
    Description: Set css style    
    */
	public  String getCssClass(){
		if(messageType==null) {
			return '';
		}
		return messageType==0?'info-message':messageType==1?'warning-message':messageType==2?'error-message':'exception-message';
	}

	/* 
    Created Date: 26/10/17
    Create By: Minh Tuan
    Description: Checking whether user's still in a session   
    */
	global PageReference authentication() {
		system.debug('into authen');
		CheckAuthentication();
		//if(isAuthenticated) {
		//	system.debug('authen - already authen');
		//	PageReference homePage = Page.WED_QuestionPage;
		//	homePage.setRedirect(true);
		//	return homePage;
		//} else {
		//	return null;
		//}
		return null;
	}

	/* 
    Created Date: 26/10/17
    Create By: Minh Tuan
    Description: Get User IP Address
    True-Client-IP has the value when the request is coming via the caching integration.
    X-Salesforce-SIP has the value when no caching integration(sandbox, dev, secure urls) or via secure URL.
    X-Forwarded-For get IP address from standard header if proxy in use
    */
	public String getUserIPAddress() {
 		String returnValue = '';     
 		
 		// The request is coming via the caching integration
        returnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
 
        // If there is no caching integration (sandbox, developer edition orgs) 
        // or the request is coming via the secure url
        if (String.isEmpty(returnValue)) {
        	returnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }
 
 		// If proxy is in used
        if (String.isEmpty(returnValue)) {
        	returnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } 
 
		return returnValue;
	}

	/*public PageReference login() {
		if(String.isEmpty(username)) {
			message = Label.WED_Validate_UserName;
			messageType = 1;
			return null;
		}
		if(String.isEmpty(password)) {
			message = Label.WED_Validate_Password;
			messageType = 1;
			return null;
		}
		List<WED_CustomUser__c> users = [SELECT Username__c, Password__c FROM WED_CustomUser__c WHERE Username__c = :username LIMIT 10];
		if(users.isEmpty()) {
			message = Label.WED_Error_NonExistUser;
			messageType = 1;
			return null;
		}
		WED_CustomUser__c currentUser = null;
		for(WED_CustomUser__c user : users) {
			if(user.Password__c == password) {
				currentUser = user;
				break;
			}
		}
		if(currentUser == null) {
			message = Label.WED_Error_WrongPassword;
			messageType = 2;
			return null;
		}
		message = Label.WED_Success_Login;
		messageType = 0;
		setCookie();
		isAuthenticated = true;
		//PageReference homepage = Page.WED_QuestionPage;
		//homepage.setRedirect(true);
		//return homepage;
		return null;
	}*/

	@RemoteAction	
	global static WED_JsonResult login(String us, String pw) {
		try
		{
			String msg = '';
			UserDataWrapper data = new UserDataWrapper();

			if(String.isEmpty(us)) {
				msg = Label.WED_Validate_UserName;
				data.cssClass = WED_Constants.CSSCLASS_INFO;
				
				return new WED_JsonResult(false, data, msg);
			}
			if(String.isEmpty(pw)) {
				msg = Label.WED_Validate_Password;
				data.cssClass = WED_Constants.CSSCLASS_INFO;
				
				return new WED_JsonResult(false, data, msg);
			}
			List<WED_CustomUser__c> users = [SELECT Username__c, Password__c FROM WED_CustomUser__c WHERE Username__c = :us LIMIT 10];
			if(users.isEmpty()) {
				msg = Label.WED_Error_NonExistUser;
				data.cssClass = WED_Constants.CSSCLASS_INFO;
				
				return new WED_JsonResult(false, data, msg);
			}
			WED_CustomUser__c currentUser = null;
			for(WED_CustomUser__c user : users) {
				if(user.Password__c == pw) {
					currentUser = user;
					break;
				}
			}
			if(currentUser == null) {
				msg = Label.WED_Error_WrongPassword;
				data.cssClass = WED_Constants.CSSCLASS_INFO;
				
				return new WED_JsonResult(false, data, msg);
			}

			msg = Label.WED_Success_Login;
			data.cssClass = WED_Constants.CSSCLASS_INFO;
			data.username = us;
			data.isAuthenticated = true;

			//setCookie(us);

			//isAuthenticated = true;
			//PageReference homepage = Page.WED_QuestionPage;
			//homepage.setRedirect(true);
			//return homepage;
			return new WED_JsonResult(true, data, msg);
		}catch(Exception ex){
			UserDataWrapper data = new UserDataWrapper();
			return new WED_JsonResult(false, data, ex.getMessage() + '' + ex.getLineNumber() + '' + ex.getStackTraceString());
		}
	}

	private static void setCookie(String user){
		Cookie usernameCookie = new Cookie('Wed_Username', user, null, 60, false);
		ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie});
	}

	/*private void setCookie(){
		Cookie usernameCookie = new Cookie('Wed_Username', username, null, 60, false);
		//Cookie passwordCookie = new Cookie('Wed_Password', password, null, 60, false);
		//Cookie ipAdressCookie = new Cookie('Wed_IpAddress', getUserIPAddress(), null, 60, false);
		ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie});
	}*/

	public class UserDataWrapper {
        @AuraEnabled public String cssClass {get;set;}
        @AuraEnabled public Boolean isAuthenticated {get;set;}
        @AuraEnabled public String username {get;set;}
    }
}