@isTest
public class MAP_FieldOptionSettingsCCTest {
    public static final String FIELDS_SHOW_IN   = '{"' + MAP_CommonUtil.ENV_PREFIX + 'Segment__c":"セグメント","' + MAP_CommonUtil.ENV_PREFIX + 'Score__c":"スコア","' + MAP_CommonUtil.ENV_PREFIX + 'CompanyCode__c":"法人ID"}';
    public static final String FIELDS_HIDDEN_IN = '{"' + MAP_CommonUtil.ENV_PREFIX + 'Shihon__c":"資本金カテゴリ","' + MAP_CommonUtil.ENV_PREFIX + 'Revenue__c":"売上カテゴリ","' + MAP_CommonUtil.ENV_PREFIX + 'Pref__c":"地域",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Lead_Converted__c":"Lead Converted","' + MAP_CommonUtil.ENV_PREFIX + 'Account_Converted__c":"Account Converted","' + MAP_CommonUtil.ENV_PREFIX + 'IsConvertFail__c":"IsConvertFail",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Zip__c":"郵便番号","' + MAP_CommonUtil.ENV_PREFIX + 'Tel__c":"電話","' + MAP_CommonUtil.ENV_PREFIX + 'Shogonor__c":"企業名nor",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Shogo__c":"企業名","' + MAP_CommonUtil.ENV_PREFIX + 'RegistedDate__c":"報告日","' + MAP_CommonUtil.ENV_PREFIX + 'Pub__c":"上場区分",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'PageUrl__c":"ページURL","' + MAP_CommonUtil.ENV_PREFIX + 'PageURLnor__c":"ページURLnor","' + MAP_CommonUtil.ENV_PREFIX + 'OrgId__c":"企業ID",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Mail__c":"メールアドレス","' + MAP_CommonUtil.ENV_PREFIX + 'IsUsedAPIData__c":"APIのデータ使用","' + MAP_CommonUtil.ENV_PREFIX + 'IsConverted__c":"変換済",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'HPURLnor__c":"HPURLnor","' + MAP_CommonUtil.ENV_PREFIX + 'HPURL__c":"HPURL","' + MAP_CommonUtil.ENV_PREFIX + 'Gyoshu__c":"業種",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Fax__c":"Fax","' + MAP_CommonUtil.ENV_PREFIX + 'ExternalKey__c":"External Key","' + MAP_CommonUtil.ENV_PREFIX + 'Emp__c":"従業員カテゴリ",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Addnor__c":"住所nor","' + MAP_CommonUtil.ENV_PREFIX + 'Add__c":"住所","' + MAP_CommonUtil.ENV_PREFIX + 'Name":"MAP_TargetCompany Name",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'OwnerId":"Owner ID"}';

	public static final String FIELDS_SHOW_IN_2  = '{"' + MAP_CommonUtil.ENV_PREFIX + 'Segment__c":"セグメント","' + MAP_CommonUtil.ENV_PREFIX + 'Score__c":"スコア","' + MAP_CommonUtil.ENV_PREFIX + 'CompanyCode__c":"法人ID" ,"' + MAP_CommonUtil.ENV_PREFIX + 'Revenue__c":"売上カテゴリ"}';
    public static final String FIELDS_HIDDEN_IN_2= '{"' + MAP_CommonUtil.ENV_PREFIX + 'Shihon__c":"資本金カテゴリ","' + MAP_CommonUtil.ENV_PREFIX + 'Pref__c":"地域",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Lead_Converted__c":"Lead Converted","' + MAP_CommonUtil.ENV_PREFIX + 'Account_Converted__c":"Account Converted","' + MAP_CommonUtil.ENV_PREFIX + 'IsConvertFail__c":"IsConvertFail",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Zip__c":"郵便番号","' + MAP_CommonUtil.ENV_PREFIX + 'Tel__c":"電話","' + MAP_CommonUtil.ENV_PREFIX + 'Shogonor__c":"企業名nor",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Shogo__c":"企業名","' + MAP_CommonUtil.ENV_PREFIX + 'RegistedDate__c":"報告日","' + MAP_CommonUtil.ENV_PREFIX + 'Pub__c":"上場区分",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'PageUrl__c":"ページURL","' + MAP_CommonUtil.ENV_PREFIX + 'PageURLnor__c":"ページURLnor","' + MAP_CommonUtil.ENV_PREFIX + 'OrgId__c":"企業ID",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Mail__c":"メールアドレス","' + MAP_CommonUtil.ENV_PREFIX + 'IsUsedAPIData__c":"APIのデータ使用","' + MAP_CommonUtil.ENV_PREFIX + 'IsConverted__c":"変換済",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'HPURLnor__c":"HPURLnor","' + MAP_CommonUtil.ENV_PREFIX + 'HPURL__c":"HPURL","' + MAP_CommonUtil.ENV_PREFIX + 'Gyoshu__c":"業種",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Fax__c":"Fax","' + MAP_CommonUtil.ENV_PREFIX + 'ExternalKey__c":"External Key","' + MAP_CommonUtil.ENV_PREFIX + 'Emp__c":"従業員カテゴリ",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'Addnor__c":"住所nor","' + MAP_CommonUtil.ENV_PREFIX + 'Add__c":"住所","' + MAP_CommonUtil.ENV_PREFIX + 'Name":"MAP_TargetCompany Name",'
												 + '"' + MAP_CommonUtil.ENV_PREFIX + 'OwnerId":"Owner ID"}';

    private static List<MAP_FieldOption__c> createFieldSetting() {
        List<MAP_FieldOption__c> lstOld = [SELECT Id, Type__c, FieldsOfType__c
							                 FROM MAP_FieldOption__c
							                LIMIT 2];
		delete lstOld;

    	List<MAP_FieldOption__c> lstFieldOption = new List<MAP_FieldOption__c>();

    	MAP_FieldOption__c  fieldOptionShow = new MAP_FieldOption__c();
    	fieldOptionShow.Type__c = MAP_AppContants.DISPLAY_FIELD;
    	fieldOptionShow.FieldsOfType__c = FIELDS_SHOW_IN;
        
        lstFieldOption.add(fieldOptionShow);

    	MAP_FieldOption__c  fieldOptionHide = new MAP_FieldOption__c();
    	fieldOptionHide.Type__c = MAP_AppContants.HIDDEN_FIELD;
    	fieldOptionHide.FieldsOfType__c = FIELDS_HIDDEN_IN;
        
        lstFieldOption.add(fieldOptionHide);
        insert lstFieldOption;

        return lstFieldOption;
    }

    // Case have no data, status new.
    private static void createFieldSettingStart() {

    	List<MAP_FieldOption__c> lstOld = [SELECT Id, Type__c, FieldsOfType__c
							                 FROM MAP_FieldOption__c
							                LIMIT 2];
		delete lstOld;
    }

	@isTest 
	public static void getFieldsSettingTest1(){
		createFieldSettingStart();
		List<MAP_FieldOption__c> lstResult = MAP_FieldOptionSettingsCC.getFieldsSetting();
		MAP_FieldOption__c fieldOptionShow = lstResult.get(0);
		MAP_FieldOption__c fieldOptionHide = lstResult.get(1);

		System.assertEquals(fieldOptionShow.FieldsOfType__c.equalsIgnoreCase('') , true);

	}

	@isTest
	public static void getFieldsSettingTest2(){
		List<MAP_FieldOption__c> lstFieldOption =  createFieldSetting();
		MAP_FieldOption__c fieldInputShow = lstFieldOption.get(0);
		MAP_FieldOption__c fieldInputHide = lstFieldOption.get(1);

		List<MAP_FieldOption__c> lstResult = MAP_FieldOptionSettingsCC.getFieldsSetting();
		MAP_FieldOption__c fieldOptionShow = lstResult.get(0);
		MAP_FieldOption__c fieldOptionHide = lstResult.get(1);

		System.assertEquals(fieldInputShow.FieldsOfType__c.equalsIgnoreCase(fieldOptionShow.FieldsOfType__c) , true);
		System.assertEquals(fieldInputHide.FieldsOfType__c.equalsIgnoreCase(fieldOptionHide.FieldsOfType__c) , true);

	}

	@isTest
	public static void saveFieldsSettingTest1() {
        createFieldSettingStart();        
        MAP_JsonResult result =  MAP_FieldOptionSettingsCC.saveFieldsSetting(FIELDS_SHOW_IN, FIELDS_HIDDEN_IN);
        List<MAP_FieldOption__c> lstSetting = MAP_FieldOptionSettingsCC.getFieldsSetting();

        System.assertEquals(result.success , true);
        System.assertEquals(lstSetting.get(0).FieldsOfType__c.equalsIgnoreCase(FIELDS_SHOW_IN) , true);
        System.assertEquals(lstSetting.get(1).FieldsOfType__c.equalsIgnoreCase(FIELDS_HIDDEN_IN) , true);
	}

	@isTest
	public static void saveFieldsSettingTest2() {
        createFieldSetting();
        MAP_JsonResult result =  MAP_FieldOptionSettingsCC.saveFieldsSetting(FIELDS_SHOW_IN_2, FIELDS_HIDDEN_IN_2);
        List<MAP_FieldOption__c> lstSetting = MAP_FieldOptionSettingsCC.getFieldsSetting();

        System.assertEquals(result.success , true);
        System.assertEquals(lstSetting.get(0).FieldsOfType__c.equalsIgnoreCase(FIELDS_SHOW_IN_2) , true);
        System.assertEquals(lstSetting.get(1).FieldsOfType__c.equalsIgnoreCase(FIELDS_HIDDEN_IN_2) , true);
        
	}

}