global with sharing class Tools_MetaDataTestClassCC {

	public static Tools_ActionResult creatWrapperTestClass(String objData, String jsonParamStr,String className) {
		String[] errors = new String[]{};
		String jsonString;

		//Remove all \t, \n, \r in json string
		jsonParamStr = jsonParamStr.replaceAll('[\t|\n|\r]', '');
		//genral format json
		jsonParamStr = JSON.serialize(jsonParamStr);
		//remove " in first and last string;
		jsonParamStr = jsonParamStr.substring(1, jsonParamStr.length() - 1);

		//reRenderClassName
		className = singularLabel(className);

		List<ObjData> data = (List<ObjData>)JSON.deserialize(objData, List<ObjData>.class);

		String body = '@isTest public class '+className+'Test {\\n';

		body+= generalTestMethod(data, jsonParamStr, className);

		body += '}';

		jsonString = '{ "Name" : "'+className+'Test", "Body" : "'+body+'" }';
		
		Httprequest req = new HttpRequest();
		req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v27.0/sobjects/ApexClass');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
		req.setBody(jsonString);

		Http httpReq = new Http();
		HttpResponse res = new HttpResponse();
		res = httpReq.send(req);
		System.debug('res.getBody() >>> ' + res.getBody());
		if(res.getStatusCode() != 201) {
			String resString = res.getBody();
			List<HttpResJSON> resJson = (List<HttpResJSON>)JSON.deserialize(res.getBody(), List<HttpResJSON>.class);
			errors.add(resJson[0].errorCode);
			return new Tools_ActionResult(errors.isEmpty(), null, errors);
		} else {
			return new Tools_ActionResult(true, null, null);
		}
		
		//return new Tools_ActionResult(true, null, null);
	}

	private static String generalTestMethod(List<ObjData> objData,String param, String className) {
		String testMethodStr = '';

		//Get all innerClass in objData
		Set<String> innerClassNameLst = getListInnerClass(className, objData);

		//Get all item in objData
		List<ClassDefine> items = getLstItemInner(className, objData);

		//General test case for succes case
		testMethodStr += genTabKey(1)+'@isTest static void testSuccess() {\\n';
		testMethodStr += genTabKey(2)+'String js = \''+param+'\';\\n';	
		testMethodStr += genTabKey(2)+className+'.parse(js);\\n';	
		testMethodStr += genTabKey(2)+'System.assert(true);\\n';	
		testMethodStr += genTabKey(1)+'}\\n';

		// General test case for false case
		for(String innerClassName: innerClassNameLst) {
			String paramString = param;
			Set<String> itemReplaced = new Set<String>();
			testMethodStr += genTabKey(1)+'@isTest static void test'+innerClassName+'Error() {\\n';
				for(ClassDefine item: items) {
					if(!itemReplaced.contains(item.properties) && item.clsName == innerClassName) {
						paramString = paramString.replace(item.properties, item.properties+'Wrong');
						itemReplaced.add(item.properties);
					}
				}
			testMethodStr += genTabKey(2)+'String js = \''+paramString+'\';\\n';	
			testMethodStr += genTabKey(2)+className+'.parse(js);\\n';	
			testMethodStr += genTabKey(2)+'System.assert(true);\\n';	
			testMethodStr += genTabKey(1)+'}\\n';
		}

		return testMethodStr;
	}

	//Get all item is innerclass
	private static Set<String> getListInnerClass(String firstClassName, List<ObjData> objData) {
		Set<String> returnData = new Set<String>();
		if(firstClassName != null) {
			returnData.add(firstClassName);
		}
		for(ObjData obj: objData) { 
			if(obj.childKey != null) {
				returnData.add(obj.key);
				returnData.addAll(getListInnerClass( null,obj.childKey));
			}
		}
		return returnData;
	}

	private static List<ClassDefine> getLstItemInner(String className, List<ObjData> objData) {
		List<ClassDefine> classDefines = new List<ClassDefine>();
		for(ObjData obj: objData) { 
			// put properties for class
			ClassDefine cls = new ClassDefine();
			cls.clsName = className;
			cls.properties = obj.key;
			classDefines.add(cls);
			if(obj.childKey != null) {
				classDefines.addAll(getLstItemInner(obj.key, obj.childKey));
			}
		}
		return classDefines;
	}

	private static string singularLabel(String param) {
		String target = param.replaceAll('[^a-zA-Z0-9|_]', '_');
		String regExp = '[a-zA-Z]{1}';
		String regExpForSpecial = '^(_){1,10}';
		target = target.replaceFirst(regExpForSpecial, '');
		String replacement = target.left(1).toUpperCase();
		return target.replaceFirst(regExp, replacement);
	}

	//General tab charecter for string
	private static String genTabKey(Integer numTab){
		String tab = '';
		for(Integer i = 0; i < numTab; i++) {
			tab += '\\t';
		}
		return tab;
	}

	global class ObjData {
		String key   {get; set;}
		String dataType {get; set;}
		List<ObjData> childKey {get; set;}
	}

	global class ClassDefine{
		String clsName {get;set;}
		String properties {get;set;}
	}

	global class HttpResJSON {
		String errorCode {get;set;} 
	}
}