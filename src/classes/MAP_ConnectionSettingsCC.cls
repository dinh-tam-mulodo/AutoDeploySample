global with sharing class MAP_ConnectionSettingsCC {
	public static String endpoint {get;set;}
	public static String authenticationId {get;set;}
	public static String tobeMEndpoint {get;set;}
	public static Boolean isUsed {get;set;}
	public static String hideFields {get;set;}
	public static String showFields {get;set;}
	public static String prefix {get;set;}

	public MAP_ConnectionSettingsCC(){
		MAP_ConnectionSetting__c setting = MAP_ConnectionSetting__c.getInstance();
		if(setting!=null) {
			endpoint = String.isEmpty(setting.Endpoint__c) ? '' : setting.Endpoint__c;
			authenticationId = String.isEmpty(setting.AuthenticationID__c) ? '' : setting.AuthenticationID__c;
			tobeMEndpoint = String.isEmpty(setting.TobeMEndpoint__c) ? '' : setting.TobeMEndpoint__c;
			isUsed = setting.IsUseCompanyInfo__c;
			prefix = MAP_CommonUtil.ENV_PREFIX_JS;
		}
	}

	@RemoteAction
	global static MAP_JsonResult saveConnectionSetting(String jsonObject){
		MAP_ConnectionSetting__c setting = MAP_ConnectionSetting__c.getInstance();
		Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
		setting.AuthenticationID__c = (String)results.get('AuthenticationID');
		setting.Endpoint__c = (String)results.get('EndPoint');
		setting.TobeMEndpoint__c = (String)results.get('TobeMEndPoint');
		setting.IsUseCompanyInfo__c = (String)results.get('isUsed') == 'true';
		update setting;
		
		return new MAP_JsonResult(true, null, 'Save Successfully');
	}
}