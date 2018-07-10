@isTest
public class MAP_CompanyUploadCsvTest
{
	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Decription: Target company test data
    */	
	private static MAP_TargetCompany__c createTargetCompany(){
		MAP_TargetCompany__c comp = new MAP_TargetCompany__c();
		comp.Name = 'Company Name';
		comp.HPURL__c = 'https://www.lightningdesignsystem.com/components/data-tables/';
		comp.Add__c = 'ホーチミン';
		comp.Addnor__c = 'ベトナム';
		comp.CompanyCode__c = 'CompanyCode__c';
		comp.Emp__c = 'Emp__c';
		comp.Fax__c = '11ff';
		comp.Gyoshu__c = '1315_一般機械';
		comp.HPURLnor__c = 'lightningdesignsystem.com';
		comp.Mail__c = 'abc@gmail.com';
		comp.OrgId__c = '12345';
		comp.PageURLnor__c = 'www.electrictoolbox.com';
		comp.PageUrl__c = 'https://www.electrictoolbox.com/javascript-add-options-html-select/';
		comp.RegistedDate__c = '201704';
		comp.Score__c = 1;
		comp.Segment__c = 'クラウド';
		comp.Shogo__c = '空の境界';
		comp.Shogonor__c = '空';
		comp.Tel__c = '03-3743-6111';
		comp.Zip__c = '144-8510';

		insert comp;

		return comp;
	}

	private static List<MAP_TargetCompany__c> createLstTargetCompany(){
		List<MAP_TargetCompany__c> lstTargetCompany = new List<MAP_TargetCompany__c>();

		MAP_TargetCompany__c comp = new MAP_TargetCompany__c();
		comp.Name = 'Company Name';
		comp.HPURL__c = 'https://www.lightningdesignsystem.com/components/data-tables/';
		comp.Add__c = 'ホーチミン';
		comp.Addnor__c = 'ベトナム';
		comp.CompanyCode__c = 'CompanyCode__c';
		comp.Emp__c = 'Emp__c';
		comp.Fax__c = '11ff';
		comp.Gyoshu__c = '1315_一般機械';
		comp.HPURLnor__c = 'lightningdesignsystem.com';
		comp.Mail__c = 'abc@gmail.com';
		comp.OrgId__c = '12345';
		comp.PageURLnor__c = 'www.electrictoolbox.com';
		comp.PageUrl__c = 'https://www.electrictoolbox.com/javascript-add-options-html-select/';
		comp.RegistedDate__c = '201704';
		comp.Score__c = 1;
		comp.Segment__c = 'クラウド';
		comp.Shogo__c = '空の境界';
		comp.Shogonor__c = '空';
		comp.Tel__c = '03-3743-6111';
		comp.Zip__c = '144-8510';
        comp.IsConverted__c = true;
        comp.IsConvertFail__c = false;

        lstTargetCompany.add(comp);

        MAP_TargetCompany__c clonedcomp = comp.clone(false, false, false, false);
        clonedcomp.IsConverted__c = false;
        clonedcomp.IsConvertFail__c = true;
        lstTargetCompany.add(comp);

		return lstTargetCompany;
	}

	private static MAP_TargetCompany__c createTargetCompanyForm(){
		MAP_TargetCompany__c comp = new MAP_TargetCompany__c();
		comp.Name = 'Company Name';
		comp.HPURL__c = 'https://www.lightningdesignsystem.com/components/data-tables/';
		comp.Add__c = 'ホーチミン';
		comp.Addnor__c = 'ベトナム';
		comp.CompanyCode__c = 'CompanyCode__c';
		comp.Emp__c = 'Emp__c';
		comp.Fax__c = '11ff';
		comp.Gyoshu__c = '1315_一般機械';
		comp.HPURLnor__c = 'lightningdesignsystem.com';
		comp.Mail__c = 'abc@gmail.com';
		comp.OrgId__c = '12345';
		comp.PageURLnor__c = 'www.electrictoolbox.com';
		comp.PageUrl__c = 'https://www.electrictoolbox.com/javascript-add-options-html-select/';
		comp.RegistedDate__c = '201704';
		comp.Score__c = 1;
		comp.Segment__c = 'クラウド';
		comp.Shogo__c = '空の境界';
		comp.Shogonor__c = '空';
		comp.Tel__c = '03-3743-6111';
		comp.Zip__c = '144-8510';

		return comp;
	}

    private static void changeSettingAPINoData() {
        MAP_ConnectionSetting__c setting = [Select AuthenticationID__c,Endpoint__c,IsUseCompanyInfo__c
                                    FROM MAP_ConnectionSetting__c 
                                    LIMIT 1];

		setting.IsUseCompanyInfo__c = false;
		update setting;
    }

    private static void changeSettingAPIData() {
        MAP_ConnectionSetting__c setting = [Select AuthenticationID__c,Endpoint__c,IsUseCompanyInfo__c
                                    FROM MAP_ConnectionSetting__c 
                                    LIMIT 1];

		setting.IsUseCompanyInfo__c = false;
		update setting;
    }


	private static void settingMapping(){
        // Delete lst mapping
    	List<MAP_ItemMapping__c>      lstMapping    = [SELECT Account_ITA__c, Lead_ITA__c
                                                                 FROM MAP_ItemMapping__c
                                                                LIMIT 1];
        delete lstMapping;

        // Insert mapping basic
        MAP_ItemMapping__c mappingItem = new MAP_ItemMapping__c();
        mappingItem.put('Account_ITA__c', '{"Name":"' + MAP_AppContants.APP_PREFIX + 'Shogo__c"}');
        mappingItem.put('Lead_ITA__c', '{"LastName":"' + MAP_AppContants.APP_PREFIX + 'Shogo__c","Company":"' + MAP_AppContants.APP_PREFIX + 'Add__c"}');
        
        insert mappingItem;
	}

	private static void settingMappingConvertFailAccount(){
        // Delete lst mapping
    	List<MAP_ItemMapping__c>      lstMapping    = [SELECT Account_ITA__c, Lead_ITA__c
                                                                 FROM MAP_ItemMapping__c
                                                                LIMIT 1];
        delete lstMapping;

        // Insert mapping basic
        MAP_ItemMapping__c mappingItem = new MAP_ItemMapping__c();
        mappingItem.put('Account_ITA__c', '{"Name":"' + MAP_AppContants.APP_PREFIX + 'Shogo__c"}');
        mappingItem.put('Lead_ITA__c', '{"LastName":"' + MAP_AppContants.APP_PREFIX + 'Shogo__c","Company":"' + MAP_AppContants.APP_PREFIX + 'Add__c"}');
        
        insert mappingItem;
	}

	private static void settingMappingConvertFailLead(){
        // Delete lst mapping
    	List<MAP_ItemMapping__c>      lstMapping    = [SELECT Account_ITA__c, Lead_ITA__c
                                                                 FROM MAP_ItemMapping__c
                                                                LIMIT 1];
        delete lstMapping;

        // Insert mapping basic
        MAP_ItemMapping__c mappingItem = new MAP_ItemMapping__c();
        mappingItem.put('Account_ITA__c', '{"Name":"' + MAP_AppContants.APP_PREFIX + 'ExternalKey__c"}');
        mappingItem.put('Lead_ITA__c', '{"Company":"' + MAP_AppContants.APP_PREFIX + 'Shogo__c","LastName":"' + MAP_AppContants.APP_PREFIX + 'Name","FirstName":"' + MAP_AppContants.APP_PREFIX + 'ExternalKey__c"}');

        insert mappingItem;
	}

	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Description: FilterConditionSetting test data
    */
    private static MAP_FilterConditionSetting__c createFilterConditionSetting(){
    	MAP_FilterConditionSetting__c result = new MAP_FilterConditionSetting__c();
    	result.Child_Id__c = '';
    	result.External_Id__c = '1';
    	result.Filter_Name__c = '小売・卸売';
    	result.Filter_Type__c = 'gyoshu__c';
    	result.Filter_Value__c = 'gyoshu_facet:[0101_百貨店・スーパー TO 0116_その他小売・卸売]';
    	insert result;

    	return result;
    }	
    
	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Description: Map<String,String> test data 
    */	
	private static Map<string,string> createTargetCompanyMap(){
		Map<string,string> result = new Map<string,string>();
		MAP_TargetCompany__c comp = createTargetCompany();

		result.put('Id', comp.Id);
		result.put('Name', comp.Name);
		result.put('HPURL__c', comp.HPURL__c);
		result.put('Add__c', comp.Add__c);
		result.put('Addnor__c', comp.Addnor__c);
		result.put('CompanyCode__c', comp.CompanyCode__c);
		result.put('Emp__c', comp.Emp__c);
		result.put('Fax__c', comp.Fax__c);
		result.put('Gyoshu__c', comp.Gyoshu__c);
		result.put('HPURLnor__c', comp.HPURLnor__c);
		result.put('Mail__c', comp.Mail__c);
		result.put('OrgId__c', comp.OrgId__c);
		result.put('PageURLnor__c', comp.PageURLnor__c);
		result.put('PageUrl__c', comp.PageUrl__c);
		result.put('RegistedDate__c', comp.RegistedDate__c);
		result.put('Score__c', String.valueOf(comp.Score__c));
		result.put('Segment__c', comp.Segment__c);
		result.put('Shogo__c', comp.Shogo__c);
		result.put('Shogonor__c', comp.Shogonor__c);
		result.put('Tel__c', comp.Tel__c);
		result.put('Zip__c', comp.Zip__c);
		return result;
	}

	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Test Function: getTargetCompanyById
    */	
	@isTest
	public static void getTargetCompanyByIdTest(){
		MAP_TargetCompany__c comp = createTargetCompany();
		MAP_TargetCompany__c selectCompany = MAP_CompanyUploadCsv.getTargetCompanyById(comp.ID);

		System.assertEquals(comp.Name, selectCompany.Name);
		System.assertEquals(comp.HPURL__c, selectCompany.HPURL__c);
		System.assertEquals(comp.Add__c, selectCompany.Add__c);
		System.assertEquals(comp.Addnor__c, selectCompany.Addnor__c);
		System.assertEquals(comp.CompanyCode__c, selectCompany.CompanyCode__c);
		System.assertEquals(comp.Emp__c, selectCompany.Emp__c);
		System.assertEquals(comp.Fax__c, selectCompany.Fax__c);
		System.assertEquals(comp.Gyoshu__c, selectCompany.Gyoshu__c);
		System.assertEquals(comp.HPURLnor__c, selectCompany.HPURLnor__c);
		System.assertEquals(comp.PageUrl__c, selectCompany.PageUrl__c);
		System.assertEquals(comp.RegistedDate__c, selectCompany.RegistedDate__c);
		System.assertEquals(comp.Score__c, selectCompany.Score__c);
		System.assertEquals(comp.Segment__c, selectCompany.Segment__c);
		System.assertEquals(comp.Shogo__c, selectCompany.Shogo__c);
		System.assertEquals(comp.Shogonor__c, selectCompany.Shogonor__c);
		System.assertEquals(comp.Tel__c, selectCompany.Tel__c);
		System.assertEquals(comp.Zip__c, selectCompany.Zip__c);
	}

	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Test Function: saveTargetCompany
    Test Key: Valid data
    */
	@isTest 
	public static void saveTargetCompanyTest1(){
		Map<String, String> companyMap = createTargetCompanyMap();

		// Valid data
	  	MAP_JsonResult successResult = MAP_CompanyUploadCsv.saveTargetCompany(companyMap);
	  	System.assertEquals(successResult.success, true);
	}

	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Test Function: saveTargetCompany
    Test Key: Invalid data
    */
	@isTest 
	public static void saveTargetCompanyTest2(){
		Map<String, String> companyMap = createTargetCompanyMap();
	  	companyMap.put('Score__c', 'abc');

	  	MAP_JsonResult failResult = MAP_CompanyUploadCsv.saveTargetCompany(companyMap);
	  	System.assertEquals(failResult.success, false);
	}

	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Test Function: deleteTargetCompany
    Test Key: Target company is not exist
    */
	@isTest 
	public static void deleteTargetCompanyTest1(){
		MAP_JsonResult resultNotExist= MAP_CompanyUploadCsv.deleteTargetCompany('QWERTYUOHMYGODNESS');
		System.assertEquals(resultNotExist.errorMessage, 'ターゲット企業が存在していません。');
	}

	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Test Function: deleteTargetCompany
    Test Key: Delete successfully
    */
	@isTest 
	public static void deleteTargetCompanyTest2(){
        MAP_TargetCompany__c comp = createTargetCompany();
        string msg = '「' + comp.Name + '」ターゲット企業の削除に成功しました。';
		MAP_JsonResult resultSucc = MAP_CompanyUploadCsv.deleteTargetCompany(comp.Id);
		System.assertEquals(resultSucc.errorMessage, msg);
	}

	@isTest 
	public static void getScoreHistoryTest(){
		MAP_TargetCompany__c comp = createTargetCompany();
		String result = MAP_CompanyUploadCsv.getScoreHistory(comp.Id);

		System.assertEquals(result.split(':').get(1), String.valueOf(comp.Score__c));

	}

	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Test Function: replaceNullWithEmpty
    Test Key: Normal text
    */
	@isTest static void replaceNullWithEmptyTest1(){
		string testString = 'Test String';
		string normalString = MAP_CompanyUploadCsv.replaceNullWithEmpty(testString);
		System.assertEquals(normalString, testString);
	}

	/*
    Created Date: 18/09/17
    Create By: Minh Tuan
    Test Function: replaceNullWithEmpty
    Test Key: Null
    */
	@isTest static void replaceNullWithEmptyTest2(){
		string emptyString = '';
		string nullString = MAP_CompanyUploadCsv.replaceNullWithEmpty(null);
		System.assertEquals(nullString, emptyString);
	}

	@isTest static void getFilterConditionSettingsTest(){
		MAP_FilterConditionSetting__c con = createFilterConditionSetting();
		String result = MAP_CompanyUploadCsv.getFilterConditionSettings();
		System.debug(result);
		System.assertEquals(result.split(':').get(2), con.Filter_Name__c);
	}

	private static void createDataGetTargetCompany(){
		// Update data in MAP_FieldOption__c;
		String arrStringShow = '{"' + MAP_AppContants.APP_PREFIX + 'Segment__c":"セグメント","' + MAP_AppContants.APP_PREFIX + 'CompanyCode__c":"法人ID","' + MAP_AppContants.APP_PREFIX + 'Score__c":"スコア","' + MAP_AppContants.APP_PREFIX + 'MAPlusTfI__Zip__c":"郵便番号"}';
		MAP_FieldOption__c fieldOption = [SELECT FieldsOfType__c FROM MAP_FieldOption__c WHERE Type__c = :MAP_AppContants.DISPLAY_FIELD LIMIT 1];
		fieldOption.FieldsOfType__c = arrStringShow;
		update fieldOption;
	}

	@isTest
	public static void getTargetCompanyTest1() {
		createDataGetTargetCompany();
        List<MAP_TargetCompany__c> lstTargetCompanyCreate = createLstTargetCompany();
        insert lstTargetCompanyCreate;

        Map<String, String> rawConditions = new Map<String, String>();
        rawConditions.put('gyoshu__c', 'gyoshu_facet:1315_一般機械');
        String result = MAP_CompanyUploadCsv.getTargetCompany(0, 10, 0, rawConditions);
        DataWrapper resultParse = (DataWrapper)JSON.deserialize(result, DataWrapper.class);

        System.assertEquals(resultParse.records.size(),2);

	}

	@isTest
	public static void getTargetCompanyTest2() {
		createDataGetTargetCompany();
        List<MAP_TargetCompany__c> lstTargetCompanyCreate = createLstTargetCompany();
        insert lstTargetCompanyCreate;

        Map<String, String> rawConditions = new Map<String, String>();
        rawConditions.put('gyoshu__c', 'gyoshu_facet:1315_一般機械');
        String result = MAP_CompanyUploadCsv.getTargetCompany(0, 10, -1, rawConditions);
        DataWrapper resultParse = (DataWrapper)JSON.deserialize(result, DataWrapper.class);

        System.assertEquals(resultParse.records.size(),2);

	}

    // TODO: INCASE Fields in FieldsOfType__c not right.
	@isTest
	public static void getTargetCompanyTest3() {

    }

    // List mapping did not set
    @isTest
    public static void convertCompanyTargetTest1(){

    	// Delete lst mapping
    	List<MAP_ItemMapping__c>      lstMapping    = [SELECT Account_ITA__c, Lead_ITA__c
                                                                 FROM MAP_ItemMapping__c
                                                                LIMIT 1];
        delete lstMapping;

        // Create Parameter
        List<MAP_TargetCompany__c> lstTargetCmp = createLstTargetCompany();
        insert lstTargetCmp;


        List<String> lstCompanyTargetId = new List<String>();

        for(MAP_TargetCompany__c cpm : lstTargetCmp) {
        	lstCompanyTargetId.add(cpm.Id);
        }

        MAP_JsonResult   jsonResult = MAP_CompanyUploadCsv.convertCompanyTarget(lstCompanyTargetId);
        System.assertEquals(jsonResult.success,false);
    }

    
    // If list company target isn't exist.
    @isTest
    public static void convertCompanyTargetTest2(){
        // Create Parameter by random.
        List<String> lstCompanyTargetId = new List<String>();

        lstCompanyTargetId.add('aaaaaaaaaaaaaaaaaa');
        lstCompanyTargetId.add('aaaaaaaaaaaaaaaaab');
        lstCompanyTargetId.add('aaaaaaaaaaaaaaaaac');

        MAP_JsonResult   jsonResult = MAP_CompanyUploadCsv.convertCompanyTarget(lstCompanyTargetId);
        System.assertEquals(jsonResult.success,false);
    }

    // Case single item select to convert
    @isTest
    public static void convertCompanyTargetTest3(){
        
        // Setting mapping item convert
        settingMapping();

        // Insert target company
    	MAP_TargetCompany__c singleCompany = createTargetCompanyForm();
    	singleCompany.CompanyCode__c = 'New_company_code';
    	insert singleCompany;

        // Create Parameter by random.
        List<String> lstCompanyTargetId = new List<String>();
        lstCompanyTargetId.add(singleCompany.Id);

        MAP_JsonResult   jsonResult = MAP_CompanyUploadCsv.convertCompanyTarget(lstCompanyTargetId);
        System.assertEquals(jsonResult.success,true);
    }

    // All record did not convert.
    @isTest
    public static void convertCompanyTargetTest4(){
        // Setting mapping item convert
        settingMapping();

    	List<MAP_TargetCompany__c> lstCompany = createLstTargetCompany();
    	lstCompany.get(0).CompanyCode__c = 'New_company_code_1';
    	lstCompany.get(1).CompanyCode__c = 'New_company_code_2';
    	insert lstCompany;

        // Create Parameter by random.
        List<String> lstCompanyTargetId = new List<String>();
        lstCompanyTargetId.add(lstCompany.get(0).Id);
        lstCompanyTargetId.add(lstCompany.get(1).Id);

        MAP_JsonResult   jsonResult = MAP_CompanyUploadCsv.convertCompanyTarget(lstCompanyTargetId);
        System.assertEquals(jsonResult.success,true);
    }

    // 1 record converted.
    @isTest
    public static void convertCompanyTargetTest5(){
    	// Setting mapping item convert
        settingMapping();

        // Insert target company
    	MAP_TargetCompany__c singleCompany = [SELECT Id FROM MAP_TargetCompany__c
    	                                      WHERE CompanyCode__c = 'New_company_code'];

        // Create Parameter by a company code that inserted before.
        List<String> lstCompanyTargetId = new List<String>();
        lstCompanyTargetId.add(singleCompany.Id);

        MAP_JsonResult   jsonResult = MAP_CompanyUploadCsv.convertCompanyTarget(lstCompanyTargetId);
        System.assertEquals(jsonResult.success,false);
    }

    // 1 record converted Account fail.
    @isTest
    public static void convertCompanyTargetTest6(){
    	// Setting mapping item convert
        settingMappingConvertFailAccount();

        // Insert target company with new Company Code
    	MAP_TargetCompany__c singleCompany = createTargetCompanyForm();
    	singleCompany.CompanyCode__c = 'company_code_test_6';
    	insert singleCompany;

        // Create Parameter by a company code that inserted before.
        List<String> lstCompanyTargetId = new List<String>();
        lstCompanyTargetId.add(singleCompany.Id);

        MAP_JsonResult   jsonResult = MAP_CompanyUploadCsv.convertCompanyTarget(lstCompanyTargetId);
        System.assertEquals(jsonResult.success,false);
    }

    // 1 record converted Lead fail.
    @isTest
    public static void convertCompanyTargetTest7(){
    	// Setting mapping item convert
        settingMappingConvertFailLead();

        // Insert target company with new Company Code
    	MAP_TargetCompany__c singleCompany = createTargetCompanyForm();
    	singleCompany.CompanyCode__c = 'company_code_test_7';
    	insert singleCompany;

        // Create Parameter by a company code that inserted before.
        List<String> lstCompanyTargetId = new List<String>();
        lstCompanyTargetId.add(singleCompany.Id);

        MAP_JsonResult   jsonResult = MAP_CompanyUploadCsv.convertCompanyTarget(lstCompanyTargetId);
        System.assertEquals(jsonResult.success,false);
    }

    // 2 record converted Lead fail
    @isTest
    public static void convertCompanyTargetTest8(){
    	// Setting mapping item convert
        settingMappingConvertFailLead();

        // Insert list target company with new Company Code
    	List<MAP_TargetCompany__c> lstCompany = createLstTargetCompany();
    	lstCompany.get(0).CompanyCode__c = 'Company_code_7_1';
    	lstCompany.get(1).CompanyCode__c = 'Company_code_7_2';
    	insert lstCompany;

        // Create Parameter by a company code that inserted before.
        List<String> lstCompanyTargetId = new List<String>();
        lstCompanyTargetId.add(lstCompany.get(0).Id);
        lstCompanyTargetId.add(lstCompany.get(1).Id);

        MAP_JsonResult   jsonResult = MAP_CompanyUploadCsv.convertCompanyTarget(lstCompanyTargetId);
        System.assertEquals(jsonResult.success,false);
    }

    // Data input without using API data.
    @isTest
    public static void saveDataTest1(){
    	changeSettingAPINoData();
    	String dataTest = '"[{"SEGMENT":"クラウド","REPORT_DATE":"201702","CNAME":"クリナップ（株）","ABM_SCORE":"1","M_ID":"6011501006231"},'
                          + '{"SEGMENT":"クラウド","REPORT_DATE":"201703","CNAME":"（株）日立国際電気","ABM_SCORE":"2","M_ID":"2010001098064"},'
                          + '{"SEGMENT":"クラウド","REPORT_DATE":"201704","CNAME":"キユーピー（株）","ABM_SCORE":"3","M_ID":"6011001006277"}]"';
        MAP_JsonResult result = MAP_CompanyUploadCsv.saveData(dataTest);
        System.assertEquals(result.success,true);
    }

    // Data input with using API data.
    @isTest
    public static void saveDataTest2(){
    	changeSettingAPIData();
    	String dataTest = '"[{"SEGMENT":"クラウド","REPORT_DATE":"201702","CNAME":"（株）荏原製作所","ABM_SCORE":"12","M_ID":"1010801001748"},'    	
                          + '{"SEGMENT":"クラウド","REPORT_DATE":"201704","CNAME":"コセキ（株）","ABM_SCORE":"24","M_ID":"6370001008033"},'
                          + '{"SEGMENT":"クラウド","REPORT_DATE":"201706","CNAME":"（株）日立国際電気","ABM_SCORE":"2","M_ID":"2010001098064"}]"';
        MAP_JsonResult result = MAP_CompanyUploadCsv.saveData(dataTest);
        System.assertEquals(result.success,true);
    }

    public class DataWrapper {
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Map<String,String>> records {get;set;}
        @AuraEnabled public Map<String, Object> showFields {get;set;}
    }
}