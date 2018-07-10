global with sharing class MAP_FieldOptionSettingsCC {
    public static String prefix {get;set;}

    public MAP_FieldOptionSettingsCC(){
        prefix = MAP_CommonUtil.ENV_PREFIX_JS;
    }
    
    // Execute when save fields to show on screen
    @RemoteAction
    global static MAP_JsonResult saveFieldsSetting(String showFields, String hideFields) {
        // Get fields setting at present
        List<MAP_FieldOption__c> lstFieldsOptPresent = getListFieldOpt();

        // check FLS
		String[] modifyFields = new String[]{'Type__c','FieldsOfType__c'};
        Map<String,Schema.SObjectField> fieldMaps = Schema.SObjectType.MAP_FieldOption__c.fields.getMap();
        
        if(!MAP_CommonUtil.checkFLS(modifyFields, MAP_CommonUtil.FLSType.UPDATE_OBJECT, fieldMaps) 
        	|| !MAP_CommonUtil.checkFLS(modifyFields, MAP_CommonUtil.FLSType.CREATE_OBJECT, fieldMaps)){
			return new MAP_JsonResult(false,null,Label.MAP_Error_DoNotHavePermission);
		}
        
        // Setting with show/hidden type
        MAP_FieldOption__c fieldsOptShow ;
        MAP_FieldOption__c fieldsOptHide ;

        if (lstFieldsOptPresent == null || lstFieldsOptPresent.size() == 0) {
            fieldsOptShow = new MAP_FieldOption__c();
            fieldsOptHide = new MAP_FieldOption__c();
        } else {
            fieldsOptShow = lstFieldsOptPresent.get(0);
            fieldsOptHide = lstFieldsOptPresent.get(1);
        }
        
        // Item contains showfield.
        fieldsOptShow.Type__c = MAP_AppContants.DISPLAY_FIELD;
        fieldsOptShow.FieldsOfType__c = showFields;
        
        // Item contains hidefield.
        fieldsOptHide.Type__c = MAP_AppContants.HIDDEN_FIELD;
        fieldsOptHide.FieldsOfType__c = hideFields;

        // Update setting field in Database
        String errMsg = '';
        try {
            if(lstFieldsOptPresent.size() > 0){
                upsert lstFieldsOptPresent;
            }
        } catch (DmlException ex) {
            errMsg = 'データを挿入する時にエラーが発生しました。';
        }

		return new MAP_JsonResult(true, null, errMsg);
    }

    // Execute when load screen
    @RemoteAction
    global static List<MAP_FieldOption__c> getFieldsSetting() {
        Map<String,String> fieldsRoot = MAP_CommonUtil.getObjectFields('MAP_TargetCompany__c');
        List<MAP_FieldOption__c> lstFieldStatus = getListFieldOpt();
        String fieldDisplay = '';
        
        Map<String, Object> mapHideFields  = new Map<String, Object>();

        // Setting list fields show/hide on screen
        if (lstFieldStatus != null && lstFieldStatus.size() > 0 ) {
            fieldDisplay = lstFieldStatus.get(0).FieldsOfType__c;
        } else {
            fieldDisplay = '';
        }

        // Setting hidden fields            
        for (String key : fieldsRoot.keySet()) {            
            if (!fieldDisplay.contains(key))
                mapHideFields.put(key, fieldsRoot.get(key));
        }

        lstFieldStatus.get(1).FieldsOfType__c = JSON.serialize(mapHideFields);
               
        
        return lstFieldStatus;
    }
    
    // Get fields setting from Database
    private static List<MAP_FieldOption__c> getListFieldOpt() {
        return [SELECT Id, Type__c, FieldsOfType__c
               FROM MAP_FieldOption__c
               LIMIT 2];
    }
}