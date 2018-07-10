/**
 * CLP_ViewSettingCCTest.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: ViewSettingPage controller unit test
 */
@IsTest
global class CLP_ViewSettingCCTest {
	@isTest global static void getViewSettingsTest(){
		CLP_JsonResult jrs = CLP_ViewSettingCC.getViewSettings();
		System.assertEquals(true, jrs.success);
	}

	@isTest global static void getViewSettingsSettingEmptyCaseTest(){
		ViewSettings__c setting = new ViewSettings__c(Display_Field__c = 'displayFieldTest', Hidden_Field__c = 'hiddenFieldTest', User__c = UserInfo.getUserId());

		insert setting;

		CLP_JsonResult jrs2 = CLP_ViewSettingCC.getViewSettings();
		System.assertEquals(true, jrs2.success);
	}

	@isTest global static void saveTest(){
		String df = 'displayField';
		String hf = 'hiddenField';
		CLP_JsonResult jrs3 = CLP_ViewSettingCC.save(df, hf);
		System.assertEquals(true, jrs3.success);
	}

	@isTest global static void saveSettingEmptyCaseTest(){
		String df = 'displayField';
		String hf = 'hiddenField';
		ViewSettings__c setting = new ViewSettings__c(Display_Field__c = 'displayFieldTest', Hidden_Field__c = 'hiddenFieldTest', User__c = UserInfo.getUserId());

		insert setting;

		CLP_JsonResult jrs4 = CLP_ViewSettingCC.save(df, hf);
		System.assertEquals(true, jrs4.success);
	}
}