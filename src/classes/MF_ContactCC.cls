/*	Description: Custom Controller of Contact Object: [Create,Update Contact]
	Created By: Rinkitori Tam
  	Created Date: Contact Controller
*/
global with sharing class MF_ContactCC extends MF_UserAuthentication{
	private static final String PROFILE_CHATTER_FREE = '00e28000001q0lt';
	private static final String INTERNAL_CONTACT = '1';
	private static final String EXTERNAL_CONTACT = '2';
	global String contactType {get;set;}
	global String contactId {get;set;}	
	global String contactName {get;set;}
	global MF_ContactCC() {		
		contactType = ApexPages.currentPage().getParameters().get('type');
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        if(contactId != null){
            MF_CookieUtil.setCookieValue(MF_CookieUtil.COOKIE_CONTACT_ID, contactId, MF_CookieUtil.COOKIE_PATH, true);
        }
		if(contactType==null || contactType != EXTERNAL_CONTACT){			
			contactType = INTERNAL_CONTACT;
		}	
		string cookieContactId = MF_CookieUtil.getCookieValue(MF_CookieUtil.COOKIE_CONTACT_ID);
		contactId = cookieContactId;
		Contact[] cont = [Select Name From Contact Where Id=:cookieContactId];
		if(cont.size() > 0){			
			contactName = cont[0].Name;	
		}
	}	
	/*
		Add new chatter user maybe delete
	*/
    /*
	private static JsonResult createChatterUser(MF_Contact contact){
		try{
			User chatter = new User();			
			chatter.FirstName = contact.FirstName;
			chatter.LastName = contact.LastName;
			chatter.Alias = contact.LastName.length() > 8? contact.LastName.subString(0,7):contact.LastName;			
			chatter.Email = contact.Email;
			chatter.CommunityNickname = contact.Email;
			chatter.UserName = contact.Email + '.chatterDev02';
			chatter.Phone = contact.Phone;
			chatter.Fax = contact.Fax;			
			chatter.ProfileId = PROFILE_CHATTER_FREE;
			chatter.TimeZoneSidKey = UserInfo.getTimeZone().getID();
			chatter.EmailEncodingKey = 'UTF-8';
			chatter.LanguageLocaleKey = 'en_US';
			chatter.LocaleSidKey = 'en_US';
			system.debug('Chatter: '+chatter);
			insert chatter;
			//send Email to User
			System.resetPassword(chatter.Id,true);
			// return chatter
			return new JsonResult(true,chatter,'');
			}catch(DmlException ex){
				system.debug(ex.getMessage());
				return new JsonResult(false,null,'Error: This Email has been used by other user!');
			}
	}
	*/
	/*
		Upload image
	*/
	@RemoteAction
    global static String doUploadAttachment(String contactId, String attachmentBody, String attachmentName, String attachmentId) {
        try{
	        if(contactId != null) {        	
	                if(attachmentBody != null) {
	                    Attachment att = getAttachment(attachmentId);	                    
	                    String newBody = '';
	                    if(att.Body != null) {
	                        newBody = EncodingUtil.base64Encode(att.Body);
	                        //system.debug(newBody);
	                    }
	                    newBody += attachmentBody;
	                    att.Body = EncodingUtil.base64Decode(newBody);
	                    if(attachmentId == '') {
	                        att.Name = attachmentName;
	                        att.parentId = contactId;
	                    }
	                    system.debug(att);
	                    upsert att;
	                    return att.Id;
	                } else {
	                    return 'Attachment Body was null';
	                }            
	        } else {
	            return 'Contact Id was null';
	        }
        }catch(Exception ex){
        	system.debug(ex.getMessage());
        	return '';
        }
        
    }
    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
	/*
		Add new Contact
	*/
	@remoteAction
	global static JsonResult addContact(String jsonObject){
		try{
		//system.debug(jsonObject);		
		MF_Contact contact = (MF_Contact)JSON.deserialize(jsonObject, MF_Contact.class);
        system.debug(contact);
		if(contact!=null && contact.Id!=null){			
			// internal Contact			
			if(contact.ContactType=='Internal') {							
					Contact internal = new Contact();
					internal.FirstName = contact.FirstName;
					internal.LastName = contact.LastName;
					internal.MF_Approver__c = contact.ApproverId;
					internal.Email = contact.Email;
					internal.Contact_Type__c = contact.ContactType;
					internal.Username__c = contact.UserName;
					internal.Birthdate = Date.ValueOf(contact.BirthDate);
					internal.Address__c = contact.Address;
					internal.Phone = contact.Phone;
					internal.Fax = contact.Fax;
					internal.MF_Department__c = contact.Department;
					internal.IsActive__c = true;
					insert internal;
					return new JsonResult(true,internal,'');
			}else{ 
						Contact external = new Contact();
						external.FirstName = contact.FirstName;
						external.LastName = contact.LastName;
						external.Email = contact.Email;
						external.Contact_Type__c = contact.ContactType;
						external.Phone = contact.Phone;
						external.Fax = contact.Fax;
						external.Address__c = contact.Address;
						external.Tag__c = contact.Tag;
						external.Company_Name__c = contact.CompanyName;
						external.AccountId = contact.AccountId;
						external.Business_Card__c = contact.BusinessCardId;						
						external.Created_By_Contact__c = contact.Id ;					
						external.IsActive__c = true;
						insert external;
						return new JsonResult(true,external,'');
			}
		}else{
			return new JsonResult(false,null,'Can\'t Parse Json String To Contact Object!');
		}		
		}catch(DmlException ex){
			system.debug(ex.getMessage());
			if(ex.getMessage().contains('duplicate')){
				return new JsonResult(false,null,'Exception: Username is exist!'); 
			}else if(ex.getMessage().contains('invalid date')){
				return new JsonResult(false,null,'Exception: Date is invalid!'); 
			}
			else{
				return new JsonResult(false,null,'Exception: ' + ex.getMessage());
			}
		}
	}
	/*
		Update Contact Profile
	*/
	@remoteAction
	global static JsonResult updateContact(String jsonObject){
		try{
			MF_Contact contact = (MF_Contact)JSON.deserialize(jsonObject, MF_Contact.class);		
			if(contact!=null){
				Contact con = [Select Id,FirstName,LastName,BirthDate,Email,Phone,Fax,Address__c,Skype_Account__c 
							   From Contact where Id=: contact.Id];
				con.Address__c = contact.Address;
				con.Phone = contact.Phone;
				con.Fax = contact.Fax;
				con.Skype_Account__c = contact.Skype;
				con.Email = contact.Email;
				con.BirthDate = Date.ValueOf(contact.BirthDate);
				con.MF_Approver__c = contact.ApproverId;
				update con;
				return new JsonResult(true,con,'');
			}else{
				return new JsonResult(false,null,'Can\'t Parse Json String To Contact Object!');
			}		
		}catch(JSONException ex){
			system.debug(ex.getMessage());
			return new JsonResult(false,null,'Exception: ' + ex.getMessage());
		}
	}
	/*
		Get List Department
	*/
	@remoteAction
	global static List<MF_Department__c> getDepartments(String BranchId){
		return [Select Id,Name From MF_Department__c Where MF_Branch__c =: BranchId];
	}
	/*
		Get list internal contact 
	*/
	@remoteAction
	global static List<Contact> getContacts(){
		List<Contact> arr = [Select UserName__c From Contact where Contact_Type__c=: 'Internal'];
		system.debug(arr);
		return arr;
	}
	/*
		Get list account
	*/
	@remoteAction
	global static List<Account> getAccounts(){
		return [Select Id,Name From Account];
	}
	/*
		Get list user license salesforce
	*/
	@remoteAction
	global static List<User> getUsers(){
		Map<Id,Profile> profileIds = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile 
					where UserLicenseId  in (SELECT Id FROM UserLicense where name ='Salesforce')]);
		return [select Id,Name from user where profileId in:profileIds.Keyset()];
	}
	/*
		Get contact 
	*/
	@remoteAction
	global static Contact getContact(String contactId){
		Contact contact = [Select Id,FirstName,LastName,Birthdate,Phone,Fax,Address__c
						   ,Skype_Account__c,Email,MF_Approver__c 
						   From Contact where Id=: contactId];		
		return contact;
	}
	/*
		Get List Branch
	*/
	global List<MF_Branch__c> getBranchs(){
		return [Select Id,Name From MF_Branch__c];
	}	

	public PageReference logoutClick(){
		System.debug('Entering logout in controller');
		MF_UserAuthentication.logout();
		PageReference loginPage = new PageReference('/apex/MF_Login');
        loginPage.setRedirect(true);
        return loginPage;
	}	
	/*check Login in mulodo force page*/
	public PageReference checkLogin(){		
		PageReference loginPage = new PageReference('/apex/MF_Login');
		if(MF_UserAuthentication.cookieContactId==null || MF_UserAuthentication.cookieContactId == ''){
		MF_UserAuthentication.logout();		
        loginPage.setRedirect(true);   
        return loginPage;     
    	}
    	else
    	{
    		return null;
    	}
	}
}