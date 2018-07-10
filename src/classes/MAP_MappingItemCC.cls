global with sharing class MAP_MappingItemCC {
	public static String itemAccount {get;set;}
    public static String itemLead {get;set;}
    public static String prefix {get;set;}
    
    public MAP_MappingItemCC() {
        List<MAP_ItemMapping__c> lstItemMapping = [SELECT Account_ITA__c, Lead_ITA__c 
                                                   FROM MAP_ItemMapping__c 
                                                   LIMIT 1];
 
        if (lstItemMapping != null && lstItemMapping.size() > 0) {
            itemAccount = lstItemMapping.get(0).Account_ITA__c;
            itemLead = lstItemMapping.get(0).Lead_ITA__c;
        }
        prefix = MAP_CommonUtil.ENV_PREFIX_JS;
    }

    @RemoteAction
    global static  Map<String, String> getObjectLabelNames(String nameObject){
        return MAP_CommonUtil.getObjectFields(nameObject);
    }

    @RemoteAction
    global static  Map<String, String> getObjectTypeFields(String nameObject){
        return MAP_CommonUtil.getObjectTypeFields(nameObject);
    }

    @RemoteAction
    global static  MAP_JsonResult saveAction(String mappingAccountItemList, String mappingLeadItemList){
        // check FLS
        String[] modifyFields = new String[]{'Account_ITA__c','Lead_ITA__c'};
        Map<String,Schema.SObjectField> fieldMaps = Schema.SObjectType.MAP_ItemMapping__c.fields.getMap();
        
        if(!MAP_CommonUtil.checkFLS(modifyFields, MAP_CommonUtil.FLSType.UPDATE_OBJECT, fieldMaps) 
            || !MAP_CommonUtil.checkFLS(modifyFields, MAP_CommonUtil.FLSType.CREATE_OBJECT, fieldMaps)){
            return new MAP_JsonResult(false,null,Label.MAP_Error_DoNotHavePermission);
        }
        
        String msg;
        List<MAP_ItemMapping__c> lstMappingItem = [SELECT Id 
                                                   FROM MAP_ItemMapping__c 
                                                   LIMIT 1];
        MAP_ItemMapping__c mappingItem;
        Savepoint sp = Database.setSavepoint();
        try {

             if (lstMappingItem != null && lstMappingItem.size() > 0) {
                    mappingItem = lstMappingItem[0];
                    delete mappingItem;
              }
              
              mappingItem = new MAP_ItemMapping__c(Account_ITA__c = mappingAccountItemList, Lead_ITA__c = mappingLeadItemList);
              insert mappingItem;
              msg = 'データの保存に成功しました。';

        } catch (DmlException ex) {

            // An exception was caught. We need to revert back to our Savepoint
            Database.rollback(sp);
            // Add the error to the page for the user to see
            msg =  ex.getDmlMessage(0);

            return new MAP_JsonResult(false, null, msg);
        }

        return new MAP_JsonResult(true, null, msg);
    }
}