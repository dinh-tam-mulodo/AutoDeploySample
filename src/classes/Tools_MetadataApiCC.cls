// what is it? let go ok version no 2
global with sharing class Tools_MetadataApiCC {

	public static Tools_ActionResult creatWrapperClass(String objData, String className) {
		String[] errors = new String[]{};
		String jsonString;

		//reRenderClassName
		className = singularLabel(className);

		List<ObjData> data = (List<ObjData>)JSON.deserialize(objData, List<ObjData>.class);

		String body = 'public class '+className+'{\\n';

		body+= generalWrapperClass(className, data);
		body+= generalInnerClass(className, data);

		body+=pareFunction(className);

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

	private static String generalWrapperClass(String className, List<ObjData> objData) {

		String body = '';
		String objKey;

		Map<String, String> itemInclued = new Map<String, String>();

		for(ObjData obj: objData) {
			itemInclued.put(obj.key, obj.dataType);
			if(obj.dataType != 'List' && obj.dataType != 'Object') {
				body+= genTabKey(1)+'public '+obj.dataType+' '+reGeneralName(obj.key)+' {get; set;}\\n';
			}
			else if(obj.dataType == 'List') {
				objKey = singularLabel(obj.key);

				body+= genTabKey(1)+'public List<'+objKey+'> '+reGeneralName(obj.key)+' {get; set;}\\n';

			}
			else if(obj.dataType == 'Object') {
				objKey = singularLabel(obj.key);

				body+= genTabKey(1)+'public '+objKey+' '+reGeneralName(obj.key)+' {get; set;}\\n';
			}
		}

		// General main cuntrustor
		String innerContrus = '';
		Integer i = 0;
		//general item in contrustor
		for(String itemName : itemInclued.keySet()) {
			String reRenderName = reGeneralName(itemName);
			if(i == 0) {
				innerContrus += genTabKey(5)+'if (text == \''+itemName+'\') {\\n';
				innerContrus += genTabKey(6)+reRenderName+' = '+genPareType(itemName, itemInclued.get(itemName));
				innerContrus +=	genTabKey(5)+'}';
			}
			else {
				innerContrus += ' else if (text == \''+itemName+'\') {\\n';
				innerContrus +=	genTabKey(6)+reRenderName+' = '+genPareType(itemName, itemInclued.get(itemName));
				innerContrus +=	genTabKey(5)+'}';
			}

			if (i == (itemInclued.size() - 1)) {
				innerContrus += ' else {\\n'+
									genTabKey(6)+'System.debug(LoggingLevel.WARN, \''+className+' consuming unrecognized property: \'+text);\\n'+
									genTabKey(6)+'consumeObject(parser);\\n'+
								genTabKey(5)+'} \\n';
			}
			i++;
		}

		if(String.isNotBlank(innerContrus)) {
			body += '\\n'+genTabKey(1)+'public '+className+'(JSONParser parser) {\\n';
			body +=	genTabKey(2)+'while (parser.nextToken() != System.JSONToken.END_OBJECT) {\\n';
			body +=	genTabKey(3)+'if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {\\n';
			body +=	genTabKey(4)+'String text = parser.getText();\\n';
			body +=	genTabKey(4)+'if (parser.nextToken() != System.JSONToken.VALUE_NULL) {\\n';
			body += innerContrus;
			body += genTabKey(4)+'}\\n';
			body +=	genTabKey(3)+'}\\n';
			body +=	genTabKey(2)+'}\\n';
			body += genTabKey(1)+'}\\n';
		}

		return body;
	}

	private static Map<String, String> getListInnerClass(List<ObjData> objData) {
		Map<String, String> returnData = new Map<String, String>();
		//String key = 'API_Wrapper';
		
		for(ObjData obj: objData) { 
			if(obj.childKey != null) {
				returnData.put(obj.key, obj.dataType);
				returnData.putAll(getListInnerClass(obj.childKey));
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
			cls.dataType = obj.dataType;
			cls.properties = obj.key;
			classDefines.add(cls);
			if(obj.childKey != null) {
				classDefines.addAll(getLstItemInner(obj.key, obj.childKey));
			}
		}
		return classDefines;
	}

	private static String generalInnerClass(String className, List<ObjData> objData) {

		Map<String, String> innerClassNameLst = getListInnerClass(objData);
		List<ClassDefine> innerItemLst = getLstItemInner(className, objData);
		
		String body='';
		for(String innerClassName: innerClassNameLst.keySet()) { 

			// Map<itemName, itemType> list included
			Map<String, String> itemInclued = new Map<String, String>();

			body +='\\n'+genTabKey(1)+'public class '+singularLabel(innerClassName)+'{\\n';
			String item ='';
			// Select list item of class
			for(ClassDefine obj: innerItemLst) {
				// reRender item name
				String itemName = reGeneralName(obj.properties);
				
				//check item is child of class and not included
				if(obj.clsName == innerClassName && itemInclued.get(obj.properties) == null) {
					String objKey ='';
					itemInclued.put(obj.properties, obj.dataType);
					if(obj.dataType != 'List' && obj.dataType != 'Object') {
						item+= genTabKey(2)+'public '+obj.dataType+' '+itemName+' {get; set;}\\n';
					}
					else if(obj.dataType == 'List') {
						objKey = singularLabel(obj.properties);

						item+= genTabKey(2)+'public List<'+objKey+'> '+itemName+' {get; set;}\\n';

					}
					else if(obj.dataType == 'Object') {
						objKey = singularLabel(obj.properties);

						item+= genTabKey(2)+'public '+objKey+' '+itemName+' {get; set;}\\n';
					}
				}
			}
			if(!String.isBlank(item)) {
				body+=item;

				String innerContrus = '';
				Integer i = 0;
				//general item in contrustor
				for(String itemName : itemInclued.keySet()) {
					String reRenderName = reGeneralName(itemName);
					if(i == 0) {
						innerContrus += genTabKey(6)+'if (text == \''+itemName+'\') {\\n';
						innerContrus += genTabKey(7)+reRenderName+' = '+genPareType(itemName, itemInclued.get(itemName));
						innerContrus +=	genTabKey(6)+'}';
					}
					else {
						innerContrus += ' else if (text == \''+itemName+'\') {\\n';
						innerContrus +=	genTabKey(7)+reRenderName+' = '+genPareType(itemName, itemInclued.get(itemName));
						innerContrus +=	genTabKey(6)+'}';
					}

					if (i == (itemInclued.size() - 1)) {
						innerContrus += ' else {\\n';
						innerContrus +=	genTabKey(7)+'System.debug(LoggingLevel.WARN, \''+singularLabel(innerClassName)+' consuming unrecognized property: \'+text);\\n';
						innerContrus +=	genTabKey(7)+'consumeObject(parser);\\n';
						innerContrus +=	genTabKey(6)+'}\\n';
					}
					i++;
				}

				if(String.isNotBlank(innerContrus)) {
					body += '\\n'+genTabKey(2)+'public '+singularLabel(innerClassName)+'(JSONParser parser) {\\n';
					body +=	genTabKey(3)+'while (parser.nextToken() != System.JSONToken.END_OBJECT) {\\n';
					body +=	genTabKey(4)+'if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {\\n';
					body +=	genTabKey(5)+'String text = parser.getText();\\n';
					body +=	genTabKey(5)+'if (parser.nextToken() != System.JSONToken.VALUE_NULL) {\\n';
					body += innerContrus;
					body += genTabKey(5)+'}\\n';
					body +=	genTabKey(4)+'}\\n';
					body +=	genTabKey(3)+'}\\n';
					body += genTabKey(2)+'}\\n';
				}
			}

			body+= '\\t}\\n';

			if(innerClassNameLst.get(innerClassName) == 'List') {
				body+= arrayPareFunction(singularLabel(innerClassName));
			}
		}


		return body;
	}

	//General main function auto pare json to wrapper class
	private static String pareFunction (String className) {
		String f = '\\n'+genTabKey(1)+'public static '+className+' parse(String json) {\\n'+
			genTabKey(2)+'System.JSONParser parser = System.JSON.createParser(json);\\n'+
			genTabKey(2)+'return new '+className+'(parser);\\n'+
			genTabKey(1)+'}\\n'+
			genTabKey(1)+'\\npublic static void consumeObject(System.JSONParser parser) {\\n'+
				genTabKey(2)+'Integer depth = 0;\\n'+
				genTabKey(2)+'do {\\n'+
					genTabKey(3)+'System.JSONToken curr = parser.getCurrentToken();\\n'+
					genTabKey(3)+'if (curr == System.JSONToken.START_OBJECT ||\\n'+
						genTabKey(4)+'curr == System.JSONToken.START_ARRAY) {\\n'+
						genTabKey(4)+'depth++;\\n'+
					genTabKey(3)+'} else if (curr == System.JSONToken.END_OBJECT ||\\n'+
						genTabKey(4)+'curr == System.JSONToken.END_ARRAY) {\\n'+
						genTabKey(4)+'depth--;\\n'+
					genTabKey(3)+'}\\n'+
				genTabKey(2)+'} while (depth > 0 && parser.nextToken() != null);\\n'+
			genTabKey(1)+'}\\n';
		return f;
	}

	//General function pare json to inner class
	private static String arrayPareFunction (String target) {
		String f = '\\n'+genTabKey(1)+'private static List<'+target+'> arrayOf'+target+'(System.JSONParser p) {\\n'+
				        genTabKey(2)+'List<'+target+'> res = new List<'+target+'>();\\n'+
				        genTabKey(2)+'if (p.getCurrentToken() == null) p.nextToken();\\n'+
				        genTabKey(2)+'while (p.nextToken() != System.JSONToken.END_ARRAY) {\\n'+
				            genTabKey(3)+'res.add(new '+target+'(p));\\n'+
				        genTabKey(2)+'}\\n'+
				        genTabKey(2)+'return res;\\n'+
				    genTabKey(1)+'}\\n';
		return f;
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

	private static string singularLabel(String param) {
		String target = param.replaceAll('[^a-zA-Z0-9|_]', '_');
		String regExp = '[a-zA-Z]{1}';
		String regExpForSpecial = '^(_){1,10}';
		target = target.replaceFirst(regExpForSpecial, '');
		String replacement = target.left(1).toUpperCase();
		return target.replaceFirst(regExp, replacement);
	}

	private static string genPareType(String itemName, String dataType) {
		String pareDataType = 'parser.';
		if(dataType == 'Boolean')            {return pareDataType+'getBooleanValue();\\n';}
		if(dataType == 'Id')                 {return pareDataType+'getText();\\n';}
		if(dataType == 'String')             {return pareDataType+'getText();\\n';}
		if(dataType == 'Blob')               {return pareDataType+'getBlobValue();\\n';}
		if(dataType == 'Date')               {return pareDataType+'getDateValue();\\n';}
		if(dataType == 'Datetime')           {return pareDataType+'getDatetimeValue();\\n';}
		if(dataType == 'Time')               {return pareDataType+'getTimeValue();\\n';}
		if(dataType == 'Integer')            {return pareDataType+'getIntegerValue();\\n';}
		if(dataType == 'Long')               {return pareDataType+'getLongValue();\\n';}
		if(dataType == 'Decimal')            {return pareDataType+'getDecimalValue();\\n';}  
		if(dataType == 'Double')             {return pareDataType+'getDoubleValue();\\n';}
		if(dataType == 'Object') 			 {return 'new '+singularLabel(itemName)+'(parser);\\n';}
		if(dataType == 'List') 			 	 {return 'arrayOf'+singularLabel(itemName)+'(parser);\\n';}
		return pareDataType;
	}

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
		String dataType {get;set;}
		String properties {get;set;}
	}

	global class HttpResJSON {
		String errorCode {get;set;} 
	}

}