/**
 * SPP_MainPageCC.
 * @author Mulodo VN
 * @version 1.0
 * @Description: Controller class
 */
global with sharing class SPP_MainPageCC extends SPP_AuthenBase {
	public String userActive {get;set;}
	
	public SPP_MainPageCC(){
		System.debug('SPP_MainPageCC.SPP_MainPageCC -> into constructor');		
	}

	/**
    *   @Name: SPP_MainPageCC.updatePassword
    *   @Parameter: current active user, current password, new password
    *   @Description: update current user's password
    *   @Return: True: updated / False: not update
    **/
	@RemoteAction
	global static Boolean updatePassword(String userActive, String currentPass, String newPass) {
		/*List<REC_CustomUser__c> users = [SELECT Password__c, LastChangingPassword__c, SessionId__c, Username__c, LastActivity__c FROM REC_CustomUser__c WHERE Username__c = :userActive];
		//user is not existing
		if(!users.isEmpty()) {
			//System.debug('user is not null');
			for(REC_CustomUser__c user : users) {
				if(user.Password__c == currentPass) {
					//System.debug('current password is correct!');
					if(newPass != '') {
						user.Password__c = newPass;
						user.LastChangingPassword__c = Datetime.now();
						user.LastActivity__c = Datetime.now();
						update user;
						REC_Utils.createLog(user.Id, user.Username__c, REC_Constant.LOG_PASS_UPDATED);
						//System.debug('Update success');
						return true;
					}					
				}else{
					//System.debug('current password is wrong!');
					return false;
				}
			}
		}
		return false;*/
		return true;
	}

	/**
    *   @Name: SPP_MainPageCC.editProfile
    *   @Parameter: current active user, firstName, lastName, email
    *   @Description: edit current user's profile
    *   @Return: True: updated / False: not update
    **/
	@RemoteAction
	global static Boolean editProfile(String userActive, String firstName, String lastName, String email) {
		/*List<REC_CustomUser__c> users = [SELECT Username__c, FirstName__c, LastName__c, Email__c, LastActivity__c FROM REC_CustomUser__c WHERE Username__c = :userActive];
		//user is not existing
		if(!users.isEmpty()) {
			//System.debug('user is not null');
			for(REC_CustomUser__c user : users) {
				user.FirstName__c = firstName;
				user.LastName__c = lastName;
				user.Email__c = email;				
				user.LastActivity__c = Datetime.now();

				update user;
				REC_Utils.createLog(user.Id, user.Username__c, REC_Constant.LOG_PROFILE_UPDATED);
				//System.debug('Update profile success');
				return true;
			}
		}
		return false;*/
		return true;
	}

	/**
    *   @Name: SPP_MainPageCC.setInfoProfile
    *   @Parameter: current active user
    *   @Description: set Info Profile of current user
    *   @Return: A list contains Username__c, FirstName__c, LastName__c, Email__c of current user
    **/
	@RemoteAction
	global static SObject setInfoProfile(String userActive) {
		//return [SELECT  Username__c, FirstName__c, LastName__c, Email__c FROM REC_CustomUser__c WHERE Username__c = :userActive Limit 1];
		return null;
	}
}