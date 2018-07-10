global with sharing class Tools_GeneralBatchClassCC {

	public static Tools_ActionResult creatWrapperClass(String wrapperClass, String objMapping,String className, List<Tools_GeneralBatchCC.KeyMappingObj> lstKeyMapping, List<Tools_GeneralBatchCC.FieldMappingObj> lstFieldMapping) {
		String[] errors = new String[]{};
		String jsonString;

		//reRenderClassName
		className = singularLabel(className);

		String body = 'global with sharing class '+className+' implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {\\n';

		body += genTabKey(1)+'// WRAPPER DATA FROM 3RD JSON STRING\\n';
    	body += genTabKey(1)+'global '+wrapperClass+' wrapper;\\n';
    	body += genTabKey(1)+'// LIST DATA WANNA SYNC\\n';
    	body += genTabKey(1)+'global List<'+objMapping+'> updateList;\\n';
    	body += genTabKey(1)+'global '+className+'() {\\n';
    	body += genTabKey(2)+'updateList = new List<'+objMapping+'>();\\n';
    	body += genTabKey(2)+'// GET DATA FROM 3RD API\\n';
    	body += genTabKey(2)+'//wrapper = getDataFromAPI();\\n';
    	body += genTabKey(1)+'}\\n';
    	body += genTabKey(1)+'// GET DATA FROM API AND SYNC TO SFDC\\n';
    	body += genStartFunction(objMapping, wrapperClass, lstKeyMapping, lstFieldMapping);
    	body += genTabKey(1)+'// MAP DATA\\n';
    	body += genExecuteFunction(objMapping, wrapperClass, lstKeyMapping, lstFieldMapping);
    	body += genTabKey(1)+'// Finish SYNC DATA TO SFDC \\n';
    	body += genFinishFunction();
		body += '}';
		
		jsonString = '{ "Name" : "'+className+'", "Body" : "'+body+'" }';
		
		Httprequest req = new HttpRequest();
		req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v27.0/sobjects/ApexClass');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
		req.setBody(jsonString);

		Http httpReq = new Http();
		HttpResponse res = new HttpResponse();
		res = httpReq.send(req);
		if(res.getStatusCode() != 201) {
			String resString = res.getBody();
			List<HttpResJSON> resJson = (List<HttpResJSON>)JSON.deserialize(res.getBody(), List<HttpResJSON>.class);
			errors.add(resJson[0].errorCode);
			return new Tools_ActionResult(errors.isEmpty(), null, errors);
		} else {
			return new Tools_ActionResult(true, null, null);
		}
	}

	private static String genStartFunction(String objMapping, String wrapperClass, List<Tools_GeneralBatchCC.KeyMappingObj> lstKeyMapping, List<Tools_GeneralBatchCC.FieldMappingObj> lstFieldMapping) {
		
		Set<String> selectfield = new Set<String>();

		for(Tools_GeneralBatchCC.KeyMappingObj kmObj : lstKeyMapping) {
			selectfield.add(kmObj.objKey);
		}

		for(Tools_GeneralBatchCC.FieldMappingObj fmObj : lstFieldMapping) {
			selectfield.add(fmObj.objField);
		}

		String s = genTabKey(1)+'global List<'+objMapping+'> start(Database.BatchableContext BC) {\\n';
		s += genTabKey(2)+'Map<String,'+wrapperClass+'> mapApiWrappers = new Map<String,'+wrapperClass+'>();\\n';
		s += genTabKey(2)+String.format('return [Select {0} from Contact Limit 10000];\\n', new String[] {String.join(new List<String>(selectfield), ',')});
		s += genTabKey(1)+'}\\n';

		return s;
	}

	private static String genExecuteFunction(String objMapping, String wrapperClass, List<Tools_GeneralBatchCC.KeyMappingObj> lstKeyMapping, List<Tools_GeneralBatchCC.FieldMappingObj> lstFieldMapping) {
		
		//List<String> selectfield = new List<String>();

		//for(Tools_GeneralBatchCC.KeyMappingObj kmObj : lstKeyMapping) {
		//	selectfield.add(kmObj.objKey);
		//}

		//for(Tools_GeneralBatchCC.FieldMappingObj fmObj : lstFieldMapping) {
		//	selectfield.add(fmObj.objField);
		//}

		String s = genTabKey(1)+'global void execute(Database.BatchableContext BC,List<'+objMapping+'> scope){\\n';
		//s += genTabKey(2)+'Map<String,'+wrapperClass+'> mapApiWrappers = new Map<String,'+wrapperClass+'>();\\n';
		//s += genTabKey(2)+String.format('return [Select {0} from Contact Limit 10000];\\n', new String[] {String.join(selectfield, ',')});
		s += genTabKey(1)+'}\\n';

		return s;
	}

	private static String genFinishFunction() {

		String s = genTabKey(1)+'global void finish(Database.BatchableContext BC){\\n';
		s += genTabKey(1)+'}\\n';

		return s;
	}

	private static String genTabKey(Integer numTab){
		String tab = '';
		for(Integer i = 0; i < numTab; i++) {
			tab += '\\t';
		}
		return tab;
	}

	private static string singularLabel(String param) {
		String target = param.replaceAll('[^a-zA-Z0-9|_]', '_');
		String regExp = '[a-zA-Z]{1}';
		String regExpForSpecial = '^(_){1,10}';
		target = target.replaceFirst(regExpForSpecial, '');
		String replacement = target.left(1).toUpperCase();
		return target.replaceFirst(regExp, replacement);
	}

	global class HttpResJSON {
		String errorCode {get;set;} 
	}
}