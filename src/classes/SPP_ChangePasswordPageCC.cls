/**
 * SPP_ChangePasswordPageCC.
 * @author NTT TechnoCross Corporation
 * @version 1.0
 * @Description: Controller class
 */
global without sharing class SPP_ChangePasswordPageCC extends SPP_AuthenBase {
	public String currentPass		{get;set;}
	public String newPass			{get;set;}
	public String confirmPass		{get;set;}
	public Contact user				{get;set;}
	public String message			{get;set;}

	/*public PageReference checkUser(){
		//System.debug('SPP_ChangePasswordPageCC.checkUser -> into checkUser');
		PageReference pr = SPP_Utils.returnLoginPage();
		try {
			String encryptedUsername = ApexPages.currentPage().getParameters().get(SPP_Constant.EMPTY_PASS_URL_PAR);
			if(String.isNotBlank(encryptedUsername)){
				String username = SPP_Utils.decryptURL(encryptedUsername);
				//System.debug('SPP_ChangePasswordPageCC.checkUser -> username: ' + username);
				List<SPP_CustomUser__c> users = [SELECT TimeMark__c, LastChangingPassword__c, Password__c, Lock__c, SessionId__c, Username__c, LastActivity__c, IsValid__c FROM SPP_CustomUser__c WHERE Username__c = :username];
				if(!users.isEmpty() &&  isPasswordNeedReset(users[0].LastChangingPassword__c)) {
					user = users[0];
					pr = null;
					message = SPP_Constant.MSG_AUTO_RESET_PASS;
				}
			}else{
				String encryptedResetKey = ApexPages.currentPage().getParameters().get(SPP_Constant.RESET_PASS_URL_PAR);
				if(String.isNotBlank(encryptedResetKey)){
					String resetKey = SPP_Utils.decryptURL(encryptedResetKey);
					String username =  SPP_Utils.getKeyFromRandom(resetKey);
					List<SPP_CustomUser__c> users = [SELECT TimeMark__c, LastChangingPassword__c, Password__c, Lock__c, SessionId__c, Username__c, LastActivity__c, IsValid__c FROM SPP_CustomUser__c WHERE Username__c = :username];
					if(!users.isEmpty() && users[0].TimeMark__c != null){
						SPP_CustomUser__c custUser = users[0];
						Long timeMark = custUser.TimeMark__c.getTime();
						if(SPP_Constant.URL_EXPIRE_TIME >= (Datetime.now().getTime() - timeMark) &&  
							(custUser.LastChangingPassword__c == null || (custUser.LastChangingPassword__c != null && custUser.LastChangingPassword__c.getTime() < timeMark))){
							user = custUser;
							pr = null;
						}		
					}
				}	
			}	
		}catch(Exception ex){
			message = SPP_Utils.getExcMsg(ex);
			pr = null;
		}
		return pr;
	}*/

	public PageReference checkUser() {
		PageReference pr = SPP_Utils.returnLoginPage();
		try {
			String encryptedResetKey = ApexPages.currentPage().getParameters().get(SPP_Constant.RESET_PASS_URL_PAR);
			if(String.isNotBlank(encryptedResetKey)) {
				String resetKey = SPP_Utils.decryptURL(encryptedResetKey);
				String username =  SPP_Utils.getKeyFromRandom(resetKey);
				List<Contact> users = [SELECT SPP_Username__c, SPP_Password__c, SPP_IsUserLocked__c, SPP_SesssionId__c
									   FROM Contact 
									   WHERE SPP_Username__c = :username];
				if(!users.isEmpty()) {
					this.user = users[0];
					pr = null;
				}
			}	

		} catch(Exception ex){
			this.message = SPP_Utils.getExcMsg(ex);
			pr = null;
		}
		return pr;	
	}

	public PageReference updatePassword(){
		System.debug('SPP_ChangePasswordPageCC.updatePassword -> into updatePassword');
		if(this.user != null) {
			//user.LastChangingPassword__c = Datetime.now();
			user.SPP_Password__c = newPass;
			user.SPP_SesssionId__c = SPP_Utils.generateSessionID();
			//user.LastActivity__c = Datetime.now();
			update this.user;
			setCookie(this.user.SPP_SesssionId__c, SPP_Utils.SITE_TYPE, this.user.Username__c);
			//SPP_Utils.createLog(user.Id, user.Username__c, SPP_Constant.LOG_CHANGE_PASS);
			return SPP_Utils.returnMainPage();
		
		} else {
			return SPP_Utils.returnLoginPage();
		}
		return null;
	}
}