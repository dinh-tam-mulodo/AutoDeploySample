/**
 * CLP_CommonUtil.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: Common class
 */
public with sharing class CLP_CommonUtil {
    public static final String ENV_PREFIX = getPrefix();
    public static final String DEFAULT_VIEW = 'Name,' + ENV_PREFIX+'DemandDetailCode__c,'+ENV_PREFIX+'Account__c,' + ENV_PREFIX+'Seikyuusakibusho__c';
    public static final Set<String> SYSTEM_FIELD = new Set<String>{'Id','CreatedById','LastModifiedById','OwnerId','LastViewedDate','LastReferencedDate'};
    
    // get package prefix
    public static String getPrefix(){
        ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'CLP_CommonUtil'];
        String nameSpacePrefix = cs.NamespacePrefix;
        if(String.isEmpty(nameSpacePrefix)) {
            nameSpacePrefix = '';
        } else {
            nameSpacePrefix+='__';
        }
        return nameSpacePrefix;
    }
    // get current url
    public static String getSalesforceBaseUrlForVF() {

        // 組織情報からインスタンス名を取得する。
        Organization o = [
            Select Id, InstanceName
            From Organization
            Where Id =: UserInfo.getOrganizationId()
        ];
        String sfInstanceName = o.InstanceName.toLowerCase();
        // 「System.URL.getSalesforceBaseUrl()」を使用して「インスタンス名」または「カスタムドメイン」を取得する。
        // 　　※カスタムドメインを設定している場合、「System.URL.getSalesforceBaseUrl()」の戻り値の「https://」の次はカスタムドメインが
        // 　　　カスタムドメインを設定していない場合、インスタンス名が記載される前提
        String[] urlSplit = System.URL.getSalesforceBaseUrl().toExternalForm().split('\\.');
        String sfInstanceNameOrCustomDomain;
        if (urlSplit.size() > 0) {
            sfInstanceNameOrCustomDomain = urlSplit.get(0).replace('https://', '');
        }

        String baseUrl;
        String prefix = ENV_PREFIX.length() > 2 ? ENV_PREFIX.subString(0,ENV_PREFIX.length()-2) : ENV_PREFIX;

        // URLにインスタンス名が含まれていない( = カスタムドメインを使用している)場合、以下を行う。
        if (sfInstanceNameOrCustomDomain != null && sfInstanceName != null 
            && !sfInstanceName.equals(sfInstanceNameOrCustomDomain) 
            && !prefix.toLowerCase().equals(sfInstanceNameOrCustomDomain) ) {
            if(String.isEmpty(prefix)){
                baseUrl = 'https://' + sfInstanceNameOrCustomDomain+'--c.' + sfInstanceName + '.visual.force.com';
            }else{
                baseUrl = 'https://' + sfInstanceNameOrCustomDomain+'--'+prefix.toLowerCase()+'.' + sfInstanceName + '.visual.force.com';
            }
        // URLにインスタンス名が含まれている( = カスタムドメインを使用していない)場合、以下を行う。
        } else {
            baseUrl = 'https://'+prefix.toLowerCase()+'.' + sfInstanceName + '.visual.force.com';
        }
        return baseUrl;
    }
    // get object prefix
    public static String getObjectPrefix(String objectName){
        try{
            objectName = objectName.contains('__c') ? ENV_PREFIX + objectName : objectName;
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{objectName});
            if(results.size()>0){
                Schema.DescribeSobjectResult rs = results[0];
                return  rs.getKeyPrefix();
            }
            return '';
        }catch(Exception ex){
            return '';
        }
    }

    // get field id 
    public static String getCustomFieldId(String objectName,String fieldName){
        objectName = objectName.contains('__c') ? ENV_PREFIX + objectName : objectName;
        fieldName = fieldName.contains('__c') ? ENV_PREFIX + fieldName : fieldName;
        List<FieldDefinition> fds = [Select EntityDefinitionId,DurableId,QualifiedApiName,Label,Length ,DataType From FieldDefinition where EntityDefinition.QualifiedApiName=: objectName];
        String fieldId = '';
        for(FieldDefinition f : fds){
            if(f.QualifiedApiName == fieldName){
                fieldId = f.DurableId;
                return f.QualifiedApiName == 'RecordTypeId' ? fieldId.split('\\.')[0] : fieldId.split('\\.')[1];
            }
        }
        return fieldId;
    }

    // get related list url     
    public static String getRelatedListURL(String objectName,String fieldName, String lookupName, String lookupId){
        String instanceUrl = getSalesforceBaseUrlForVF();
        String objPrefix = getObjectPrefix(objectName);
        String fieldId = getCustomFieldId(objectName,fieldName);
        String fieldRecordType = getCustomFieldId(objectName,'RecordTypeId');
        // https://ap2.salesforce.com/a00/e?CF00N280000042hHT=TEST-15120801&CF00N280000042hHT_lkid=0012800000Ci7he&retURL=%2F0012800000Ci7he
        String relatedURLWithoutRecordType = String.format('{0}/{1}/e?CF{2}={3}&CF{2}_lkid={4}&retURL=%2F{4}',
                    new String[]{instanceUrl,objPrefix,fieldId,lookupName,lookupId});
        ////https://ap2.salesforce.com/setup/ui/recordtypeselect.jsp?ent=01I28000002NE2F&retURL=/0012800000Ci85H
        //&save_new_url=/a05/e?CF00N2800000IlS6f=%E8%A9%A6%E9%A8%931.1_release&CF00N2800000IlS6f_lkid=0012800000Ci85H&retURL=%2F0012800000Ci85H
        String relatedURLWithRecordType = String.format('{0}/setup/ui/recordtypeselect.jsp?ent={1}&retURL=/{2}&save_new_url=/{3}/e?CF{4}={5}&CF{4}_lkid={2}&retURL=%2F{2}',
                    new String[]{instanceUrl,fieldRecordType,lookupId,objPrefix,fieldId,lookupName});
        return String.isNotBlank(fieldRecordType) ? relatedURLWithRecordType : relatedURLWithoutRecordType;
    }

    // get object describe Map<apiname,label>
    public static Map< String, String> getObjectFields(String selectedObject) 
    {
        if(selectedObject.contains('__c'))
            selectedObject = ENV_PREFIX+selectedObject;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = schemaMap.get(selectedObject);
        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
        Map<String, String> fieldNames = new Map<String, String>();
        for (String fieldName: fieldMap.keySet()) 
        { 
            fieldNames.put(fieldMap.get(fieldName).getDescribe().getName(), fieldMap.get(fieldName).getDescribe().getLabel());  
        }
        return fieldNames;
    }

    // get object describe Map<apiname,label>
    public static Map< String, String> getFieldTypes(String selectedObject) 
    {
        selectedObject = selectedObject.contains('__c') ? ENV_PREFIX+selectedObject : selectedObject;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = schemaMap.get(selectedObject);
        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
        Map<String, String> fieldTypes = new Map<String, String>();
        for (String fieldName: fieldMap.keySet()) 
        { 
            fieldTypes.put(fieldMap.get(fieldName).getDescribe().getName(), String.valueOf(fieldMap.get(fieldName).getDescribe().getType()));  
        }
        return fieldTypes;
    }

    // check FLS
    public enum FLSType {CREATE_OBJECT, UPDATE_OBJECT}
    public static Boolean checkFLS(String objectName, String[] listUpdatedFields, FLSType type)
    {       
        //objectName = ENV_PREFIX + objectName;
        objectName = objectName.contains('__c') ? ENV_PREFIX + objectName : objectName;
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> m = objType.getDescribe().fields.getMap(); 
        if(type == FLSType.CREATE_OBJECT){
            for(String field : listUpdatedFields){                
                if(field.contains('__')){ //custom field
                    if(!m.get(ENV_PREFIX + field).getDescribe().isCreateable()){
                        system.debug('##### error CREATE_OBJECT: field ' + field  + ' is not creatable');
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
                //system.debug(field);
                if(field.contains('__')){ //custom field
                    if(!m.get(ENV_PREFIX + field).getDescribe().isUpdateable()){
                        system.debug('##### error UPDATE_OBJECT: field ' + field  + ' is not updateable');
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

    // undelete record
    public static void restoreData(List<SObject> deletedList,String objectName){
        try{
            String objWithPrefix = objectName.contains('__c') ? ENV_PREFIX + objectName : objectName;
            List<SObject> listToRestore = new List<SObject>();            
            for(SObject del : deletedList){
                sObject obj = Schema.getGlobalDescribe().get(objWithPrefix).newSObject() ;
                obj.put('Id',del.Id);
                obj.put('StopFlg__c',null);
                obj.put('IsStop__c',false);
                obj.put('IsIntegrated__c',false);
                obj.put('ManipulateStatus__c',CLP_MikataConstant.DEMAND_IN_EDIT);
                //obj.put('ErrorMessage__c','');                
                listToRestore.add(obj);
            }            
            String[] fields = new String[]{'ErrorMessage__c','IsIntegrated__c','IsStop__c','StopFlg__c','ManipulateStatus__c'};
            if(checkFLS(objectName,fields, FLSType.UPDATE_OBJECT)) 
            {
                update listToRestore;
            }
        }catch(Exception ex){
            system.debug('error:'+ex.getMessage());
            throw ex;
        }
    }

    public static Date convertJsonDate(String strDate){
        String[] dateSplit = String.isBlank(strDate) ? new String[]{} :  strDate.split('/');
        if(dateSplit.size()>2){ 
            date myDate = date.newInstance(Integer.valueOf(dateSplit[0])
                                            , Integer.valueOf(dateSplit[1])
                                            , Integer.valueOf(dateSplit[2]));
            return myDate;
        }
        return null;
    }
    /*// split - character and check this zipcode is a numeric
    public static String splitZipCode(String zipCode){
        String retZipCode = '';
        retZipCode = String.isBlank(zipCode) ? '' : zipCode.remove('-');
        try{
            Decimal.valueOf(retZipCode);
            if(retZipCode.length() != 7)
                retZipCode = '';
        }catch(Exception ex){
            retZipCode = '';
        }
        return retZipCode;
    }*/
}