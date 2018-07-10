@isTest
private class CLP_AccountBillingCCTest {

	@testSetup static void batchTestSetup(){
		MikataConfig__c mikataConfig = new MikataConfig__c();
		mikataConfig.ApiAccessKey__c = 'dfc9645942d554cd';
		mikataConfig.ApiHost__c = 'https://keirinomikata.jp:10443';
		mikataConfig.ApiUserId__c = 'htamaru@sunbridge.com';
		mikataConfig.NotifyTo1__c = 'tran.huy@mulodo.com';
		mikataConfig.Tax__c = 8; 
		insert mikataConfig;
		// create account for stop
		Account accStopButNotIntegrated = createAccount('test stop but not Integrated','1111','abc1',false,null,false);
		Account accStop = createAccount('test stop','0000','abc2',true,null,false);
		Account accUnStop = createAccount('test unstop','2222','abc3',true,CLP_MikataConstant.FLG_STOP,true);
		List<Account> accountList = new List<Account>{accStopButNotIntegrated,accStop,accUnStop};
		insert accountList;
		
		system.assert(!accountList.isEmpty());
	}
	// create account
	private static Account createAccount(String name,String seikyusakiCode,String customerCode, Boolean isIntegrated , String stopFlg, Boolean isStop){
		Account acc = new Account();
		acc.Name = name;
		acc.link_customer_code__c = customerCode;
		if(String.isNotBlank(stopFlg)) acc.StopFlg__c = stopFlg;
		if(isStop != null) acc.IsStop__c = isStop;
		if(String.isNotBlank(seikyusakiCode)) acc.SeikyusakiCode__c = seikyusakiCode;
		if(isIntegrated != null) acc.IsIntegrated__c = isIntegrated;
		return acc;
	}

	// test stop account
	// account can stop is contains code 000 so ==> "orderby code asc" to get first stop record  
	@isTest static void stopAccountTest(){
		Map<Id,Account> mapAccs = new Map<Id,Account>([Select Id,SeikyusakiCode__c From Account order by SeikyusakiCode__c asc limit 5]);
		List<Id> ids = new List<Id>(mapAccs.keySet());
		
		// -------------------------- Stop completed --------------------------
		Test.startTest();
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": null,"error_message": null,"code": "'+mapAccs.get(ids[0]).SeikyusakiCode__c+'","del_flg": 0,"individual": null,"payment": null}]}';
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_AccountBillingCC.stopAccountBillToMikata(ids);		
		system.assert(mapAccs!=null);
	}
	// stop account with error test
	@isTest static void stopAccountWithErrorTest(){
		Map<Id,Account> mapAccs = new Map<Id,Account>([Select Id,SeikyusakiCode__c From Account where IsStop__c = false order by SeikyusakiCode__c asc]);
		List<Id> ids = new List<Id>(mapAccs.keySet());
		
		// -------------------------- Stop completed --------------------------
		Test.startTest();
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": "1234","error_message": "error message","code": "'+mapAccs.get(ids[0]).SeikyusakiCode__c+'","del_flg": 0,"individual": null,"payment": null}]}';
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_AccountBillingCC.stopAccountBillToMikata(ids);		
		system.assert(mapAccs!=null);
	}
	// stop account with connection error test
	@isTest static void stopAccountWithConnectionErrorTest(){
		Map<Id,Account> mapAccs = new Map<Id,Account>([Select Id,SeikyusakiCode__c From Account where IsStop__c = false order by SeikyusakiCode__c asc]);
		List<Id> ids = new List<Id>(mapAccs.keySet());
		
		// -------------------------- Stop completed --------------------------
		Test.startTest();
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": "1234","error_message": "'+CLP_MikataApi.HTTP_CONNECTION_ERROR+'","code": "'+mapAccs.get(ids[0]).SeikyusakiCode__c+'","del_flg": 0,"individual": null,"payment": null}]}';
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_AccountBillingCC.stopAccountBillToMikata(ids);		
		system.assert(mapAccs!=null);
	}
	// test unstop account 
	@isTest static void stopUnAccountTest(){
		Map<Id,Account> mapAccs = new Map<Id,Account>([Select Id,SeikyusakiCode__c From Account where IsStop__c = true]);
		List<Id> ids = new List<Id>(mapAccs.keySet());
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": null,"error_message": null,"code": "'+mapAccs.get(ids[0]).SeikyusakiCode__c+'","del_flg": 0,"individual": null,"payment": null}]}';
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_AccountBillingCC.unStopAccountBillToMikata(ids);
		Test.stopTest();
		system.assert(mapAccs!=null);
	}
	// test unstop account with error
	@isTest static void stopUnAccountWithErrorTest(){
		Map<Id,Account> mapAccs = new Map<Id,Account>([Select Id,SeikyusakiCode__c From Account where IsStop__c = true]);
		List<Id> ids = new List<Id>(mapAccs.keySet());
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": "1234","error_message": "error message","code": "'+mapAccs.get(ids[0]).SeikyusakiCode__c+'","del_flg": 0,"individual": null,"payment": null}]}';
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_AccountBillingCC.unStopAccountBillToMikata(ids);
		Test.stopTest();
		system.assert(mapAccs!=null);
	}
	// test unstop account with error
	@isTest static void stopUnAccountWithConectionErrorTest(){
		Map<Id,Account> mapAccs = new Map<Id,Account>([Select Id,SeikyusakiCode__c From Account where IsStop__c = true]);
		List<Id> ids = new List<Id>(mapAccs.keySet());
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": "1234","error_message": "'+CLP_MikataApi.HTTP_CONNECTION_ERROR+'","code": "'+mapAccs.get(ids[0]).SeikyusakiCode__c+'","del_flg": 0,"individual": null,"payment": null}]}';
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_AccountBillingCC.unStopAccountBillToMikata(ids);
		Test.stopTest();
		system.assert(mapAccs!=null);
	}
	// test multi batch 
	@isTest static void multiBatchTest(){
		Map<Id,Account> mapAccs = new Map<Id,Account>([Select Id,SeikyusakiCode__c From Account where IsStop__c = true]);
		List<Id> ids = new List<Id>(mapAccs.keySet());
		Test.startTest();
		// -------------------------- Test.startTest() --------------------------
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": null,"error_message": null,"code": "'+ids[0]+'","del_flg": 0,"individual": null,"payment": null}]}';
		Test.setMock(HttpCalloutMock.class,mock);
		CLP_AccountBillingCC.stopAccountBillToMikata(ids);
		CLP_AccountBillingCC.stopAccountBillToMikata(ids);

		CLP_AccountBillingBulkStopBatch progress = new CLP_AccountBillingBulkStopBatch();
		progress.shouldStop = true;
		Database.executeBatch(progress,100);

		CLP_AccountBillingCC.unStopAccountBillToMikata(ids);
		CLP_AccountBillingCC.unStopAccountBillToMikata(ids);

		CLP_AccountBillingBulkUpsertBatch progressUnstop = new CLP_AccountBillingBulkUpsertBatch();
		progressUnstop.shouldStop = true;
		Database.executeBatch(progressUnstop,100);

		CLP_AccountBillingBulkDeleteBatch progressDelete = new CLP_AccountBillingBulkDeleteBatch();
		progressDelete.shouldStop = true;
		Database.executeBatch(progressDelete,100);
		Test.stopTest();
		system.assert(mapAccs!=null);
	}

	// test delete account to run batch delete
	// account can stop is contains code 222 so ==> "orderby code desc" to get first stop record 
	@isTest static void deleteAccountTest(){
		List<Account> accs = [Select Id,SeikyusakiCode__c From Account order by SeikyusakiCode__c desc limit 5];
		Test.startTest();
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		Test.setMock(HttpCalloutMock.class,mock);
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": null,"error_message": null,"code": "'+accs[0].SeikyusakiCode__c+'","del_flg": 1,"individual": null,"payment": null}]}';
		Database.DeleteResult[] results =  Database.delete(accs,false);
		List<Account> delAccs = new List<Account>();
		for(Integer i =0;i<accs.size();i++){
			if(results[i].isSuccess())
				delAccs.add(accs[i]);
		}
		undelete delAccs;
		Test.stopTest();
		system.assert(accs!=null);
	} 
	// test delete account with error
	@isTest static void deleteAccountWithConectionErrorTest(){
		MikataInteBuffer__c bf = new MikataInteBuffer__c(SObjectType__c='Account',ManipulateStatus__c=CLP_MikataConstant.DEMAND_LINK_AWAITING);
		insert bf;
		List<Account> accs = [Select Id,SeikyusakiCode__c From Account order by SeikyusakiCode__c desc limit 5];
		Test.startTest();
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		Test.setMock(HttpCalloutMock.class,mock);
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": "222","error_message": "'+CLP_MikataApi.HTTP_CONNECTION_ERROR+'","code": "'+accs[0].SeikyusakiCode__c+'","del_flg": 1,"individual": null,"payment": null}]}';
		Database.delete(accs,false);
		Test.stopTest();
		system.assert(accs!=null);
	} 
	// test delete account with error
	@isTest static void deleteAccountWithErrorTest(){
		List<Account> accs = [Select Id,SeikyusakiCode__c From Account order by SeikyusakiCode__c desc limit 5];
		Test.startTest();
		CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
		Test.setMock(HttpCalloutMock.class,mock);
		mock.body = '{"user_id": "test@cloudpayment.co.jp","access_key": "8b3a95e9c3e279d1","billing": [{"error_code": "222","error_message": "error message","code": "'+accs[0].SeikyusakiCode__c+'","del_flg": 1,"individual": null,"payment": null}]}';
		Database.delete(accs,false);
		Test.stopTest();
		system.assert(accs!=null);
	}
	
}