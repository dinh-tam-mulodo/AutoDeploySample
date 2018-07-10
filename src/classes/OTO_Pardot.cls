public with sharing class OTO_Pardot {

	public OTO_Pardot (){
	}

	public static HttpResponse httpCallout(String url, String body){
        HttpRequest     request     = new HttpRequest();
        HttpResponse    response    = new HttpResponse();
        Http            http        = new Http();

        request.setEndPoint(url);
        request.setBody(body);
        request.setMethod('POST');

        /* Try to send the request */
        try {
            response = http.send(request);
            System.debug('::RESPONSE::'+response.getBody());
            return response;
        } catch(System.CalloutException e) {
            System.debug('ERROR: '+ e);
            return null;
        }
	}

	public static OneToOne__c getSetting(){
		return OneToOne__c.getInstance('test');
	}

	public static String getUserKey() {
		OneToOne__c obj = getSetting();
		return EncodingUtil.urlEncode(obj.Pardot_UserKey__c, 'UTF-8');
	}

	public static String getEmail() {
		OneToOne__c obj = getSetting();
		return EncodingUtil.urlEncode(obj.Pardot_ID__c, 'UTF-8');
	}

	public static String getPassword() {
		OneToOne__c obj = getSetting();
		return EncodingUtil.urlEncode(obj.Pardot_PW__c, 'UTF-8');
	}

	public static String getApiKey() {
		OneToOne__c setting = getSetting();

		system.debug(setting);

		String email = getEmail();
		String password = getPassword();
		String user_key = getUserKey();

		String url = 'https://pi.pardot.com/api/login/version/3';

		String body = 'email='+ email+ '&password='+ password;
		body += '&user_key=' + user_key;

		system.debug(url);
		system.debug(body);
		HttpResponse response = httpCallout(url, body);
		system.debug(response);

		Dom.Document doc = new Dom.Document();
        doc.load(response.getBody());
        Dom.XMLNode root = doc.getRootElement();
        if(root.getName()=='rsp') {
            for(Dom.XMLNode node1: root.getChildElements()) {
                if(node1.getName()=='err') {
                    String err = root.getChildElement('err', null).getText();
                    String code = root.getChildElement('err', null).getAttribute('code', null);
                    System.debug('::API REQUEST ERROR:: '+code+' - '+err);
                    return err;
                }

                if(node1.getName()=='api_key') {
                    /* Store API in variable */
                    // TODO: Store API for 1 hour in Global__c
                    String api_key = root.getChildElement('api_key', null).getText();
                    return api_key;
                }
            }
		}

		return '';
	}

	@future (callout=true)
    private static void AsyncAPIRequest(String url, String body){
    	String userKey = getUserKey();
    	String apiKey = getAPIKey();

        HttpResponse response = httpCallout( url, 'user_key='+ userKey +'&api_key='+ apiKey +'&'+ body );
        system.debug(response);
	}

	//@future (callout=true)
    private static HttpResponse SyncAPIRequest(String url, String body){
    	String userKey = getUserKey();
    	String apiKey = getAPIKey();

        HttpResponse response = httpCallout( url, 'user_key='+ userKey +'&api_key='+ apiKey +'&'+ body );
        system.debug(response);
        return response;
	}

	public static List<SObject> getAllProspect() {
		String url = 'https://pi.pardot.com/api/prospect/version/4/do/query';
		String body = 'id_greater_than=0';
		HttpResponse response = SyncAPIRequest(url, body);
		List<Prospect> prospects = getAPIResult(response.getBody());
		System.debug(prospects);

		return null;
	}

	public static void sendMail(List<String> prospects){
        for (String s :prospects) {
            AsyncAPIRequest(
                'https://pi.pardot.com/api/email/version/4/do/send/prospect_id/' + s , 
                'campaign_id='+ '5085' + '&email_template_id=7710' // Required parameter
            );
            //System.debug('::PARDOT EMAIL::'+c.Email);
    	}
	}

	public static List<Prospect> getAPIResult(String body){
		if (String.isBlank(body)) {
			return null;
		}
		List<Prospect> result = new List<Prospect>();
		try {
			Dom.Document doc = new Dom.Document();
	        doc.load(body);
	        Dom.XMLNode root = doc.getRootElement();
	        if(root.getName()=='rsp') {
	            for(Dom.XMLNode node: root.getChildElements()) {
	                if(node.getName()=='err') {
	                    String err = root.getChildElement('err', null).getText();
	                    String code = root.getChildElement('err', null).getAttribute('code', null);
	                    System.debug('::API REQUEST ERROR:: '+code+' - '+err);
	                    return result;
	                }

	                if(node.getName()=='result') {
	                	for(Dom.XMLNode child : node.getChildElements()){
	                		if (child.getName() == 'prospect'){
	                			Prospect p = new Prospect();
		                		p.id = child.getChildElement('id', null).getText();
		                		p.email = child.getChildElement('email', null).getText();
		                		p.created_at = child.getChildElement('created_at', null).getText();
		                		p.updated_at = child.getChildElement('updated_at', null).getText();

		                		result.add(p);
	                		}
	                	}
	                }
	            }
			}
		} catch (Exception ex) {
			System.debug(ex.getMessage());
			System.debug(ex.getLineNumber());
			return null;
		}
		
		return result;
	}

	public class Prospect {
		public String id {get;set;}
		public String email {get;set;}
		public String created_at {get;set;}
		public String updated_at {get;set;}
	}
}