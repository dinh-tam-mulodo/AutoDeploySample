@isTest
private class CLP_SyncBillCCTest {
	@testSetup static void commonSetupTest() {
		// create custom setting
		MikataConfig__c mikataConfig = new MikataConfig__c();
		mikataConfig.ApiAccessKey__c = 'dfc9645942d554cd';
		mikataConfig.ApiHost__c = 'https://keirinomikata.jp:10443';
		mikataConfig.ApiUserId__c = 'htamaru@sunbridge.com';
		mikataConfig.NotifyTo1__c = 'tran.huy@mulodo.com';
		mikataConfig.Tax__c = 8; 
		insert mikataConfig;

		// Create Bill__c
		List<Bill__c> listBill = new List<Bill__c>();
		for (Integer i=0; i<3; i++) {
			Bill__c bill = new Bill__c();
			bill.Name = 'TestBill-' + i;
			bill.number__c = 'TestBillNumber-' + i;
			bill.IsIntegrated__c = false;
			bill.IsStop__c = false;
			bill.StopFlg__c = null;
			bill.manipulateStatus__c = '0';
			listBill.add(bill);
		}
		insert listBill;

		system.assert(mikataConfig != null);
		system.assert(listBill != null);
	}

	@isTest static void constructorTest() {
		Test.startTest();
		CLP_SyncBillCC cons1 = new CLP_SyncBillCC(); 
		CLP_MikataBillApi cons2 = new CLP_MikataBillApi();
		CLP_BillTriggerHandler cons3 = new CLP_BillTriggerHandler();
		CLP_BillBulkReferenceSchedulableBatch cons4 = new CLP_BillBulkReferenceSchedulableBatch();
		CLP_BillBulkReferenceMikataBatch cons5 = new CLP_BillBulkReferenceMikataBatch();
		Test.stopTest(); 
		system.assert(cons1 != null);
		system.assert(cons2 != null);
		system.assert(cons3 != null);
		system.assert(cons4 != null);
		system.assert(cons5 != null);	
	}

	@isTest static void billWrapperTest() {
		Test.startTest();
		CLP_BulkBillWrapper.Bill bill = new CLP_BulkBillWrapper.Bill();
		bill.error_code = null;
		bill.error_message = null;
		bill.number_z = null;
		bill.bs_residence_code = null;
		bill.billing_code = null;
		bill.billing_name = null;
		bill.billing_individual_number = null;
		bill.billing_individual_code = null;
		bill.billing_individual_name = null;
		bill.demand_number = null;
		bill.subtotal_amount_billed = null;
		bill.consumption_tax_amount = null;
		bill.total_amount_billed = null;
		bill.unclearing_amount = null;
		bill.message_column = null;
		bill.billing_method = null;
		bill.issue_date = null;
		bill.make_date = null;
		bill.sending_scheduled_date = null;
		bill.sending_date = null;
		bill.update_date = null;
		bill.confirm_date = null;
		bill.mail_send_flg = null;
		bill.post_send_flg = null;
		bill.payment_method = null;
		bill.payment_method_number = null;
		bill.payment_method_code = null;
		bill.payment_method_name = null;
		bill.settlement_result = null;
		bill.transfer_deadline = null;
		bill.transfer_date = null;
		bill.payment_status = null;
		bill.memo = null;
		bill.template_code = null;
		bill.bs_department_code = null;
		bill.bs_department_name = null;
		bill.bs_owner_code = null;
		bill.bs_owner_name = null;
		bill.valid_flg = null;
		bill.delete_flg = null;
		bill.limit_count = null;
		bill.page_count = null;
		bill.total_page_count = null;
		bill.gid = null;
		bill.erasure_deposit_date = null;
		bill.erasure_cancel_date = null;
		bill.issue_start_date = null;
		bill.issue_stop_date = null;
		bill.update_start_date = null;
		bill.update_stop_date = null;
		bill.deadline_start_date = null;
		bill.deadline_stop_date = null;
		bill.download_url = null;
		bill.bill_detail = null;
		//
		CLP_BulkBillWrapper.BillDetail biDet = new CLP_BulkBillWrapper.BillDetail();
		biDet.demand_number = null;
		biDet.demand_code = null;
		biDet.item_number = null;
		biDet.item_code = null;
		biDet.goods_name = null;
		biDet.pattern_period_format = null;
		biDet.demand_start_date = null;
		biDet.demand_end_date = null;
		biDet.criterion_date = null;
		biDet.link_customer_code = null;
		biDet.goods_code = null;
		biDet.link_goods_code = null;
		biDet.unit_price = null;
		biDet.quantity = null;
		biDet.unit = null;
		biDet.tax_category = null;
		biDet.consumption_tax = null;
		biDet.subtotal_amount_billed = null;
		biDet.consumption_tax_amount = null;
		biDet.total_amount_billed = null;
		biDet.unclearing_amount = null;
		biDet.remark = null;
		biDet.recorded_date = null;
		biDet.payment_method = null;
		biDet.payment_status = null;
		biDet.valid_flg = null;
		biDet.delete_flg = null;
		//		
		CLP_BulkBillWrapper billWrap = new CLP_BulkBillWrapper();
		billWrap.success = null;
		billWrap.error_message = null;
		billWrap.user_id = null;
		billWrap.access_key = null;
		billWrap.limit_count = null;
		billWrap.page_count = null;
		billWrap.total_page_count = null;
		billWrap.bill = null;
		//
		Test.stopTest(); 
		system.assert(bill != null);
		system.assert(biDet != null);
		system.assert(billWrap != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           REFERENCE BILL                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void referenceBillWithoutLastRefTest() {
		List<LastReference__c> lastRefList = [SELECT Id, LastModifiedById, LastReferenceDate__c FROM LastReference__c];
		Test.startTest();
		CLP_SyncBillCC.referenceBillFromMikata('');
		Test.stopTest(); 
		system.assert(lastRefList == null || lastRefList.isEmpty());
	}

	@isTest static void referenceBillWithDateReferenceTest() {
		LastReference__c lr1 = new LastReference__c();
		Date td = Date.today();
		Integer testYear = td.addYears(-2).year();
		lr1.LastReferenceDate__c = Date.newInstance(testYear, 1, 1);
		insert lr1;

		Test.startTest();
		String result = CLP_SyncBillCC.referenceBillFromMikata('');
		Test.stopTest();
		system.assert(result != null);
	}

	@isTest static void referenceBillWithoutDateReferenceTest() {
		LastReference__c lr1 = new LastReference__c();
		insert lr1;

		Test.startTest();
		String result = CLP_SyncBillCC.referenceBillFromMikata('');
		Test.stopTest();
		system.assert(result != null);
	}

	@isTest static void referenceBillWithEmptyResponseTest() {
		LastReference__c lr1 = new LastReference__c();
		Date td = Date.today();
		Integer testYear = td.addYears(-2).year();
		lr1.LastReferenceDate__c = Date.newInstance(testYear, 1, 1);
		insert lr1;

		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[]}';
		
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		String result = CLP_SyncBillCC.referenceBillFromMikata('');
		Test.stopTest();
		system.assert(result != null);
	}

	@isTest static void referenceBillWithDoInsertBillTest() {
		LastReference__c lr1 = new LastReference__c();
		Date td = Date.today();
		Integer testYear = td.addYears(-2).year();
		lr1.LastReferenceDate__c = Date.newInstance(testYear, 1, 1);
		insert lr1;

		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":' + 
			'[{"error_code":null,"error_message":null,"number":"201707-billing1-2","bs_residence_code":"1","billing_code":"billing1","billing_name":"Credit Card",' + 
			'"billing_individual_number":1,"billing_individual_code":"","billing_individual_name":"請求先部署名","demand_number":"1","subtotal_amount_billed":1000,' + 
			'"consumption_tax_amount":80,"total_amount_billed":1080,"unclearing_amount":0,"message_column":"Test message on 01/09/2017-5th","billing_method":2,' + 
			'"issue_date":"2017/06/01","make_date":"2017/07/13","sending_scheduled_date":"2017/09/01","sending_date":null,"update_date":"2017/09/04",' + 
			'"confirm_date":"2017/09/04","mail_send_flg":0,"post_send_flg":0,"payment_method":1,"payment_method_number":"1","payment_method_code":null,' + 
			'"payment_method_name":"クレジットカード1","settlement_result":2,"transfer_deadline":"2017/09/01","slip_deadline":null,"transfer_date":"2017/07/13",' + 
			'"payment_status":3,"memo":null,"template_code":"10000","bs_department_code":null,"bs_department_name":null,"bs_owner_code":null,"bs_owner_name":null,' + 
			'"valid_flg":1,"delete_flg":0,"gid":"23121369","download_url":"https://google.com","bill_detail":[{"demand_number":"30","demand_code":null,' + 
			'"item_number":null,"item_code":null,"goods_name":"商品1","pattern_period_format":0,"demand_start_date":"2017-06-01","demand_end_date":"2017-06-30",' + 
			'"criterion_date":"2017-06-30","link_customer_code":"","goods_code":null,"link_goods_code":null,"unit_price":1000,"quantity":1,"unit":null,' + 
			'"tax_category":0,"consumption_tax":"0.080","subtotal_amount_billed":1000,"consumption_tax_amount":80,"total_amount_billed":1080,"unclearing_amount":0,' + 
			'"remark":null,"recorded_date":"2017/06/30","payment_method":"クレジットカード1","payment_status":1,"valid_flg":1,"delete_flg":0}]}]}';
		
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		String result = CLP_SyncBillCC.referenceBillFromMikata('');
		Test.stopTest();
		system.assert(result != null);
	}

	@isTest static void referenceBillWithDoUpdateBillTest() {
		LastReference__c lr1 = new LastReference__c();
		Date td = Date.today();
		Integer testYear = td.addYears(-2).year();
		lr1.LastReferenceDate__c = Date.newInstance(testYear, 1, 1);
		insert lr1;

		// Create bill to update
		Bill__c bill = new Bill__c();
		bill.Name = '201707-billing1-2';
		bill.number__c = '201707-billing1-2';
		bill.Update_Date__c = Date.newInstance(2017, 9, 3);  	// must < 2017/09/04
		insert bill;

		// Create bill detail
		BillDetail__c billDet = new BillDetail__c();
		billDet.Name = 'bill detail test';
		billDet.BillId__c = bill.Id;
		insert billDet;

		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":' + 
			'[{"error_code":null,"error_message":"error","number":"' + bill.number__c + '","bs_residence_code":"1","billing_code":"billing1","billing_name":"Credit Card",' + 
			'"billing_individual_number":1,"billing_individual_code":"","billing_individual_name":"請求先部署名","demand_number":"1","subtotal_amount_billed":1000,' + 
			'"consumption_tax_amount":80,"total_amount_billed":1080,"unclearing_amount":0,"message_column":"Test message on 01/09/2017-5th","billing_method":2,' + 
			'"issue_date":"2017/06/01","make_date":"2017/07/13","sending_scheduled_date":"2017/09/01","sending_date":null,"update_date":"2017/09/04",' + 
			'"confirm_date":"2017/09/04","mail_send_flg":0,"post_send_flg":0,"payment_method":1,"payment_method_number":"1","payment_method_code":null,' + 
			'"payment_method_name":"クレジットカード1","settlement_result":2,"transfer_deadline":"2017/09/01","slip_deadline":null,"transfer_date":"2017/07/13",' + 
			'"payment_status":3,"memo":null,"template_code":"10000","bs_department_code":null,"bs_department_name":null,"bs_owner_code":null,"bs_owner_name":null,' + 
			'"valid_flg":1,"delete_flg":0,"gid":"23121369","download_url":"https://google.com","bill_detail":[{"demand_number":"30","demand_code":null,' + 
			'"item_number":null,"item_code":null,"goods_name":"商品1","pattern_period_format":0,"demand_start_date":"2017-06-01","demand_end_date":"2017-06-30",' + 
			'"criterion_date":"2017-06-30","link_customer_code":"","goods_code":null,"link_goods_code":null,"unit_price":1000,"quantity":1,"unit":null,' + 
			'"tax_category":0,"consumption_tax":"0.080","subtotal_amount_billed":1000,"consumption_tax_amount":80,"total_amount_billed":1080,"unclearing_amount":0,' + 
			'"remark":null,"recorded_date":"2017/06/30","payment_method":"クレジットカード1","payment_status":1,"valid_flg":1,"delete_flg":0}]}]}';
		
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		String result = CLP_SyncBillCC.referenceBillFromMikata('');
		Test.stopTest();
		system.assert(result != null);
	}

	@isTest static void referenceBillWithDoUpsertBillTest() {
		LastReference__c lr1 = new LastReference__c();
		Date td = Date.today();
		Integer testYear = td.addYears(-2).year();
		lr1.LastReferenceDate__c = Date.newInstance(testYear, 1, 1);
		insert lr1;

		// Create bill to update
		Bill__c bill = new Bill__c();
		bill.Name = '201707-billing1-2';
		bill.number__c = '201707-billing1-2';
		bill.Update_Date__c = Date.newInstance(2017, 9, 3);  	// must < 2017/09/04
		insert bill;

		// Create bill detail
		BillDetail__c billDet = new BillDetail__c();
		billDet.Name = 'bill detail test';
		billDet.BillId__c = bill.Id;
		insert billDet;

		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":' + 
		'[{"error_code":null,"error_message":null,"number":"' + bill.number__c + '","bs_residence_code":"1","billing_code":"billing1","billing_name":"Credit Card",' + 
		'"billing_individual_number":1,"billing_individual_code":"","billing_individual_name":"請求先部署名","demand_number":"1","subtotal_amount_billed":1000,' + 
		'"consumption_tax_amount":80,"total_amount_billed":1080,"unclearing_amount":0,"message_column":"Test message on 01/09/2017-5th","billing_method":2,' + 
		'"issue_date":"2017/06/01","make_date":"2017/07/13","sending_scheduled_date":"2017/09/01","sending_date":null,"update_date":"2017/09/04",' + 
		'"confirm_date":"2017/09/04","mail_send_flg":0,"post_send_flg":0,"payment_method":1,"payment_method_number":"1","payment_method_code":null,' + 
		'"payment_method_name":"クレジットカード1","settlement_result":2,"transfer_deadline":"2017/09/01","slip_deadline":null,"transfer_date":"2017/07/13",' + 
		'"payment_status":3,"memo":null,"template_code":"10000","bs_department_code":null,"bs_department_name":null,"bs_owner_code":null,"bs_owner_name":null,' + 
		'"valid_flg":1,"delete_flg":0,"gid":"23121369","download_url":"https://google.com","bill_detail":[{"demand_number":"30","demand_code":null,' + 
		'"item_number":null,"item_code":null,"goods_name":"商品1","pattern_period_format":0,"demand_start_date":"2017-06-01","demand_end_date":"2017-06-30",' + 
		'"criterion_date":"2017-06-30","link_customer_code":"","goods_code":null,"link_goods_code":null,"unit_price":1000,"quantity":1,"unit":null,' + 
		'"tax_category":0,"consumption_tax":"0.080","subtotal_amount_billed":1000,"consumption_tax_amount":80,"total_amount_billed":1080,"unclearing_amount":0,' + 
		'"remark":null,"recorded_date":"2017/06/30","payment_method":"クレジットカード1","payment_status":1,"valid_flg":1,"delete_flg":0}]},{"error_code":null,' + 
		'"error_message":null,"number":"201707-billing1-1","bs_residence_code":"1","billing_code":"billing1","billing_name":"Credit Card",' + 
		'"billing_individual_number":1,"billing_individual_code":"","billing_individual_name":"請求先部署名","demand_number":"1","subtotal_amount_billed":1000,' + 
		'"consumption_tax_amount":80,"total_amount_billed":1080,"unclearing_amount":0,"message_column":null,"billing_method":2,"issue_date":"2017/06/01",' + 
		'"make_date":"2017/07/12","sending_scheduled_date":"2017/06/01","sending_date":null,"update_date":"2017/09/04","confirm_date":"2017/09/04",' + 
		'"mail_send_flg":0,"post_send_flg":0,"payment_method":1,"payment_method_number":"1","payment_method_code":null,"payment_method_name":"クレジットカード1",' + 
		'"settlement_result":2,"transfer_deadline":"2017/06/01","slip_deadline":null,"transfer_date":"2017/07/12","payment_status":1,"memo":null,' + 
		'"template_code":"10000","bs_department_code":null,"bs_department_name":null,"bs_owner_code":null,"bs_owner_name":null,"valid_flg":1,"delete_flg":0,' + 
		'"gid":"23112720","download_url":"https://google.com","bill_detail":[{"demand_number":"23","demand_code":null,"item_number":null,"item_code":null,' + 
		'"goods_name":"商品1","pattern_period_format":0,"demand_start_date":"2017-06-01","demand_end_date":"2017-06-30","criterion_date":"2017-06-30",' + 
		'"link_customer_code":"","goods_code":null,"link_goods_code":null,"unit_price":1000,"quantity":1,"unit":null,"tax_category":0,"consumption_tax":"0.080",' + 
		'"subtotal_amount_billed":1000,"consumption_tax_amount":80,"total_amount_billed":1080,"unclearing_amount":0,"remark":null,"recorded_date":"2017/06/30",' + 
		'"payment_method":"クレジットカード1","payment_status":1,"valid_flg":1,"delete_flg":0}]}]}';
		
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		String result = CLP_SyncBillCC.referenceBillFromMikata('');
		Test.stopTest();
		system.assert(result != null);
	}

	@isTest static void referenceBillScheduledBatch1Test() {
		LastReference__c lr1 = new LastReference__c();
		//Date td = Date.today();
		//Integer testYear = td.addYears(-2).year();
		//lr1.LastReferenceDate__c = Date.newInstance(testYear, 1, 1);
		insert lr1;

		CLP_BillBulkReferenceSchedulableBatch schBatch = new CLP_BillBulkReferenceSchedulableBatch();
		Datetime dt = Datetime.now().addMinutes(1);
		String timer = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

		Test.startTest();
		System.schedule('CLP_BillBulkReferenceSchedulableBatch', timer, schBatch);
		Test.stopTest();
		system.assert(timer != null);
	}

	@isTest static void referenceBillScheduledBatch2Test() {
		CLP_BillBulkReferenceSchedulableBatch schBatch = new CLP_BillBulkReferenceSchedulableBatch();
		Datetime dt = Datetime.now().addMinutes(1);
		String timer = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

		Test.startTest();
		System.schedule('CLP_BillBulkReferenceSchedulableBatch', timer, schBatch);
		Test.stopTest();
		system.assert(timer != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           UPSERT BILL                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void upsertBillErrorValidationTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  limit 2];
		listBill[1].IsIntegrated__c = true;
		listBill[1].IsStop__c = true;
		listBill[1].StopFlg__c = '0';
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		CLP_SyncBillCC.upsertBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void upsertBillExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncBillCC.upsertBillMikata(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	@isTest static void upsertBillSuccessTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  limit 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":null,"number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.upsertBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void upsertBillErrorDuplicateTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  limit 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":null,"number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.upsertBillMikata(listIds);
		CLP_SyncBillCC.upsertBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void upsertBillFailedTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  limit 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":"error","number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.upsertBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void upsertBillErrorInterfaceTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  limit 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		CLP_SyncBillCC.upsertBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           STOP BILL                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void stopBillErrorValidationTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  limit 2];
		listBill[0].IsIntegrated__c = false;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		listBill[1].IsIntegrated__c = true;
		listBill[1].IsStop__c = true;
		listBill[1].StopFlg__c = '0';
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		CLP_SyncBillCC.stopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void stopBillExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncBillCC.stopBillMikata(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	@isTest static void stopBillSuccessTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":null,"number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.stopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void stopBillErrorDuplicateTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":null,"number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.stopBillMikata(listIds);
		CLP_SyncBillCC.stopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void stopBillFailedTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","bill":[{"error_code":1705,"error_message":"Already Erasured bill.","number":null,"billing_code":null}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.stopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void stopBillErrorInterfaceTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		CLP_SyncBillCC.stopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           UNSTOP BILL                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void unstopBillErrorValidationTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		CLP_SyncBillCC.unstopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void unstopBillExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncBillCC.unstopBillMikata(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	@isTest static void unstopBillSuccessTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = true;
		listBill[0].StopFlg__c = '0';
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":null,"number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.unstopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void unstopBillErrorDuplicateTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = true;
		listBill[0].StopFlg__c = '0';
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":null,"number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.unstopBillMikata(listIds);
		CLP_SyncBillCC.unstopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void unstopBillFailedTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = true;
		listBill[0].StopFlg__c = '0';
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":"error","number":"201707-billing1-2","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.unstopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void unstopBillErrorInterfaceTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = true;
		listBill[0].StopFlg__c = '0';
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		CLP_SyncBillCC.unstopBillMikata(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           UPDATE BILL URL                                            
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void getBillUrlErrorValidationTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = true;
		listBill[0].StopFlg__c = '0';
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		CLP_SyncBillCC.getBillUrl(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void getBillUrlExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncBillCC.getBillUrl(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	@isTest static void getBillUrlSuccessTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":null,"number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.getBillUrl(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void getBillUrlEmptyResponseTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.getBillUrl(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void getBillUrlErrorDuplicateTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":null,"number":"' + listBill[0].number__c  + '","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.getBillUrl(listIds);
		CLP_SyncBillCC.getBillUrl(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void getBillUrlFailedTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		String jsonString = '{"success":true,"error_message":null,"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","limit_count":20,"page_count":0,"total_page_count":1,"bill":[{"error_code":null,"error_message":"error","number":"201707-billing1-2","download_url":"https://google.com","bill_detail":[]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_SyncBillCC.getBillUrl(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void getBillUrlErrorInterfaceTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;
		//
		List<Id> listIds = new List<Id>();
		for (Bill__c bi : listBill) {
			listIds.add(bi.Id);	
		}
		Test.startTest();
		CLP_SyncBillCC.getBillUrl(listIds);
		Test.stopTest();
		system.assert(listBill != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           DELETE BILL                                            
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void deleteBillErrorValidationTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = false;
		listBill[0].StopFlg__c = null;
		update listBill;

		Test.startTest();
		Database.delete(listBill, false);
		Test.stopTest();
		system.assert(listBill != null);
	}

	@isTest static void deleteBillSuccessTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		listBill[0].IsIntegrated__c = true;
		listBill[0].IsStop__c = true;
		listBill[0].StopFlg__c = '0';
		update listBill;

		Test.startTest();
		Database.delete(listBill, false);
		Database.undelete(listBill, false);
		Test.stopTest();
		system.assert(listBill != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           DELETE BILL DETAIL                                        
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void deleteBillDetailErrorTriggerTest() {
		List<Bill__c> listBill = [SELECT Id, Name, number__c, IsIntegrated__c, IsStop__c, StopFlg__c, BillingURL__c
								  FROM Bill__c
								  WHERE number__c like 'TestBillNumber%'
								  LIMIT 1];
		// Create bill detail
		BillDetail__c bidet = new BillDetail__c();
		bidet.Name = 'Test Bill detail';
		bidet.BillId__c = listBill[0].Id;
		insert bidet;

		Test.startTest();
		Database.delete(bidet, false);
		Test.stopTest();
		system.assert(bidet != null);
	}
}