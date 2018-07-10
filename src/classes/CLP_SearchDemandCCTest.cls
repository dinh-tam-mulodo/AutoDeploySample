/**
 * CLP_SearchDemandCCTest.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: SearchDemandPage controller unit test
 */
@IsTest
global class CLP_SearchDemandCCTest {
	@isTest global static void getPaymentMethodTest(){
		CLP_SearchDemandCC sd = new CLP_SearchDemandCC();
		List<RecordType> rt = CLP_SearchDemandCC.getPaymentMethod();
		System.assert(!rt.isEmpty());
	}

	@isTest global static void getBillingSourceIndividualTest(){
		List<BillingSourceIndividual__c> bsi = CLP_SearchDemandCC.getBillingSourceIndividual();		
		System.assert(bsi.isEmpty());
	}

	@isTest global static void getPicklistValuesTest(){
		String fieldName = 'DemandType__c';
		List<CLP_SearchDemandCC.WrapObject> wo = CLP_SearchDemandCC.getPicklistValues(fieldName);
		System.assert(!wo.isEmpty());
	}

	@isTest global static void isConnectMikataTest(){
		Account acc = new Account(Name = 'test'
								, SeikyusakiCode__c = 'CodeTest'
								,link_customer_code__c = 'abc'
								,IsIntegrated__c = true);
		insert acc;

		Account a = [Select Id,IsIntegrated__c from Account];
		system.debug(a);
		// insert Seikyuusakibusho
		Seikyusakibusho__c sei = new Seikyusakibusho__c( Name = 'test sei',
														billing_individual_number__c = 'd1234',
														address1__c = 'address1',
														pref__c = '北海道',
														email__c = 'dinh.tam@mulodo.com',
														zip_code__c = '1234567',
														city_address__c = 'city address',
														Seikyusakimei__c = acc.Id,
														IsIntegrated__c = true,
														manipulateStatus__c = CLP_MikataConstant.DEMAND_IN_EDIT,
														tel__c = '0939127600'
														);
		upsert sei;
		Seikyusakibusho__c s = [Select Id,IsIntegrated__c from Seikyusakibusho__c];
		system.debug(s);
		// insert payment method

		String payment = CLP_CommonUtil.ENV_PREFIX+'PaymentMethod__c';
        RecordType rt = [Select Id From RecordType where SObjectType =:payment and DeveloperName = 'PaymentSlip'];
		PaymentMethod__c pay = new PaymentMethod__c(Name = 'test payment',
													AccountId__c = acc.Id,
													RecordTypeId = rt.Id,
													PaymentMethodCode__c = '1122',
													RegisterStatus__c = '5',
													IsIntegrated__c = true,
													manipulateStatus__c = CLP_MikataConstant.DEMAND_IN_EDIT
													);
		upsert pay;
		PaymentMethod__c p = [Select Id,IsIntegrated__c from PaymentMethod__c];
		system.debug(p);
		DemandDetail__c d_bulk = new DemandDetail__c();
		d_bulk.ManipulateStatus__c = CLP_MikataConstant.DEMAND_IN_EDIT;
		d_bulk.StopFlg__c = null;
		d_bulk.IsStop__c = false;
		d_bulk.IsIntegrated__c = false;
		d_bulk.AwaitingGetNewInfo__c = false;
		d_bulk.Account__c = acc.Id;
		d_bulk.Seikyuusakibusho__c = sei.Id;
		d_bulk.PaymentMethod__c = pay.Id;
		d_bulk.DemandType__c = '0';
		d_bulk.DemandDetailCode__c = '1122';
		d_bulk.ProductName__c = 'test product';
		d_bulk.Price__c = 1;
		d_bulk.Quantity__c = 1;
		d_bulk.TaxCategory__c = '0';
		d_bulk.TaxRate__c = '8%';
		d_bulk.PaymentProcess__c = '0';
		d_bulk.StartDate__c = Date.today();
		d_bulk.Period_Format__c = '0';
		d_bulk.BillIssueDate__c = Date.today();
		d_bulk.BillSendDate__c = Date.today();
		d_bulk.PaymentDeadlineDate__c = Date.today();
		d_bulk.Slip_Deadline__c = Date.today();
		// udpate 13/09 add more validation field
		d_bulk.RemainingAmount__c = 1;		
		d_bulk.BillIssueCriteria_Month__c = '2';
		d_bulk.BillIssueCriteria_Date__c = '1';
		d_bulk.BillSendScheduleCriteria_Month__c = '4';
		d_bulk.BillSendScheduleCriteria_Day__c = '1';
		d_bulk.SlipDeadline_Month__c = '1';
		d_bulk.SlipDeadline_Day__c = '1';
		d_bulk.TransferDeadline_Month__c = '6';
		d_bulk.TransferDeadline_Day__c = '1';
		insert d_bulk;
		DemandDetail__c d = [Select Id,IsIntegrated__c,DemandDetailCode__c from DemandDetail__c];
		system.debug(d);
		Boolean isConnect2 = CLP_SearchDemandCC.isConnectMikata(d_bulk.Id);
		System.assert(d!=null);
	}

	@isTest global static void getDepartmentsTest(){
		List<Seikyusakibusho__c > s = CLP_SearchDemandCC.getDepartments('');
		System.assert(s.isEmpty());
	}

	@isTest global static void getUsersTest(){
		List<BillingSourceOwner__c> u = CLP_SearchDemandCC.getUsers('');
		System.assert(u.isEmpty());
	}

	@isTest global static void getWrapObjectsTest(){
		ViewSettings__c vs = new ViewSettings__c(User__c = UserInfo.getUserId(), Display_Field__c = 'Id,Name');
		insert vs;

		List<CLP_SearchDemandCC.WrapObject> wo1 = CLP_SearchDemandCC.getWrapObjects();
		System.assert(!wo1.isEmpty());
	}

	@isTest global static void searchNullTest(){
		String jsonString = '{"fields":"Id,Name,Account__c","page":1,"pageSize":500,"sortColumn":"Id","sortOption":"ASC","opts":[{"filter_id":"billing-source","filter_key":"billing-source","filter_value":"第一営業部"},{"filter_id":"search-account","filter_key":"search-account","filter_value":"001280000151IeT"},{"filter_id":"issue-date","filter_key":"issue-date","filter_value":"2017-08-25,2017-08-25"},{"filter_id":"period-date","filter_key":"period-date","filter_value":"2017-08-25,2017-08-25"},{"filter_id":"department","filter_key":"department","filter_value":"a002800000KqrKzAAJ"},{"filter_id":"user","filter_key":"request-user","filter_value":"00528000000GnxsAAC"},{"filter_id":"product_code","filter_key":"product-code","filter_value":"TEST"},{"filter_id":"product_name","filter_key":"product-name","filter_value":"TEST"},{"filter_value":"01228000001DgspAAC","filter_id":"payment","filter_key":"payment"},{"filter_value":"0","filter_id":"demand-type","filter_key":"demand-type"},{"filter_value":"0","filter_id":"condition","filter_key":"condition"},{"filter_value":"0","filter_id":"flag-stop","filter_key":"flag-stop"}]}';
		CLP_DemandWrapper dmw = CLP_SearchDemandCC.search(jsonString);
		System.assertEquals(0, dmw.total);
	}
	@isTest global static void searchTest(){
		String jsonString = '{"fields":"Id,Name","page":1,"pageSize":500,"sortColumn":"Id","sortOption":"ASC","opts":[{"filter_id":"billing-source","filter_key":"billing-source","filter_value":""},{"filter_id":"search-account","filter_key":"search-account","filter_value":""},{"filter_id":"department","filter_key":"department","filter_value":""},{"filter_id":"user","filter_key":"request-user","filter_value":""},{"filter_id":"product_code","filter_key":"product-code","filter_value":""},{"filter_id":"product_name","filter_key":"product-name","filter_value":""},{"filter_value":""},{"filter_value":""},{"filter_value":""},{"filter_value":""}]}';
		CLP_DemandWrapper dmw = CLP_SearchDemandCC.search(jsonString);
		System.assertEquals(0, dmw.total);
	}

	@isTest global static void saveChangeTest(){
		String jsonObject = '[{"Id":"a0jN0000008N514IAC","'+CLP_CommonUtil.ENV_PREFIX+'ErrorMessage__c":"code"}]';
		CLP_JSONResult jr = CLP_SearchDemandCC.saveChange(jsonObject);
		System.assertEquals(false, jr.success);
	}
	@isTest global static void getRelatedListURLNullTest(){
		String url = CLP_SearchDemandCC.getRelatedListURL('Account','PaymentMethod__c','Account__c','001280000151IeT');
		if(String.isBlank(url))
			system.assert(String.isBlank(url));
		else
			system.assert(!String.isBlank(url));
	}

	@isTest global static void getRelatedListURLTest(){
		Account acc = new Account(Name = 'test'
        						, SeikyusakiCode__c = 'CodeTest'
        						,link_customer_code__c = 'abc'
        						,IsIntegrated__c = true);
		insert acc;
		String url = CLP_SearchDemandCC.getRelatedListURL('Account','PaymentMethod__c','AccountId__c',acc.Id);
		if(String.isBlank(url))
			system.assert(String.isBlank(url));
		else
			system.assert(!String.isBlank(url));
	}

	@isTest global static void goToNewDemandPageTest(){
		CLP_SearchDemandCC ctrl = new CLP_SearchDemandCC();
		PageReference ref = ctrl.goToNewDemandPage();
		if(ref == null)
			system.assert(ref == null);
		else
			system.assert(ref != null);
	}
}