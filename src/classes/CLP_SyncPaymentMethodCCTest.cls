@isTest
private class CLP_SyncPaymentMethodCCTest {
	@testSetup static void commonSetupTest() {
		// create custom setting
		MikataConfig__c mikataConfig = new MikataConfig__c();
		mikataConfig.ApiAccessKey__c = 'dfc9645942d554cd';
		mikataConfig.ApiHost__c = 'https://keirinomikata.jp:10443';
		mikataConfig.ApiUserId__c = 'htamaru@sunbridge.com';
		mikataConfig.NotifyTo1__c = 'tran.huy@mulodo.com';
		mikataConfig.Tax__c = 8; 
		insert mikataConfig;

		// Create data
		// Account
		Account goodAcc = new Account();
		goodAcc.Name = 'goodAcc';
		goodAcc.SeikyusakiCode__c = '00001';
		goodAcc.IsIntegrated__c = false;
		goodAcc.IsStop__c = false;
		goodAcc.MikataCooperate__c = false;
		goodAcc.StopFlg__c = null;
		goodAcc.link_customer_code__c = '10001';

		Account badAcc = new Account();
		badAcc.Name = 'badAcc';
		badAcc.SeikyusakiCode__c = null;
		badAcc.IsIntegrated__c = false;
		badAcc.IsStop__c = false;
		badAcc.MikataCooperate__c = false;
		badAcc.StopFlg__c = null;
		badAcc.link_customer_code__c = '10002';
		List<Account> listAcc = new List<Account>{goodAcc, badAcc};
		insert listAcc;

		// BillingSourceBankAccountPattern__c
		BillingSourceBankAccountPattern__c billSource = new BillingSourceBankAccountPattern__c(Name = 'billSource', Code__c = '00003');
		insert billSource;

		// Record type
		String paymentMethodName = CLP_CommonUtil.ENV_PREFIX + 'PaymentMethod__c';
		RecordType bankTransfer = 			[Select id from RecordType where DeveloperName = 'BankTransfer' and SobjectType = :paymentMethodName];
		RecordType creditCard = 			[Select id from RecordType where DeveloperName = 'CreditCard' and SobjectType = :paymentMethodName];
		RecordType bankCheck = 				[Select id from RecordType where DeveloperName = 'BankCheck' and SobjectType = :paymentMethodName];
		RecordType cp_AccountTransfer = 	[Select id from RecordType where DeveloperName = 'CP_AccountTransfer' and SobjectType = :paymentMethodName];
		RecordType rl_AccountTransfer = 	[Select id from RecordType where DeveloperName = 'RL_AccountTransfer' and SobjectType = :paymentMethodName];
		RecordType other_AccountTransfer =	[Select id from RecordType where DeveloperName = 'Other_AccountTransfer' and SobjectType = :paymentMethodName];
		RecordType paymentSlip = 			[Select id from RecordType where DeveloperName = 'PaymentSlip' and SobjectType = :paymentMethodName];

		List<Id> listRecordType = new List<Id>();
		listRecordType.add(bankTransfer.Id);
		listRecordType.add(creditCard.Id);
		listRecordType.add(bankCheck.Id);
		listRecordType.add(cp_AccountTransfer.Id);
		listRecordType.add(rl_AccountTransfer.Id);
		listRecordType.add(other_AccountTransfer.Id);
		listRecordType.add(paymentSlip.Id);

		// PaymentMethod__c good
		List<PaymentMethod__c> goodlistPm = new List<PaymentMethod__c>();
		for (Integer i=0; i<7; i++) {
			PaymentMethod__c pm = new PaymentMethod__c();
			pm.Name = 'goodPm-' + i;
			pm.PaymentMethodCode__c = 'goodItemCodePm-' + i;
			pm.RegisterStatus__c = '0';
			pm.BankAccountName__c = 'MulodoVN';
			pm.BankAccountType__c = '1';
			pm.BankCode__c = '9900';
			pm.BankAccountNumber__c = '1234567' + i;
			pm.AccountId__c = goodAcc.Id;
			pm.BillingSourceBankAccountPatternId__c = billSource.Id;
			pm.RecordTypeId = listRecordType.get(i); 
			pm.IsIntegrated__c = false;
			pm.IsStop__c = false;
			pm.StopFlg__c = '';	
			pm.ManipulateStatus__c = '0';
			goodlistPm.add(pm);
		}
		insert goodlistPm;

		// PaymentMethod__c bad
		List<PaymentMethod__c> badListPm = new List<PaymentMethod__c>();
		for (Integer i=0; i<7; i++) {
			PaymentMethod__c pm = new PaymentMethod__c();
			pm.Name = 'badPm-' + i;
			pm.PaymentMethodCode__c = 'badItemCodePm-' + i;
			pm.RegisterStatus__c = '0';
			pm.BankAccountName__c = null;
			pm.BankAccountType__c = null;
			pm.BankCode__c = null;
			pm.BankAccountNumber__c = null;
			pm.AccountId__c = badAcc.Id;
			pm.BillingSourceBankAccountPatternId__c = null;
			pm.RecordTypeId = listRecordType.get(i); 
			pm.IsIntegrated__c = false;
			pm.IsStop__c = false;
			pm.StopFlg__c = '';	
			pm.ManipulateStatus__c = '0';
			badListPm.add(pm);
		}
		insert badListPm;
		
		// Create account
		Account stopAcc = new Account();
		stopAcc.Name = 'Stopped Account';
		stopAcc.IsIntegrated__c = true;
		stopAcc.IsStop__c = false;
		stopAcc.StopFlg__c = null;
		stopAcc.MikataCooperate__c = false;
		stopAcc.link_customer_code__c = '20001';
		insert stopAcc;

		// Single PaymentMethod__c linked with account above
		PaymentMethod__c pm = new PaymentMethod__c();
		pm.Name = 'linkedStopAccPm'; 
		pm.PaymentMethodCode__c = 'StopItemCodePm';
		pm.RegisterStatus__c = '0';
		pm.BankAccountName__c = null;
		pm.BankAccountType__c = null;
		pm.BankCode__c = null;
		pm.BankAccountNumber__c = null;
		pm.AccountId__c = stopAcc.Id;
		pm.BillingSourceBankAccountPatternId__c = null;
		pm.RecordTypeId = listRecordType[6]; 
		pm.IsIntegrated__c = false;
		pm.IsStop__c = false;
		pm.StopFlg__c = '';	
		pm.ManipulateStatus__c = '0';
		insert pm;

		system.assert(mikataConfig != null);
	}

	@isTest static void constructorTest() {
		CLP_SyncPaymentMethodCC cons1 = new CLP_SyncPaymentMethodCC();
		CLP_MikataPaymentMethodApi cons2 = new CLP_MikataPaymentMethodApi();
		CLP_PaymentMethodTriggerHandler cons3 = new CLP_PaymentMethodTriggerHandler();
		system.assert(cons1 != null);
		system.assert(cons2 != null);
		system.assert(cons3 != null);
	}

	@isTest static void wrapperTest() {
		CLP_BulkBillingWrapper wrap1 = new CLP_BulkBillingWrapper();
		wrap1.success = null;
		wrap1.error_message = null;
		wrap1.user_id = null;
		wrap1.access_key = null;
		wrap1.billing = null;
		//	
		CLP_BulkBillingWrapper.Billing wrap2 = new CLP_BulkBillingWrapper.Billing();
		wrap2.error_code = null;
		wrap2.error_message = null;
		wrap2.code = null;
		wrap2.name = null;
		wrap2.individual = null;
		wrap2.payment = null;
		wrap2.sub_account_title = null;
		//
		CLP_BulkBillingWrapper.Payment wrap3 = new CLP_BulkBillingWrapper.Payment();
		wrap3.error_code = null;
		wrap3.error_message = null;
		wrap3.del_flg = null;
		wrap3.number_Z = null;
		wrap3.code = null;
		wrap3.name = null;
		wrap3.bank_transfer_pattern_code = null;
		wrap3.payment_method = null;
		wrap3.register_status = null;
		wrap3.source_bank_account_name = null;
		wrap3.customer_number = null;
		wrap3.bank_code = null;
		wrap3.bank_name = null;
		wrap3.branch_code = null;
		wrap3.branch_name = null;
		wrap3.bank_account_type = null;
		wrap3.bank_account_number = null;
		wrap3.bank_account_name = null;
		wrap3.payment_type = null;
		wrap3.cod = null;
		wrap3.bank_check_bank_code = null;
		wrap3.bank_check_bank_name = null;
		wrap3.bank_check_branch_code = null;
		wrap3.bank_check_branch_name = null;
		wrap3.bank_check_kind = null;
		wrap3.bank_check_bank_account_number = null;
		wrap3.url = null;
		wrap3.credit_card_regist_kind = null;
		//
		CLP_BulkBillingWrapper.Individual wrap4 = new CLP_BulkBillingWrapper.Individual();
		wrap4.error_code = null;
		wrap4.error_message = null;
		wrap4.number_Z = null;
		wrap4.code = null;
		wrap4.name = null;
		wrap4.link_customer_code = null;
		wrap4.address1 = null;
		wrap4.address2 = null;
		wrap4.address3 = null;
		wrap4.zip_code = null;
		wrap4.pref = null;
		wrap4.city_address = null;
		wrap4.building_name = null;
		wrap4.set_post_address = null;
		wrap4.post_address1 = null;
		wrap4.post_address2 = null;
		wrap4.post_address3 = null;
		wrap4.post_zip_code = null;
		wrap4.post_pref = null;
		wrap4.post_city_address = null;
		wrap4.post_building_name = null;
		wrap4.tel = null;
		wrap4.email = null;
		wrap4.cc_email = null;
		wrap4.memo = null;
		wrap4.billing_method = null;
		wrap4.issue_month = null;
		wrap4.issue_day = null;
		wrap4.sending_month = null;
		wrap4.sending_day = null;
		wrap4.deadline_month = null;
		wrap4.deadline_day = null;
		wrap4.payment_method_code = null;
		wrap4.bs_owner_code = null;
		wrap4.ref_billing_code = null;
		wrap4.ref_individual_number = null;
		wrap4.ref_individual_code = null;
		wrap4.bill_template_code = null;
		wrap4.del_flg = null;
		wrap4.sub_account_title = null;
		//
		CLP_BulkBillingWrapper.Sub_account_title wrap5 = new CLP_BulkBillingWrapper.Sub_account_title(); 
		wrap5.error_code = null;
		wrap5.error_message = null;
		wrap5.account_receivable_code = null;
		wrap5.advances_received_code = null;
		wrap5.suspense_received_code = null;
		wrap5.account_title_code = null;
		wrap5.journal_cooperation_code = null;
		//
		system.assert(wrap1 != null);
		system.assert(wrap2 != null);
		system.assert(wrap3 != null);
		system.assert(wrap4 != null);
		system.assert(wrap5 != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           REGISTER MIKATA PAYMENT METHOD                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void registerMikataErrorValidationTest() {
		// Cas return true
		List<PaymentMethod__c> badlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, ManipulateStatus__c 
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'badItemCodePm%'
		                          	          Limit 1]; 	                          	       
		badlistPm[0].StopFlg__c = '0';
		badlistPm[0].IsStop__c = true;
		badlistPm[0].IsIntegrated__c = true;
		update badlistPm;
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : badlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		Test.stopTest();
		system.assert(badlistPm != null);
	}

	@isTest static void registerMikataErrorRegisterBeforeTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, ManipulateStatus__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '7'
		                          	          limit 1];
		goodlistPm.get(0).IsIntegrated__c = true;	
		goodlistPm.get(0).IsStop__c = false;
		goodlistPm.get(0).StopFlg__c = '';   
		goodlistPm.get(0).ManipulateStatus__c = '3';   
		update goodlistPm;                  	          
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerMikataExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	/*@isTest static void registerMikataExceptionTwoTest() {
		List<PaymentMethod__c> listPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c,
										 AccountId__c, AccountId__r.IsStop__c, AccountId__r.IsIntegrated__c, AccountId__r.StopFlg__c 
                          		      From PaymentMethod__c
                          	          Where PaymentMethodCode__c = 'StopItemCodePm'];
       	Account acc = listPm[0].AccountId__r;
       	acc.IsStop__c = true;
       	acc.StopFlg__c = '0';
       	update acc;
		String pmJson = JSON.serialize(listPm);

		Test.startTest();
		CLP_SyncPaymentMethodCC.registerMikata(pmJson);
		Test.stopTest();
		system.assert(acc != null);
	}*/

	@isTest static void registerMikataSuccessTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerMikataErrorBillingTest()
	{
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null, "billing":[{"code":"00001","error_message":"error01","individual":[],"sub_account_title":[],"payment":[{"code":null,"error_message":null}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerMikataErrorPaymentTest()
	{
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":null,"error_message":"error01"}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerMikataErrorInterfaceTest()
	{
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'];
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerMikataErrorDuplicateTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		CLP_SyncPaymentMethodCC.registerMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           STOP MIKATA PAYMENT METHOD                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void stopMikataErrorValidationTest() {
		// Cas return true
		List<PaymentMethod__c> badlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, ManipulateStatus__c 
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'badItemCodePm%'
		                          	          Limit 1]; 	                          	       
		badlistPm[0].IsIntegrated__c = true;
		badlistPm[0].IsStop__c = true;
		badlistPm[0].StopFlg__c = '0';
		update badlistPm;
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : badlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.stopMikata(listIds);
		Test.stopTest();
		system.assert(badlistPm != null);
	}

	@isTest static void stopMikataExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncPaymentMethodCC.stopMikata(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	/*@isTest static void stopMikataExceptionTwoTest() {
		List<PaymentMethod__c> listPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c,
										 AccountId__c, AccountId__r.IsStop__c, AccountId__r.IsIntegrated__c, AccountId__r.StopFlg__c 
                          		      From PaymentMethod__c
                          	          Where PaymentMethodCode__c = 'StopItemCodePm'];
       	Account acc = listPm[0].AccountId__r;
       	acc.IsStop__c = true;
       	acc.StopFlg__c = '0';
       	update acc;
		String pmJson = JSON.serialize(listPm);

		Test.startTest();
		CLP_SyncPaymentMethodCC.stopMikata(pmJson);
		Test.stopTest();
		system.assert(acc != null);
	}*/

	@isTest static void stopMikataSuccessTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true; 
		update goodlistPm;                     	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.stopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void stopMikataErrorBillingTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];

		goodlistPm[0].IsIntegrated__c = true;  
		update goodlistPm;                           	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null, "billing":[{"code":"00001","error_message":"error01","individual":[],"sub_account_title":[],"payment":[{"code":null,"error_message":null}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.stopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void stopMikataErrorPaymentTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];

		goodlistPm[0].IsIntegrated__c = true;   
		update goodlistPm;	                          	             	                          	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":"error01"}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.stopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void stopMikataErrorInterfaceTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;	
		update goodlistPm;	      
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.stopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void stopMikataErrorDuplicateTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;	  	
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.stopMikata(listIds);
		CLP_SyncPaymentMethodCC.stopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           UNSTOP MIKATA PAYMENT METHOD                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void unstopMikataErrorValidationTest() {
		// Cas return true
		List<PaymentMethod__c> badlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, ManipulateStatus__c 
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'badItemCodePm%'
		                          	          Limit 2]; 	                          	       
		badlistPm[0].IsIntegrated__c = false;
		badlistPm[0].IsStop__c = false;
		badlistPm[0].StopFlg__c = null;
		badlistPm[1].IsIntegrated__c = true;
		badlistPm[1].IsStop__c = false;
		badlistPm[1].StopFlg__c = null;
		update badlistPm; 
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : badlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.unstopMikata(listIds);
		Test.stopTest();
		system.assert(badlistPm != null);
	}

	@isTest static void unstopMikataExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncPaymentMethodCC.unstopMikata(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	/*@isTest static void unstopMikataExceptionTwoTest() {
		List<PaymentMethod__c> listPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c,
										 AccountId__c, AccountId__r.IsStop__c, AccountId__r.IsIntegrated__c, AccountId__r.StopFlg__c 
                          		      From PaymentMethod__c
                          	          Where PaymentMethodCode__c = 'StopItemCodePm'];
       	Account acc = listPm[0].AccountId__r;
       	acc.IsStop__c = true;
       	acc.StopFlg__c = '0';
       	update acc;
		String pmJson = JSON.serialize(listPm);

		Test.startTest();
		CLP_SyncPaymentMethodCC.unstopMikata(pmJson);
		Test.stopTest();
		system.assert(acc != null);
	}*/

	@isTest static void unstopMikataSuccessTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0';  
		update goodlistPm;                         	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.unstopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void unstopMikataErrorBillingTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0';      
		update goodlistPm;                      	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null, "billing":[{"code":"00001","error_message":"error01","individual":[],"sub_account_title":[],"payment":[{"code":null,"error_message":null}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.unstopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void unstopMikataErrorPaymentTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0';
		update goodlistPm;       	                          	             	                          	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":"error01"}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.unstopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void unstopMikataErrorInterfaceTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0'; 
		update goodlistPm;     
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.unstopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void unstopMikataErrorDupicateTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0';
		update goodlistPm; 	
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.unstopMikata(listIds);
		CLP_SyncPaymentMethodCC.unstopMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           DELETE PAYMENT METHOD                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void deleteMikataErrorValidationTest() {
		// Cas return true
		List<PaymentMethod__c> badlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, ManipulateStatus__c 
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'badItemCodePm%'
		                          	          Limit 1]; 	                          	       
		badlistPm[0].IsIntegrated__c = true;
		update badlistPm;
		String pmJson = JSON.serialize(badlistPm);

		Test.startTest();
		Database.delete(badlistPm, false);
		Test.stopTest();
		system.assert(badlistPm != null);
	}

	@isTest static void deleteMikataSuccessTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0';
		update goodlistPm;                          	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         

		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		Database.delete(goodlistPm, false);
		Database.undelete(goodlistPm, false);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void deleteMikataErrorBillingTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0'; 
		update goodlistPm;                            	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         

		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null, "billing":[{"code":"00001","error_message":"error01","individual":[],"sub_account_title":[],"payment":[{"code":null,"error_message":null}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		Database.delete(goodlistPm, false);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void deleteMikataErrorPaymentTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0';    
		update goodlistPm;   	                          	             	                          	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         

		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":"error01"}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		Database.delete(goodlistPm, false);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void deleteMikataErrorInterfaceTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0';    
		update goodlistPm;    

		Test.startTest();
		Database.delete(goodlistPm, false);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void deleteMikataErrorDuplicateTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		goodlistPm[0].IsStop__c = true;
		goodlistPm[0].StopFlg__c = '0'; 
		update goodlistPm;	
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         

		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		Database.delete(goodlistPm, false);
		Database.delete(goodlistPm, false);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           REGISTER STATUS CREDIT CARD PAYMENT METHOD                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void registerCreditCardErrorValidationTest() {
		// Cas return true
		List<PaymentMethod__c> badlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, ManipulateStatus__c 
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'badItemCodePm%'
		                          	          Limit 2]; 	
		badlistPm[1].IsIntegrated__c = true;  
		badlistPm[1].IsStop__c = true;     
		badlistPm[1].StopFlg__c = '0';    
		update badlistPm;                  	                                    	       
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : badlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(listIds);
		Test.stopTest();
		system.assert(badlistPm != null);
	}

	@isTest static void registerCreditCardExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	/*@isTest static void registerCreditCardExceptionTwoTest() {
		List<PaymentMethod__c> listPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c,
										 AccountId__c, AccountId__r.IsStop__c, AccountId__r.IsIntegrated__c, AccountId__r.StopFlg__c 
                          		      From PaymentMethod__c
                          	          Where PaymentMethodCode__c = 'StopItemCodePm'];
       	Account acc = listPm[0].AccountId__r;
       	acc.IsStop__c = true;
       	acc.StopFlg__c = '0';
       	update acc;
		String pmJson = JSON.serialize(listPm);

		Test.startTest();
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(pmJson);
		Test.stopTest();
		system.assert(acc != null);
	}*/

	@isTest static void registerCreditCardSuccessTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '1'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;                          	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerCreditCardErrorBillingTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '1'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true; 
		update goodlistPm;                            	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null, "billing":[{"code":"00001","error_message":"error01","individual":[],"sub_account_title":[],"payment":[{"code":null,"error_message":null}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerCreditCardErrorPaymentTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '1'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;   	                          	             	                          	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":"error01"}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerCreditCardErrorInterfaceTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '1'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;    
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void registerCreditCardErrorDuplicateTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '1'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;	
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(listIds);
		CLP_SyncPaymentMethodCC.registerCreditCardMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	//------------------------------------------------------------------------------------------------------------------//
	//
	//                                           REQUEST FORM URL PAYMENT METHOD                                                 
	//                                      
	//------------------------------------------------------------------------------------------------------------------//
	@isTest static void getUrlFormPdfErrorValidationTest() {
		// Cas return true
		List<PaymentMethod__c> badlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, ManipulateStatus__c 
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'badItemCodePm%'
		                          	          Limit 2];	                          	       
		badlistPm[1].IsIntegrated__c = true;
		badlistPm[1].IsStop__c = true;
		badlistPm[1].StopFlg__c = '0';
		update badlistPm;
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : badlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"badItemCodePm-0","error_message":null,"register_status":"5"}]}]}';  		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(listIds);
		Test.stopTest();
		system.assert(badlistPm != null);
	}

	@isTest static void getUrlFormPdfExceptionOneTest() {
		List<Id> listIds = new List<Id>();
		Test.startTest();
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(listIds);
		Test.stopTest();
		system.assert(listIds != null);
	}

	/*@isTest static void getUrlFormPdfExceptionTwoTest() {
		List<PaymentMethod__c> listPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c,
										 AccountId__c, AccountId__r.IsStop__c, AccountId__r.IsIntegrated__c, AccountId__r.StopFlg__c 
                          		      From PaymentMethod__c
                          	          Where PaymentMethodCode__c = 'StopItemCodePm'];
       	Account acc = listPm[0].AccountId__r;
       	acc.IsStop__c = true;
       	acc.StopFlg__c = '0';
       	update acc;
		String pmJson = JSON.serialize(listPm);

		Test.startTest();
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(pmJson);
		Test.stopTest();
		system.assert(acc != null);
	}*/

	@isTest static void getUrlFormPdfSuccessTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '3'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;                          	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void getUrlFormPdfErrorBillingTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '3'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true; 
		update goodlistPm;                            	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null, "billing":[{"code":"00001","error_message":"error01","individual":[],"sub_account_title":[],"payment":[{"code":null,"error_message":null}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void getUrlFormPdfErrorPaymentTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '3'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;   	                          	             	                          	          
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":"error01"}]}]}';
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void getUrlFormPdfErrorInterfaceTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '3'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;    
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}

	@isTest static void getUrlFormPdfErrorDuplicateTest() {
		// Cas return true
		List<PaymentMethod__c> goodlistPm = [Select IsIntegrated__c, IsStop__c, StopFlg__c, PaymentMethodCode__c, PaymentMethod__c
		                          		      From PaymentMethod__c
		                          	          Where PaymentMethodCode__c like 'goodItemCodePm%'
		                          	          And PaymentMethod__c = '3'
		                          	          Limit 1];
		goodlistPm[0].IsIntegrated__c = true;
		update goodlistPm;	
		String pmcode = goodlistPm.get(0).PaymentMethodCode__c; 	                          	         
		//
		List<Id> listIds = new List<Id>();
		for (PaymentMethod__c pm : goodlistPm) {
			listIds.add(pm.Id);	
		}
		Test.startTest();
		String jsonString = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"error_message":null,"billing":[{"code":"00001","error_message":null,"individual":[],"sub_account_title":[],"payment":[{"code":"' + pmcode + '","error_message":null,"register_status":"5"}]}]}';   		    
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = jsonString;
		Test.setMock(HttpCalloutMock.class, mock);
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(listIds);
		CLP_SyncPaymentMethodCC.requestAccountTransferMikata(listIds);
		Test.stopTest();
		system.assert(goodlistPm != null);
	}
}