public with sharing class REC_LoginPageCC extends REC_AuthenBase{
	public String username{get;set;}
	public String password{get;set;}
	public String message{get;set;}
	public Integer messageType{get;set;} //0: info, 1: warning, 2: error, 3: exception
	public String getCssClass(){
		if(messageType==null) {
			return '';
		}
		return messageType==0?'info-message':messageType==1?'warning-message':messageType==2?'error-message':'exception-message';
	}

	public PageReference authen() {
		system.debug('into authen');
		if(IsAuthen) {
			system.debug('authen - already authen');
			PageReference homepage = Page.REC_MainPage;
			homepage.setRedirect(true);
			return homepage;
		} else {
			return null;
		}
	}

	public static String GetUserIPAddress() {
 		String ReturnValue = '';     
 		// True-Client-IP has the value when the request is coming via the caching integration.
        ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
 
        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (String.isEmpty(ReturnValue)) {
        	ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)
 
        if (String.isEmpty(ReturnValue)) {
        	ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
 
		return ReturnValue;
	}

	public PageReference login() {
		if(String.isEmpty(username)) {
			message = 'Please enter Username';
			messageType = 1;
			return null;
		}
		if(String.isEmpty(password)) {
			message = 'Please enter Password';
			messageType = 1;
			return null;
		}
		List<CustomUser__c> users = [SELECT Password__c, Username__c FROM CustomUser__c WHERE Username__c = :username];
		if(users.isEmpty()) {
			message = 'User does not exist';
			messageType = 1;
			return null;
		}
		CustomUser__c currentUser = null;
		for(CustomUser__c user : users) {
			if(user.Password__c == password) {
				currentUser = user;
				break;
			}
		}
		if(currentUser == null) {
			message = 'Password is not correct';
			messageType = 2;
			return null;
		}
		message = 'Login successfully';
		messageType = 0;
		setCookie();
		PageReference homepage = Page.REC_MainPage;
		homepage.setRedirect(true);
		return homepage;
	}

	private void setCookie(){
		Cookie usernameCookie = new Cookie('Rec_Username', username, null, -1, false);
		Cookie passwordCookie = new Cookie('Rec_Password', password, null, -1, false);
		Cookie ipAdressCookie = new Cookie('Rec_IpAddress', GetUserIPAddress(), null, -1, false);
		ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie, passwordCookie, ipAdressCookie});
	}
}