@isTest
private class CLP_SyncProductCCTest {
	@testSetup static void commonSetupTest() {
		// create custom setting
		MikataConfig__c mikataConfig = new MikataConfig__c();
		mikataConfig.ApiAccessKey__c = 'dfc9645942d554cd';
		mikataConfig.ApiHost__c = 'https://keirinomikata.jp:10443';
		mikataConfig.ApiUserId__c = 'htamaru@sunbridge.com';
		mikataConfig.NotifyTo1__c = 'tran.huy@mulodo.com';
		mikataConfig.Tax__c = 8; 
		insert mikataConfig;

		// Create product data
		Product2 prd = new Product2();
		prd.Name = 'Test Prd';
		prd.Item_Code__c = 'TestPrd';
		//
		prd.DemandType__c = '';
		prd.TaxCategory__c = '';
		prd.Unit__c = '';	
		//
		prd.IsIntegrated__c = false;
		prd.IsStop__c = false;
		prd.StopFlg__c = null;
		prd.ManipulateStatus__c = '1';
		insert prd;

		system.assert(mikataConfig != null);
		system.assert(prd != null);
	}

	@isTest static void constructorTest() {
		Test.startTest();
		CLP_SyncProductCC cons1 = new CLP_SyncProductCC(); 
		CLP_MikataProductApi cons2 = new CLP_MikataProductApi();
		CLP_ProductTriggerHandler cons3 = new CLP_ProductTriggerHandler();
		Test.stopTest(); 
		system.assert(cons1 != null);
		system.assert(cons2 != null);
		system.assert(cons3 != null);
	}

	@isTest static void productWrapperTest() {
		Test.startTest();
		CLP_BulkProductWrapper.Goods cons = new CLP_BulkProductWrapper.Goods(); 
		cons.error_code = null;
		cons.error_message = null;
		cons.del_flg = null;
		cons.item_number = null;
		cons.item_code = null;
		cons.code = null;
		cons.journal_cooperation_goods_code = null;
		cons.item_name = null;
		cons.name = null;
		cons.demand_type = null;
		cons.unit_price = null;
		cons.unit = null;
		cons.tax_category = null;
		cons.tax_rate = null;
		cons.remarks_column = null;
		cons.repetition_period_number = null;
		cons.repetition_period_unit = null;
		cons.repeat_count_max = null;
		cons.period_format = null;
		cons.period_value = null;
		cons.period_unit = null;
		cons.period_criterion = null;
		cons.bill_issue_date_month = null;
		cons.bill_issue_date_day = null;
		cons.bill_sending_date_month = null;
		cons.bill_sending_date_day = null;
		cons.transfer_deadline_month = null;
		cons.transfer_deadline_day = null;
		cons.sales_recorded_date_month = null;
		cons.sales_recorded_date_day = null;
		cons.billing_method = null;
		cons.bill_template_code = null;
		cons.account_title_code = null;
		cons.account_title_id = null;
		cons.sub_account_title_code = null;
		cons.account_title_code_account_receivable_trade = null;
		cons.sub_account_title_code_account_receivable_trade = null;
		cons.account_title_code_advances_received = null;
		cons.sub_account_title_code_advances_received = null;
		Test.stopTest(); 
		system.assert(cons != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           REGISTER MIKATA PRODUCT                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void registerMikataExceptionTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.registerMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(listIds != null);
	}

	@isTest static void registerMikataErrorValidationOneTest() {
		// Missing required field
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		List<Id> listIds = new List<Id>();
		for (Product2 prd : listPrd) {
			listIds.add(prd.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.registerMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void registerMikataErrorValidationTwoTest() {
		// Already registered
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.ManipulateStatus__c = '3';
		update listPrd;
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		} 
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.registerMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void registerMikataSuccessTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":null,"item_code":"' + listPrd[0].Item_Code__c + '"}]}' ;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.registerMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void registerMikataErrorDuplicateTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":null,"item_code":"' + listPrd[0].Item_Code__c + '"}]}' ;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.registerMikata(listIds);
		CLP_SyncProductCC.registerMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void registerMikataErrorConnectionTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":"HTTP CONNECTION ERROR","item_code":"' + listPrd[0].Item_Code__c + '"}]}' ;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.registerMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void registerMikataErrorOtherTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":"error","item_code":"' + listPrd[0].Item_Code__c + '"}]}' ;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.registerMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void registerMikataErrorInterfaceTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.registerMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           STOP MIKATA PRODUCT                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void stopMikataExceptionTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.stopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(listIds != null);
	}

	@isTest static void stopMikataErrorValidationTest() {
		// Already stop
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.stopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void stopMikataSuccessTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":null,"item_code":"' + listPrd[0].Item_Code__c + '","del_flg":0}]}';
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.stopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void stopMikataErrorDuplicateTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":null,"item_code":"' + listPrd[0].Item_Code__c + '","del_flg":0}]}';
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.stopMikata(listIds);
		CLP_SyncProductCC.stopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void stopMikataErrorConnectionTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":"HTTP CONNECTION ERROR","item_code":"' + listPrd[0].Item_Code__c + '","del_flg":0}]}';
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.stopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void stopMikataErrorOtherTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":"error","item_code":"' + listPrd[0].Item_Code__c + '","del_flg":0}]}';
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.stopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void stopMikataErrorInterfaceTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.stopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           UNSTOP MIKATA PRODUCT                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void unstopMikataExceptionTest() {
		List<Id> listIds = new List<Id>();

		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.unstopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(listIds != null);
	}

	@isTest static void unstopMikataErrorValidationOneTest() {
		// Not integrated
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.unstopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void unstopMikataErrorValidationTwoTest() {
		// Not stopped
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = false;
		prd.StopFlg__c = null;
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.unstopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void unstopMikataSuccessTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":null,"item_code":"' + listPrd[0].Item_Code__c + '"}]}' ;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.unstopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void unstopMikataErrorDuplicateTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":null,"item_code":"' + listPrd[0].Item_Code__c + '"}]}' ;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.unstopMikata(listIds);
		CLP_SyncProductCC.unstopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void unstopMikataErrorConnectionTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":"HTTP CONNECTION ERROR","item_code":"' + listPrd[0].Item_Code__c + '"}]}' ;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.unstopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void unstopMikataErrorOtherTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":"error","item_code":"' + listPrd[0].Item_Code__c + '"}]}' ;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncProductCC.unstopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void unstopMikataErrorInterfaceTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		//
		List<Id> listIds = new List<Id>();
		for (Product2 p : listPrd) {
			listIds.add(p.Id);	
		}
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_SyncProductCC.unstopMikata(listIds);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           DELETE PRODUCT                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//

	@isTest static void deleteProductErrorValidationTest() {
		// not stopped
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = false;
		prd.StopFlg__c = null;
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		Database.delete(listPrd, false);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void deleteProductSuccessTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":null,"item_code":"' + listPrd[0].Item_Code__c + '","del_flg":1}]}';
		Test.setMock(HttpCalloutMock.class, mock);
		Database.delete(listPrd, false);
		Database.undelete(listPrd, false);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void deleteProductErrorDuplicateTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":null,"item_code":"' + listPrd[0].Item_Code__c + '","del_flg":1}]}';
		Test.setMock(HttpCalloutMock.class, mock);
		Database.delete(listPrd, false);
		Database.delete(listPrd, false);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void deleteProductErrorConnectionTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":"HTTP CONNECTION ERROR","item_code":"' + listPrd[0].Item_Code__c + '","del_flg":1}]}';
		Test.setMock(HttpCalloutMock.class, mock);
		Database.delete(listPrd, false);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void deleteProductErrorOtherTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","goods":[{"error_code":null,"error_message":"error","item_code":"' + listPrd[0].Item_Code__c + '","del_flg":1}]}';
		Test.setMock(HttpCalloutMock.class, mock);
		Database.delete(listPrd, false);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}

	@isTest static void deleteProductErrorInterfaceTest() {
		List<Product2> listPrd = [SELECT Name, Item_Code__c, DemandType__c, TaxCategory__c, Unit__c, IsIntegrated__c,
		                                 IsStop__c, StopFlg__c, ManipulateStatus__c
		                          FROM Product2
		                          WHERE Item_Code__c = 'TestPrd'];
		Product2 prd = listPrd.get(0);
		prd.DemandType__c = '1';
		prd.TaxCategory__c = '1';
		prd.Unit__c = '1';
		prd.IsIntegrated__c = true;
		prd.IsStop__c = true;
		prd.StopFlg__c = '0';
		prd.ManipulateStatus__c = '3';
		update listPrd; 
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		Database.delete(listPrd, false);
		// -------------------------- Test.stopTest() --------------------------
		Test.stopTest();
		system.assert(!listPrd.isEmpty());
	}
}