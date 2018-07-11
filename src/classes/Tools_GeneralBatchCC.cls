global with sharing class Tools_GeneralBatchCC {
	global Tools_GeneralBatchCC() {
		
	}

	@RemoteAction
	global static Tools_ActionResult getGeneralJson (String param){
		
		ResObj paramData = new ResObj();
		try {
			paramData = (ResObj)JSON.deserialize(param, ResObj.class);
		} catch(JSONException e) {
			return new Tools_ActionResult(false, null, new String[] {e.getMessage()});
		}

		List<ObjData> rs = GeneralJson(paramData.jsonString);

		String className = paramData.className;

		////Generate class
		//if(!rs.isEmpty()) {
		//	Tools_ActionResult errors = Tools_MetadataApiCC.creatWrapperClass(JSON.serialize(rs), paramData.className);
		//	if(!errors.isSuccess) {
		//		return errors;
		//	}
		//}

		////Generate test class
		//if(!rs.isEmpty()) {
		//	Tools_ActionResult errors = Tools_MetaDataTestClassCC.creatWrapperTestClass(JSON.serialize(rs), paramData.jsonString,paramData.className);
		//	if(!errors.isSuccess) {
		//		return errors;
		//	}
		//}

		//Get list Sobject
		List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
		Map<String,String> objName = new Map<String,String>();
		for(Schema.SObjectType f : gd) {
			objName.put(f.getDescribe().getName().toLowerCase(), f.getDescribe().getLabel());
		}
		
		ActionResult res = new ActionResult();
		res.currentObjOrg = objName;
		res.jsonData = genJsonToOption(rs, null);

		return new Tools_ActionResult(!rs.isEmpty(), res, null);
	}

	//General batch class
	@RemoteAction
	global static Tools_ActionResult generalBatchClass(String data) {

		BatchObj paramData = new BatchObj();
		try {
			paramData = (BatchObj)JSON.deserialize(data, BatchObj.class);
		} catch(JSONException e) {
			return new Tools_ActionResult(false, null, new String[] {e.getMessage()});
		}

		String className = paramData.className;
		String objMapping = paramData.objMapping;
		String wrapperClass = paramData.wrapperClass;
		String mappingCondition = paramData.mappingCondition;

		Tools_ActionResult errors = Tools_GeneralBatchClassCC.creatWrapperClass(wrapperClass, objMapping, className, mappingCondition, paramData.lstMappingObj, paramData.lstMappingField);

		return errors;
		//return new Tools_ActionResult(false, null, null);
	}

	//Get List field off mapping object
	@RemoteAction
	global static Tools_ActionResult getCurrentLstField (String param){
		
		Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType objectType = gd.get(param);
		List<Schema.SObjectField> fields = objectType.getDescribe().fields.getMap().Values();

		List<OrgFieldData> lstFields = new List<OrgFieldData>();

		for(Schema.SObjectField field: fields) {
			OrgFieldData orgField = new OrgFieldData();

			orgField.label = field.getDescribe().getLabel();
			orgField.apiName = field.getDescribe().getName().toLowerCase();
			orgField.dataType = getFieldType(field.getDescribe().getType());
			lstFields.add(orgField);
		}

		//res.isSuccess = !lstFields.isEmpty();
		//res.data = lstFields;
		return new Tools_ActionResult(!lstFields.isEmpty(), lstFields, null);
	}

	private static List<ObjData> GeneralJson (String json_instance) {
		List<ObjData> genJSON = new List<ObjData>();
		if(checkIsList(json_instance)) {
			List<Object> rs = (List<Object>)JSON.deserializeUntyped(json_instance);
			for(Object data: rs) {
				List<ObjData> dataList = GeneralJson(JSON.serialize(data));
				genJSON.addAll(dataList);
			}
		} else {
			Map<String, Object> rs = (Map<String, Object>)JSON.deserializeUntyped(json_instance);
		
			for(String keyName: rs.keySet()) {

				//if(keyName.toLowerCase() != 'class' && !keyName.left(1).isNumeric()) {
					ObjData objData = new ObjData();
					objData.key = keyName;
					objData.dataType = getType(rs.get(keyName));
					if(isValidJSON(JSON.serialize(rs.get(keyName))) || checkIsList(JSON.serialize(rs.get(keyName)))) {
						List<ObjData> data = GeneralJson(JSON.serialize(rs.get(keyName)));
						objData.childKey = data;
					}

					genJSON.add(objData);
				//} else{
				//	continue;
				//}
			}
		}
		return genJSON;
	}

	private static List<SelectOptionField> genJsonToOption(List<ObjData> rs, SelectOptionField parent) {
		List<SelectOptionField> options = new List<SelectOptionField>();
		for(ObjData item: rs) {
			SelectOptionField option = new SelectOptionField();
			option.key = parent != null ? parent.key+'.'+item.key : item.key;
			option.dataType = item.dataType;
			option.parent = parent != null ? parent : null;
			options.add(option);
			if(item.childKey != null) {
				options.addAll(genJsonToOption(item.childKey, option));
			}
		}

		for(SelectOptionField sObj: options) {
			System.debug('sObj >>> ' + sObj);
		}

		return options;
	}

	private static boolean isValidJSON(String json_instance){
	    try{
	   		Map<String,Object> rs = (Map<String, Object>)JSON.deserializeUntyped(json_instance);
	        return true;
	    }catch(Exception e){
	        return false;
	    }
	}

	private static boolean checkIsList(String json_instance) {
		try {
			List<Object> rs = (List<Object>)JSON.deserializeUntyped(json_instance);
			return true;
		} catch(Exception e) {
			return false;
		}
	}

	private static string getType(Object o) {
		if(o==null) return '';              // we can't say much about null with our current techniques
		if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
		if(o instanceof Boolean)            return 'Boolean';
		if(o instanceof Id)                 return 'String';
		if(o instanceof String)             return 'String';
		if(o instanceof Blob)               return 'Blob';
		if(o instanceof Date)               return 'Date';
		if(o instanceof Datetime)           return 'Datetime';
		if(o instanceof Time)               return 'Time';
		if(o instanceof Integer)            return 'Integer';
		if(o instanceof Long)               return 'Long';
		if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
		if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
		if(o instanceof List<object>)       return 'List';
		return 'Object';                    // actually we can't detect maps and sets and maps
	}

	private static string getFieldType(Object fieldType) {
		if(fieldType==null) return '';     

		if(fieldType == Schema.DisplayType.String || 
			fieldType == Schema.DisplayType.TextArea ||
			fieldType == Schema.DisplayType.Id ||
			fieldType == Schema.DisplayType.Picklist ||
			fieldType == Schema.DisplayType.Reference ||
			fieldType == Schema.DisplayType.Phone ||
			fieldType == Schema.DisplayType.Email ||
			fieldType == Schema.DisplayType.URL)
		return 'String';

		if(fieldType == Schema.DisplayType.Double)
		return 'Double'; 

		if(fieldType == Schema.DisplayType.Currency)
		return 'Decimal';

		if(fieldType == Schema.DisplayType.Integer)
		return 'Integer';
		if(fieldType == Schema.DisplayType.Boolean)
		return 'Boolean';

		if(fieldType == Schema.DisplayType.DateTime)
		return 'DateTime';  

		if(fieldType == Schema.DisplayType.Date)
		return 'Date'; 

		if(fieldType == Schema.DisplayType.Time)
		return 'Time';

		if(fieldType == Schema.DisplayType.Combobox)
		return 'Combobox'; 

		if(fieldType == Schema.DisplayType.MultiPicklist)
		return 'MultiPicklist';

		if(fieldType == Schema.DisplayType.EncryptedString)
		return 'EncryptedString';

		if(fieldType == Schema.DisplayType.DataCategoryGroupReference)
		return 'DataCategoryGroupReference';  

		if(fieldType == Schema.DisplayType.base64 )
		return 'base64 ';

		return 'UNKNOWN';    
	}

	global class ObjData {
		String key   			{get; set;}
		String dataType 		{get; set;}
		List<ObjData> childKey 	{get; set;}
	}

	global class OrgFieldData {
		String label 		{get; set;}
		String apiName 		{get; set;}
		String dataType 	{get; set;}
	}

	global class ActionResult{
		Object jsonData 		{get; set;}
		Object currentObjOrg 	{get; set;}
	}

	global class ResObj{
		String className 	{get; set;}
		String jsonString 	{get; set;}
	}

	global class BatchObj{
		String wrapperClass 					{get; set;}
		String objMapping 						{get; set;}
		String className 						{get; set;}
		String mappingCondition 				{get; set;}
		Boolean isRunAfterGen 					{get; set;}
		List<KeyMappingObj> lstMappingObj 		{get; set;}
		List<FieldMappingObj> lstMappingField 	{get; set;}
	}

	global class KeyMappingObj{
		global String jsonKey	{get; set;}
		global String objKey 	{get; set;}
	}

	global class FieldMappingObj{
		global String jsonField 	{get; set;}
		global String objField 		{get; set;}
	}

	global class SelectOptionField {
		global String key 						{get; set;}
		global String dataType     				{get; set;}
		global SelectOptionField parent     	{get; set;}
	}
}