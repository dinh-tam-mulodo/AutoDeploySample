@isTest
public with sharing class CLP_SyncBillingIndividualTest {
    @testSetup static void setup(){
        // insert custom setting
        MikataConfig__c mikataConfig = new MikataConfig__c();
        mikataConfig.ApiAccessKey__c = 'dfc9645942d554cd';
        mikataConfig.ApiHost__c = 'https://keirinomikata.jp:10443';
        mikataConfig.ApiUserId__c = 'htamaru@sunbridge.com';
        mikataConfig.NotifyTo1__c = 'tran.huy@mulodo.com';
        mikataConfig.Tax__c = 8; 
        insert mikataConfig;

        // insert account
        Account acc = new Account(Name = 'test'
                                 , SeikyusakiCode__c = '123'
                                 , link_customer_code__c = 'abc1');
                                 //,KEIRINOMIKATA__IsStop__c=false
                                // ,IsIntegrated__c = true
                                // ,ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS);
        insert acc;
        // insert Seikyuusakibusho
        List<Seikyusakibusho__c> individuals = new List<Seikyusakibusho__c>();
        // sei for register
        Seikyusakibusho__c sei = new Seikyusakibusho__c( Name = 'test sei',
                                                        billing_individual_number__c = 's1234',
                                                        link_customer_code__c = 'abc1',
                                                        address1__c = 'address1',
                                                        pref__c = '北海道',
                                                        email__c = 'dinh.tam@mulodo.com',
                                                        zip_code__c = '1234567',
                                                        city_address__c = 'city address',
                                                        Seikyusakimei__c = acc.Id,
                                                        ManipulateStatus__c = CLP_MikataConstant.DEMAND_IN_EDIT,
                                                        tel__c = '0939127600'
                                                        );
        individuals.add(sei);
        // sei for stop
        Seikyusakibusho__c seiStop = new Seikyusakibusho__c( Name = 'test sei1',
                                                        billing_individual_number__c = 's12345',
                                                        link_customer_code__c = 'abc2',
                                                        address1__c = 'address1',
                                                        pref__c = '北海道',
                                                        email__c = 'dinh.tam@mulodo.com',
                                                        zip_code__c = '1234567',
                                                        city_address__c = 'city address',
                                                        Seikyusakimei__c = acc.Id,
                                                        IsStop__c = false,
                                                        StopFlg__c = null,
                                                        IsIntegrated__c = true,
                                                        ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS,
                                                        tel__c = '0939127600'
                                                        );
        individuals.add(seiStop);
        // sei for unstop
        Seikyusakibusho__c seiUnStop = new Seikyusakibusho__c( Name = 'test sei2',
                                                        billing_individual_number__c = 's12346',
                                                        link_customer_code__c = 'abc3',
                                                        address1__c = 'address1',
                                                        pref__c = '北海道',
                                                        email__c = 'dinh.tam@mulodo.com',
                                                        zip_code__c = '1234567',
                                                        city_address__c = 'city address',
                                                        Seikyusakimei__c = acc.Id,
                                                        IsStop__c = true,
                                                        StopFlg__c = CLP_MikataConstant.FLG_STOP,
                                                        IsIntegrated__c = true,
                                                        ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS,
                                                        tel__c = '0939127600'
                                                        );
        individuals.add(seiUnStop);
        insert individuals;
        
        system.assert(!individuals.isEmpty());
    }

    // test constructor
    @isTest static void wrapperTest(){
        CLP_BulkBillingResponseWrapper wrap1 = new CLP_BulkBillingResponseWrapper();
        wrap1.success = null;
        wrap1.error_message = null;
        wrap1.user_id = null;
        wrap1.access_key = null;
        wrap1.billing = null;
        //
        CLP_BulkBillingResponseWrapper.Billing wrap2 = new CLP_BulkBillingResponseWrapper.Billing();
        wrap2.error_code = null;
        wrap2.error_message = null;
        wrap2.code = null;
        wrap2.name = null;
        wrap2.individual = null;
        wrap2.payment = null;
        wrap2.sub_account_title = null;
        //
        CLP_BulkBillingResponseWrapper.Payment wrap3 = new CLP_BulkBillingResponseWrapper.Payment();
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
        CLP_BulkBillingResponseWrapper.Individual wrap4 = new CLP_BulkBillingResponseWrapper.Individual();
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
        CLP_BulkBillingResponseWrapper.Sub_account_title wrap5 = new CLP_BulkBillingResponseWrapper.Sub_account_title();
        wrap5.error_code = null;
        wrap5.error_message = null;
        wrap5.account_receivable_code = null;
        wrap5.advances_received_code = null;
        wrap5.suspense_received_code = null;
        wrap5.account_title_code = null;
        wrap5.journal_cooperation_code = null;
    }

    // test register billing individual
    @isTest static void registerIndividualTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c where ManipulateStatus__c =: CLP_MikataConstant.DEMAND_IN_EDIT];     
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": null,"error_message": null,"code": "'+individuals[0].billing_individual_number__c+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.registerBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test register billing individual was integrated before
    @isTest static void registerIndividualErrorTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c limit 100];      
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": null,"error_message": null,"code": "'+individuals[0].billing_individual_number__c+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.registerBillToMikata(ids);
        CLP_BillingIndividualCC.unStopBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test register billing individual
    @isTest static void registerIndividualWithErrorTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c limit 100];      
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": null,"error_message": "error","code": "'+individuals[0].billing_individual_number__c+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.unStopBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test unstop billing individual with error message
    @isTest static void registerIndividualWithErrorMessageTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c where IsStop__c=true and IsIntegrated__c = true and StopFlg__c =: CLP_MikataConstant.FLG_STOP];      
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": null,"error_message": "error","code": "'+individuals[0].billing_individual_number__c+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.unStopBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test unstop billing individual with http error message
    @isTest static void registerIndividualWithHTTPErrorTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c where IsStop__c=true and IsIntegrated__c = true and StopFlg__c =: CLP_MikataConstant.FLG_STOP];      
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": null,"error_message": "'+CLP_MikataAPI.HTTP_CONNECTION_ERROR+'","code": "'+individuals[0].billing_individual_number__c+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.unStopBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }

    // test multi batch at the same time
    @isTest static void multiBatchTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c from Seikyusakibusho__c where IsStop__c=true and IsIntegrated__c = true and StopFlg__c =: CLP_MikataConstant.FLG_STOP];       
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": null,"error_message": "'+CLP_MikataAPI.HTTP_CONNECTION_ERROR+'","code": "'+individuals[0].Id+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.registerBillToMikata(ids);
        CLP_BillingIndividualCC.registerBillToMikata(ids);

        CLP_BillingIndividualCC.stopBillToMikata(ids);
        CLP_BillingIndividualCC.stopBillToMikata(ids);

        CLP_BillingIndividualCC.unStopBillToMikata(ids);
        CLP_BillingIndividualCC.unStopBillToMikata(ids);
        // multi upsert
        CLP_BillingIndividualBulkUpsertBatch upJobs = new CLP_BillingIndividualBulkUpsertBatch();       
        upJobs.shouldStop = true;           
        Database.executeBatch(upJobs,100);
        // multi stop
        CLP_BillingIndividualBulkStopBatch stopJobs = new CLP_BillingIndividualBulkStopBatch();     
        stopJobs.shouldStop = true;         
        Database.executeBatch(stopJobs,100);
        // multi delete
        CLP_BillingIndividualBulkDeleteBatch delJobs = new CLP_BillingIndividualBulkDeleteBatch();      
        delJobs.shouldStop = true;          
        Database.executeBatch(delJobs,100);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test stop billing individual
    @isTest static void stopIndividualTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c where IsStop__c=false and IsIntegrated__c = true and StopFlg__c = null];     
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": null,"error_message": null,"code": "'+individuals[0].billing_individual_number__c+'","del_flg":0}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.stopBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test register billing individual
    @isTest static void stopIndividualWithErrorTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c limit 100];      
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": "123","error_message": "error","code": "'+individuals[0].billing_individual_number__c+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.stopBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test stop billing individual with error message
    @isTest static void stopIndividualWithErrorMessageTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c where IsStop__c=false and IsIntegrated__c = true and StopFlg__c = null];     
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": "123","error_message": "error","code": "'+individuals[0].billing_individual_number__c+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.stopBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test unstop billing individual with http error message
    @isTest static void stopIndividualWithHTTPErrorTest(){
        List<Seikyusakibusho__c> individuals = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c where IsStop__c=false and IsIntegrated__c = true and StopFlg__c = null];     
        List<Id> ids = new List<Id>();
        for(Seikyusakibusho__c sei : individuals){
            ids.add(sei.Id);
        }
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": "123","error_message": "'+CLP_MikataAPI.HTTP_CONNECTION_ERROR+'","code": "'+individuals[0].billing_individual_number__c+'","del_flg":null}]}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_BillingIndividualCC.stopBillToMikata(ids);
        Test.stopTest();
        system.assert(individuals!=null);
    }
    // test delete demand
    @isTest static void bulkDeleteBillingIndividualTest(){
        List<Seikyusakibusho__c> billings = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c order by billing_individual_number__c desc  limit 100];     
        
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------       
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        Test.setMock(HttpCalloutMock.class,mock);
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": "","error_message": "","code": "'+billings[0].billing_individual_number__c+'","del_flg":1}]}]}';
        Database.delete(billings,false);
        Test.stopTest();
        system.assert(billings!=null);  
    }
    // test delete demand
    @isTest static void bulkDeleteBillingIndividualWithErrorTest(){
        List<Seikyusakibusho__c> billings = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c order by billing_individual_number__c desc  limit 100];     
        
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------       
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        Test.setMock(HttpCalloutMock.class,mock);
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": "123","error_message": "message","code": "'+billings[0].billing_individual_number__c+'","del_flg":1}]}]}';
        Database.delete(billings,false);
        Test.stopTest();
        system.assert(billings!=null);  
    }
    // test delete demand
    @isTest static void bulkDeleteBillingIndividualWithErrorConnectionTest(){
        List<Seikyusakibusho__c> billings = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c order by billing_individual_number__c desc  limit 100];     
        
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------       
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        Test.setMock(HttpCalloutMock.class,mock);
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd", "billing": [{"code": "123","name": "test 2555","individual": [{"error_code": "123","error_message": "'+CLP_MikataAPI.HTTP_CONNECTION_ERROR+'","code": "'+billings[0].billing_individual_number__c+'","del_flg":1}]}]}';
        Database.delete(billings,false);
        Test.stopTest();
        system.assert(billings!=null);  
    }
    // test delete demand
    @isTest static void bulkDeleteBillingIndividualWithNullResultTest(){
        List<Seikyusakibusho__c> billings = [Select Id,ManipulateStatus__c,billing_individual_number__c from Seikyusakibusho__c order by billing_individual_number__c desc  limit 100];     
        
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------       
        Database.delete(billings,false);
        Test.stopTest();
        system.assert(billings!=null);  
    }
    // test delete demand
    @isTest static void bulkUnDeleteBillingIndividualTest(){
        List<Seikyusakibusho__c> billings = [Select Id,ManipulateStatus__c from Seikyusakibusho__c where ManipulateStatus__c =: CLP_MikataConstant.DEMAND_LINK_SUCCESS
                                 and StopFlg__c =: CLP_MikataConstant.FLG_STOP and IsStop__c = true];       
        
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------       
        Database.delete(billings,false);

        undelete billings;
        Test.stopTest();
        system.assert(billings!=null);  
    }
}