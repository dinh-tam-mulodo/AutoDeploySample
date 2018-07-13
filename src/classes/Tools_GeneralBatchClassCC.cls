global with sharing class Tools_GeneralBatchClassCC {

	public static Tools_ActionResult creatWrapperClass(String wrapperClass, String objMapping, String jsonObjMapping, String className, String mappingCondition,List<Tools_GeneralBatchCC.KeyMappingObj> lstKeyMapping, List<Tools_GeneralBatchCC.FieldMappingObj> lstFieldMapping) {
		String[] errors = new String[]{};
		String jsonString;

		ApexClass classAp = new ApexClass();

		//reRenderClassName
		className = singularLabel(className);

		String body = 'global with sharing class '+className+' implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {\\n';

		body += genContrustorFunction(objMapping, jsonObjMapping, className);
		
    	body += genTabKey(1)+'// GET DATA FROM API AND SYNC TO SFDC\\n';
    	body += genStartFunction(objMapping, wrapperClass, lstKeyMapping, lstFieldMapping);
    	body += genTabKey(1)+'// MAP DATA\\n';
    	body += genExecuteFunction(objMapping, jsonObjMapping, lstKeyMapping, lstFieldMapping, mappingCondition);
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
			System.debug('err >>> ' + res.getBody());
			String resString = res.getBody();
			List<HttpResJSON> resJson = (List<HttpResJSON>)JSON.deserialize(res.getBody(), List<HttpResJSON>.class);
			errors.add(resJson[0].errorCode);
			return new Tools_ActionResult(errors.isEmpty(), null, errors);
		} else {
			return new Tools_ActionResult(true, null, null);
		}
	}

	private static String genContrustorFunction(String objMapping, String jsonObjMapping, String className) {
		

		String body = genTabKey(1)+'// WRAPPER DATA FROM 3RD JSON STRING\\n';
		
		body += genTabKey(1)+'global List<'+jsonObjMapping+'> '+jsonObjMapping.split('\\.')[1].toLowerCase()+';\\n';
		

    	body += genTabKey(1)+'// LIST DATA WANNA SYNC\\n';
    	body += genTabKey(1)+'global List<'+objMapping+'> updateList;\\n';
    	body += genTabKey(1)+'global '+className+'() {\\n';
    	body += genTabKey(2)+'updateList = new List<'+objMapping+'>();\\n';
    	body += genTabKey(2)+'// GET DATA FROM 3RD API\\n';
    	body += genTabKey(2)+'//'+jsonObjMapping.split('\\.')[1].toLowerCase()+' = getDataFromAPI();\\n';
    	body += genTabKey(1)+'}\\n';

    	return body;
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
		s += genTabKey(2)+String.format('return [Select {0} from Contact Limit 10000];\\n', new String[] {String.join(new List<String>(selectfield), ',')});
		s += genTabKey(1)+'}\\n';

		return s;
	}

	private static String genExecuteFunction(String objMapping, String jsonObjMapping, List<Tools_GeneralBatchCC.KeyMappingObj> lstKeyMapping, List<Tools_GeneralBatchCC.FieldMappingObj> lstFieldMapping, String mappingCondition) {
		
		Set<String> setApiWrapper = new Set<String>();

		for(Tools_GeneralBatchCC.KeyMappingObj key: lstKeyMapping) {
			SelectOptionField jsonKey = (SelectOptionField) JSON.deserialize(key.jsonKey, SelectOptionField.class);
			setApiWrapper.add(jsonKey.jsonType);
		}

		for(Tools_GeneralBatchCC.FieldMappingObj field: lstFieldMapping) {
			SelectOptionField jsonField = (SelectOptionField) JSON.deserialize(field.jsonField, SelectOptionField.class);
			setApiWrapper.add(jsonField.jsonType);
		}

		String s = genTabKey(1)+'global void execute(Database.BatchableContext BC,List<'+objMapping+'> scope){\\n';
		
		s += genTabKey(2)+'// map data from api and update into contact\\n';
		s += genTabKey(2)+'for('+jsonObjMapping+' wrap : '+jsonObjMapping.split('\\.')[1].toLowerCase()+'){\\n';
		s += genTabKey(3)+'for('+objMapping+' con : scope){\\n';
		s += genConditionMappingCode(mappingCondition, jsonObjMapping, lstKeyMapping, lstFieldMapping);
		s += genTabKey(3)+'}\\n';
		s += genTabKey(2)+'}\\n';
		
		s += genTabKey(2)+'// update con\\n';
		s += genTabKey(2)+'if(!updateList.isEmpty()) {\\n';
		s += genTabKey(3)+'update updateList;\\n';
		s += genTabKey(2)+'}\\n';
		s += genTabKey(1)+'}\\n';

		return s;
	}

	private static String genFinishFunction() {

		String s = genTabKey(1)+'global void finish(Database.BatchableContext BC){\\n';
		s += genTabKey(1)+'}\\n';

		return s;
	}

	private static String genInnerMappingCode(String jsonType, List<Tools_GeneralBatchCC.FieldMappingObj> lstFieldMapping) {
		String s = '';
		//Create mapping key condition
		for(Tools_GeneralBatchCC.FieldMappingObj key: lstFieldMapping) {
			SelectOptionField item = (SelectOptionField) JSON.deserialize(key.jsonField, SelectOptionField.class);	
			if(jsonType == item.jsonType) {
				s += genTabKey(5)+'con.'+key.objField+' = wrap.'+reGeneralName(item.key)+';\\n';
			}else {
				s += genTabKey(5)+'con.'+key.objField+' = wrap.'+reGeneralName(item.jsonType.split('\\.')[1].toLowerCase())+' != null ? wrap.'+reGeneralName(item.jsonType.split('\\.')[1].toLowerCase())+'.'+reGeneralName(item.key)+' : null;\\n';
			}
		}

		s += genTabKey(5)+'// add record into update list\\n';
    	s += genTabKey(5)+'updateList.add(con);\\n';

		return s;
	}

	private static String genConditionMappingCode(String mappingCondition, String jsonType, List<Tools_GeneralBatchCC.KeyMappingObj> lstKeyMapping, List<Tools_GeneralBatchCC.FieldMappingObj> lstFieldMapping) {
		
		String s = genTabKey(4)+'if({0})';

		List<String> condition = new List<String>();

		//Create mapping key condition
		for(Tools_GeneralBatchCC.KeyMappingObj key: lstKeyMapping) {
			SelectOptionField item = (SelectOptionField) JSON.deserialize(key.jsonKey, SelectOptionField.class);	
			if(jsonType == item.jsonType) {
				condition.add('wrap.'+reGeneralName(item.key)+' == con.'+key.objKey);
			} else {
				condition.add('wrap.'+reGeneralName(item.jsonType.split('\\.')[1].toLowerCase())+'.'+reGeneralName(item.key)+' == con.'+key.objKey);
			}
		}

		String operator = mappingCondition == 'AND' ? ' && ' : mappingCondition == 'OR' ? ' || ' : ' AND ';

		if(lstKeyMapping.size() > 1) {
			s = String.format(s, new String[] { String.join(condition, operator) })+'{\\n';
		} else {
			s = String.format(s, new String[] {condition[0]})+'{\\n';
		}

		s += genInnerMappingCode(jsonType, lstFieldMapping);
		s += genTabKey(4)+'}\\n';

		return s;
	}

	//Check name item is valid for create class if invalid replace it
	private static String reGeneralName(String item) {

		Boolean isUpperCase = item.isAllUpperCase();

		// check item first char is number
		if(item.left(1).isNumeric()) {
			item = 'n_'+item;
		}
		// check item first char i special char
		else if(!item.left(1).isAlpha() && !item.left(1).isNumeric()) {
			item = 'x'+item.replaceAll('[^a-zA-Z0-9]', '_');
		}
		// check item has special name
		else if(item.toLowerCase() == 'class') {
			item += '_z';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'boolean') {
			item += '_b';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'id') {
			item += '_i';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'blob') {
			item += '_bl';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'date') {
			item += '_d';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'datetime') {
			item += '_dt';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'time') {
			item += '_t';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'string') {
			item += '_s';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'integer') {
			item += '_int';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'long') {
			item += '_l';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'decimal') {
			item += '_dec';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'dobuble') {
			item += '_dob';
		}
		// Check item has special name
		else if(item.toLowerCase() == 'list' 
			|| item.toLowerCase() == 'object' 
			|| item.toLowerCase() == 'map' 
			|| item.toLowerCase() == 'set') {

			item += '_o';

		}

		if(isUpperCase) {
			item = item.toUpperCase();
		}

		return item;
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

	global class SelectOptionField {
		global String key 						{get; set;}
		global String dataType     				{get; set;}
		global String jsonType  				{get; set;}
		global String jsonVariable  			{get; set;}
		global SelectOptionField parent     	{get; set;}
	}
}