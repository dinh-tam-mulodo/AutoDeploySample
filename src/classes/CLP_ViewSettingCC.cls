/**
 * CLP_ViewSettingCC.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: ViewSettingPage controller
 */
global with sharing class CLP_ViewSettingCC {

    // get view setting by current user
	@RemoteAction
	global static CLP_JsonResult getViewSettings(){
        try{
            Set<String> VISIBLE_FIELDS = new Set<String>{ 
                    CLP_CommonUtil.ENV_PREFIX+'Item_code__c'
                    ,CLP_CommonUtil.ENV_PREFIX+'Period_Unit__c'                    
                    ,CLP_CommonUtil.ENV_PREFIX+'SalesRecordedDate__c'
                    ,CLP_CommonUtil.ENV_PREFIX+'Period_Criterion__c'
                    ,CLP_CommonUtil.ENV_PREFIX+'ErrorMessage__c'};
			Map<String,String> fields = CLP_CommonUtil.getObjectFields('DemandDetail__c');
			List<ViewSettings__c> settings = [Select Id,Display_Field__c,Hidden_Field__c from ViewSettings__c 
								where User__c =: UserInfo.getUserId() limit 50000];
			List<ViewItem> items = new list<ViewItem>();
			String displayField = '';
			if(!settings.isEmpty()){
				displayField = settings[0].Display_Field__c;			
			}else{
                displayField = CLP_CommonUtil.DEFAULT_VIEW;
            }
			Set<String> setFields = new Set<String>();
			if(String.isNotBlank(displayField))
				setFields.addAll(displayField.split(','));
            system.debug('setFields:'+setFields);
			for(String f : setFields){
                if( f != 'Id' 
                    && f != CLP_CommonUtil.ENV_PREFIX+'ErrorMessage__c' 
                    && !CLP_CommonUtil.DEFAULT_VIEW.contains(f))
                {
    				ViewItem item = new ViewItem();
    				item.id = f;
    				item.label = fields.get(f);
    				item.isDisplay = true;
				    items.add(item);
                }
			}
            system.debug(items);
			for(String s : fields.keySet()){
				if((setFields.isEmpty() || !setFields.contains(s)) 
                    && ! CLP_CommonUtil.SYSTEM_FIELD.contains(s)
                    && ! VISIBLE_FIELDS.contains(s)
                    )
                {
					ViewItem item = new ViewItem();
					item.id = s;
					item.label = fields.get(s);
					item.isDisplay = false;
					items.add(item);
				}
			}
			return new CLP_JsonResult(true,items,'');
		}catch(Exception ex){
			return new CLP_JsonResult(false,null,ex.getMessage());
		}
	}
    // save view setting 
    @RemoteAction
    global static CLP_JsonResult save(String displayField,String hiddenField){
        try{
            displayField= !String.isBlank(displayField) ? String.format('Id,{0},{1},{2}ErrorMessage__c',
                                                                                new String[]{CLP_CommonUtil.DEFAULT_VIEW
                                                                                ,displayField
                                                                                ,CLP_CommonUtil.ENV_PREFIX}) 
                                                        : String.format('Id,{0},{1}ErrorMessage__c',
                                                                                new String[]{CLP_CommonUtil.DEFAULT_VIEW                                                                                
                                                                                ,CLP_CommonUtil.ENV_PREFIX}) ;

            String[] modifyFields = new String[]{'User__c','Display_Field__c','Hidden_Field__c'};            
            if(!CLP_CommonUtil.checkFLS('ViewSettings__c',modifyFields, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
                || !CLP_CommonUtil.checkFLS('ViewSettings__c',modifyFields, CLP_CommonUtil.FLSType.CREATE_OBJECT)){
                //system.debug(fieldMaps);
                return new CLP_JsonResult(false,null,'エラー：権限がありません。');
            }

            List<ViewSettings__c> settings = [Select Id,Display_Field__c,Hidden_Field__c from ViewSettings__c 
                                where User__c =: UserInfo.getUserId()];
            ViewSettings__c setting;                            
            if(!settings.isEmpty()){
                    setting = settings[0];
                    setting.Display_Field__c = displayField;
                    setting.Hidden_Field__c = hiddenField;
            }else{
                setting = new ViewSettings__c();
                setting.Display_Field__c = displayField;
                setting.Hidden_Field__c = hiddenField;
                setting.User__c = UserInfo.getUserId();
            }
            //system.debug(setting);
            Database.UpsertResult rs =  Database.upsert(setting,false);
            //system.debug(rs);
            return new CLP_JsonResult(rs.isSuccess(),setting,rs.getErrors().isEmpty() ? '' : rs.getErrors()[0].getMessage());                           
        }catch(Exception ex){
            return new CLP_JsonResult(false,null,ex.getMessage());
        }
    }

    global class ViewItem{
        public String id;
        public String label;
        public Boolean isDisplay;
    }  
}