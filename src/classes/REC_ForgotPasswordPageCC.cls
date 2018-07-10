public with sharing class REC_ForgotPasswordPageCC {
	public String username{get;set;}
	public String message{get;set;}
	public String messageType{get;set;}
	public static final String ENV_PREFIX = getPrefix();

	public static String generateRandomString(Integer len) {
    	final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    	String randStr = '';
    	while (randStr.length() < len) {
       		Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       		randStr += chars.substring(idx, idx+1);
    	}
    	return randStr; 
	}

	public static String getPrefix(){
        ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'REC_ForgotPasswordPageCC'];
        String nameSpacePrefix = cs.NamespacePrefix;
        if(String.isEmpty(nameSpacePrefix)) {
            nameSpacePrefix = '';
        } else {
            nameSpacePrefix+='__';
        }
        return nameSpacePrefix;
    } 

	public static String getSalesforceBaseUrlForVF() {

        // 組織情報からインスタンス名を取得する。
        Organization o = [
            Select Id, InstanceName
            From Organization
            Where Id =: UserInfo.getOrganizationId()
        ];
        String sfInstanceName = o.InstanceName.toLowerCase();
        String[] urlSplit = System.URL.getSalesforceBaseUrl().toExternalForm().split('\\.');
        String sfInstanceNameOrCustomDomain;
        if (urlSplit.size() > 0) {
            sfInstanceNameOrCustomDomain = urlSplit.get(0).replace('https://', '');
        }

        String baseUrl;
        String prefix = ENV_PREFIX.length() > 2 ? ENV_PREFIX.subString(0,ENV_PREFIX.length()-2) : ENV_PREFIX;
        if (sfInstanceNameOrCustomDomain != null && sfInstanceName != null 
        	&& !sfInstanceName.equals(sfInstanceNameOrCustomDomain) ) {
        	if(String.isEmpty(prefix)){
        		baseUrl = 'https://' + sfInstanceNameOrCustomDomain+'.' + sfInstanceName + '.visual.force.com';
        	}else{
        		baseUrl = 'https://' + sfInstanceNameOrCustomDomain+'--'+prefix.toLowerCase()+'.' + sfInstanceName + '.visual.force.com';
        	}
        } else {
            baseUrl = 'https://'+prefix.toLowerCase()+'.' + sfInstanceName + '.visual.force.com';
        }
        return baseUrl;
    }

    public void removeCookie(){
        Cookie usernameCookie = new Cookie('Rec_Username', '', null, 0, false);
        Cookie ipAdressCookie = new Cookie('Rec_IpAddress', '', null, 0, false);
        Cookie passwordCookie = new Cookie('Rec_Password', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie, passwordCookie, ipAdressCookie});
    }

	public PageReference validateUsername(){
		try{
			CustomUser__c user = [SELECT Id, Password__c, Email__c from CustomUser__c WHERE Username__c = :username LIMIT 1];
			user.Password__c = generateRandomString(8);
			update user;
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	String[] toAddresses = new String[] {user.Email__c};
        	mail.setToAddresses(toAddresses);
        	String domain = getSalesforceBaseUrlForVF();
        	String url = domain + '/apex/REC_LoginPage';
        	String subject = 'Updated Password';
        	String body = 'Dear '+username+'.<br/><br/>'+
        	'Your password has changed to <b>'+user.Password__c+'</b><br/><br/>'+
        	'Please use this password to login next time.<br/><br/>'+
        	'<a href="'+url+'">Click here to login</a><br/><br/>'+
        	'Best Regards<br/>';

        	mail.setSubject(subject);
        	mail.setHtmlBody(body);
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        	removeCookie();
			message = 'New password was sent to your email. Please check your email then login again';
			messageType = 'info-message';
			return null;

		} catch(System.QueryException qEx) {
			message = 'User is not existing';
			messageType = 'error-message';
			return null;
		}
		catch(Exception ex) {
			message = ex.getMessage();
			messageType = 'error-message';
			return null;
		}
	}
}