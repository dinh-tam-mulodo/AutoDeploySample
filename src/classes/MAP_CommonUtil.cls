public with sharing class MAP_CommonUtil {
	public static final String ENV_PREFIX = getPrefix();
    public static final String ENV_PREFIX_JS = getPrefixJS();
    private static Set<String> systemFields = new Set<String>{'MasterRecordId','Id', 'IsDeleted', 'CreatedById','CreatedDate','LastModifiedById','LastModifiedDate','SystemModstamp', MAP_CommonUtil.ENV_PREFIX + 'IsImported__c'};

	public static String getPrefix(){
		String nameSpacePrefix = '';
		try{
			ApexClass cs =[SELECT NamespacePrefix FROM ApexClass WHERE Name =:'MAP_CommonUtil'];
	        if(!String.isEmpty(cs.NamespacePrefix)) {
	            nameSpacePrefix = cs.NamespacePrefix + '__';
	        }
		}catch(Exception ex){
			return '';
		}
        return nameSpacePrefix;
    }
    public static String getPrefixJS(){
        String nameSpacePrefix = '';
        try{
            ApexClass cs =[SELECT NamespacePrefix FROM ApexClass WHERE Name =:'MAP_CommonUtil'];
            if(!String.isEmpty(cs.NamespacePrefix)) {
                nameSpacePrefix = cs.NamespacePrefix + '.';
            }
        }catch(Exception ex){
            return '';
        }
        return nameSpacePrefix;
    }
    
    // Get all fields object.
    public static Map< String, String> getObjectFields(String selectedObject) 
     {
            // If this object is custom object
            if(selectedObject.contains('__c')) {
                selectedObject = ENV_PREFIX + selectedObject;
            }

            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objectSchema = schemaMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
            Map<String, String> fieldNames = new Map<String, String>();

            // Create data object fields
            for (String fieldName: fieldMap.keySet()) {
                if (!systemFields.contains(fieldMap.get(fieldName).getDescribe().getName())
                    && fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                    fieldNames.put(fieldMap.get(fieldName).getDescribe().getName(), fieldMap.get(fieldName).getDescribe().getLabel());
                }    
            }

            return fieldNames;
      }

      // Get all fields Type.
      public static Map< String, String> getObjectTypeFields(String selectedObject) {
            if(selectedObject.contains('__c')) {
                selectedObject = ENV_PREFIX + selectedObject;
            }

            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(selectedObject);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            Map<String, String> fieldTypes = new Map<String, String>();
            Schema.DisplayType fieldDataType;

            for (String fieldName: fieldMap.keySet()) { 
                fieldDataType = fieldMap.get(fieldName).getDescribe().getType();
                
                fieldTypes.put(fieldName, String.valueOf(fieldDataType));
            }

      return fieldTypes;
    }

    public enum FLSType {CREATE_OBJECT, UPDATE_OBJECT}
    public static Boolean checkFLS(String[] listUpdatedFields, FLSType type, Map<String,Schema.SObjectField> fieldsMap)
    {       
        Map<String,Schema.SObjectField> m = fieldsMap;
        if(type == FLSType.CREATE_OBJECT){
            for(String field : listUpdatedFields){                
                if(field.contains('__')){ //custom field
                    if(!m.get(ENV_PREFIX + field).getDescribe().isCreateable()){
                        return false;
                    }   
                } else { //standard field
                    if(!m.get(field).getDescribe().isCreateable()){
                        return false;
                    }
                }
            }   
        }
        if(type == FLSType.UPDATE_OBJECT){
            for(String field : listUpdatedFields){
                system.debug(field);
                if(field.contains('__')){ //custom field
                    if(!m.get(ENV_PREFIX + field).getDescribe().isUpdateable()){
                        return false;
                    }   
                } else { // standard field
                    if(!m.get(field).getDescribe().isUpdateable()){
                        return false;
                    }
                }   
            }   
        }
        return true;
    }

    public static String calloutRESTApi(String url){
    	Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(url);
		request.setMethod('GET');
		HttpResponse response = http.send(request);
		// If the request is successful, parse the JSON response.
		if (response.getStatusCode() == 200) {
		    return response.getBody();
		}
		return null;
    }

    public static String calloutRESTApiMethodPost(String url,String body){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        System.debug(response.getStatusCode());
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            return response.getBody();
        }
        return null;
    }

    public static Integer countRecord(String objectName){
        try{
            String query =  'SELECT count() FROM ' + String.escapeSingleQuotes(objectName);
            return Database.countQuery(query);  
        }catch(Exception ex){
            return 0;
        }
    }

    public static Integer countRecord(String objectName, string whereStatement){
        try{
            String query =  'SELECT count() FROM ' + String.escapeSingleQuotes(objectName) + whereStatement;
            return Database.countQuery(query);  
        }catch(Exception ex){
            return 0;
        }
    }

}