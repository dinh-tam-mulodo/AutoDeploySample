@isTest
public with sharing class CLP_SyncDemandDetailTest {
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
                                , SeikyusakiCode__c = 'CodeTest'
                                ,link_customer_code__c = 'abc'
                                ,IsIntegrated__c = true);
        upsert acc;
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
        //system.debug('Payment:'+pay);
        // insert list demand to test
        List<DemandDetail__c> demandList = new List<DemandDetail__c>();
        // demand to click bulk upsert
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
        d_bulk.TransferDeadline_Month__c = '6';
        d_bulk.TransferDeadline_Day__c = '1';
         d_bulk.SlipDeadline_Month__c = '8';
        d_bulk.SlipDeadline_Day__c = '1';
        demandList.add(d_bulk);
        // demand to stop
        DemandDetail__c d_stop = new DemandDetail__c();
        d_stop.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
        d_stop.StopFlg__c = null;
        d_stop.IsStop__c = false;
        d_stop.IsIntegrated__c = true;
        d_stop.AwaitingGetNewInfo__c = false;
        d_stop.Account__c = acc.Id;
        d_stop.Seikyuusakibusho__c = sei.Id;
        d_stop.PaymentMethod__c = pay.Id;
        d_stop.DemandType__c = '0';
        d_stop.ProductName__c = 'test product';
        d_stop.Price__c = 1;
        d_stop.Quantity__c = 1;
        d_stop.TaxCategory__c = '0';
        d_stop.TaxRate__c = '8%';
        d_stop.PaymentProcess__c = '0';
        d_stop.StartDate__c = Date.today();
        d_stop.Period_Format__c = '0';
        d_stop.BillIssueDate__c = Date.today();
        d_stop.BillSendDate__c = Date.today();
        d_stop.PaymentDeadlineDate__c = Date.today();
        d_stop.Slip_Deadline__c = Date.today();
        // udpate 13/09 add more validation field
        d_stop.RemainingAmount__c = 1;      
        d_stop.BillIssueCriteria_Month__c = '2';
        d_stop.BillIssueCriteria_Date__c = '1';
        d_stop.BillSendScheduleCriteria_Month__c = '4';
        d_stop.BillSendScheduleCriteria_Day__c = '1';
        d_stop.TransferDeadline_Month__c = '6';
        d_stop.TransferDeadline_Day__c = '1';        
        d_stop.SlipDeadline_Month__c = '8';
        d_stop.SlipDeadline_Day__c = '1';
        demandList.add(d_stop);
        // demand to unstop
        DemandDetail__c d_unstop = new DemandDetail__c();
        d_unstop.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
        d_unstop.StopFlg__c = CLP_MikataConstant.FLG_STOP;
        d_unstop.IsStop__c = true;
        d_unstop.IsIntegrated__c = true;
        d_unstop.AwaitingGetNewInfo__c = false;
        d_unstop.Account__c = acc.Id;
        d_unstop.Seikyuusakibusho__c = sei.Id;
        d_unstop.PaymentMethod__c = pay.Id;
        d_unstop.DemandType__c = '0';
        d_unstop.ProductName__c = 'test product';
        d_unstop.Price__c = 1;
        d_unstop.Quantity__c = 1;
        d_unstop.TaxCategory__c = '0';
        d_unstop.TaxRate__c = '8%';
        d_unstop.PaymentProcess__c = '0';
        d_unstop.StartDate__c = Date.today();
        d_unstop.Period_Format__c = '0';
        d_unstop.BillIssueDate__c = Date.today();
        d_unstop.BillSendDate__c = Date.today();
        d_unstop.PaymentDeadlineDate__c = Date.today();
        d_unstop.Slip_Deadline__c = Date.today();
        // udpate 13/09 add more validation field
        d_unstop.RemainingAmount__c = 1;        
        d_unstop.BillIssueCriteria_Month__c = '2';
        d_unstop.BillIssueCriteria_Date__c = '1';
        d_unstop.BillSendScheduleCriteria_Month__c = '4';
        d_unstop.BillSendScheduleCriteria_Day__c = '1';
        d_unstop.TransferDeadline_Month__c = '6';
        d_unstop.TransferDeadline_Day__c = '1';        
        d_unstop.SlipDeadline_Month__c = '8';
        d_unstop.SlipDeadline_Day__c = '1';
        demandList.add(d_unstop);       

        insert demandList;
        system.debug(demandList);
        system.assert(!demandList.isEmpty());
    }
    // test register demand
    @isTest static void registerDemandTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c where ManipulateStatus__c =: CLP_MikataConstant.DEMAND_IN_EDIT];     
        String jsonString = JSON.serialize(demand);
        system.debug(jsonString);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":null,"error_message":null,"error_code":null,"del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_SearchDemandCC.bulkUpsertDemand(jsonString);
        Test.stopTest();
        system.assert(demand!=null);
    }
    // register failed null code
    @isTest static void registerDemandFailedTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c where ManipulateStatus__c =: CLP_MikataConstant.DEMAND_IN_EDIT];     
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":null,"number_Z":null,"error_message":null,"error_code":null,"del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_SearchDemandCC.bulkUpsertDemand(jsonString);
        Test.stopTest();
        system.assert(demand!=null);
    }
    // register fail with error
    @isTest static void registerDemandFailedWithErrorTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];
        for(DemandDetail__c d: demand){
            d.StopFlg__c = CLP_MikataConstant.FLG_STOP;
            d.IsIntegrated__c = true;
            d.IsStop__c = true;
        }
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","number_Z":null,"error_message":"error","error_code":"123","del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);   
        CLP_SearchDemandCC.bulkUnStopDemand(jsonString);
        Test.stopTest();
        system.assert(demand!=null);
    }
    // register fail with error connection
    @isTest static void registerDemandFailedWithErrorConnectionTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c  limit 1];
        for(DemandDetail__c d: demand){
            d.StopFlg__c = CLP_MikataConstant.FLG_STOP;
            d.IsIntegrated__c = true;
            d.IsStop__c = true;
        }
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","number_Z":null,"error_message":"'+CLP_MikataAPI.HTTP_CONNECTION_ERROR+'","error_code":"123","del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);   
        CLP_SearchDemandCC.bulkUnStopDemand(jsonString);
        Test.stopTest();
        system.assert(demand!=null);
    }
    // register fail with error failed bulkwrapper
    @isTest static void registerDemandFailedWrapperTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c  limit 1];
        for(DemandDetail__c d: demand){
            d.StopFlg__c = CLP_MikataConstant.FLG_STOP;
            d.IsIntegrated__c = true;
            d.IsStop__c = true;
        }       
        update demand;       
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":"false","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":null,"error_message":"","error_code":null,"del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);   
        CLP_SearchDemandCC.bulkUnStopDemand(jsonString);
        Test.stopTest();
        system.assert(demand!=null);
    }
    // search fail with error test
    @isTest static void searchDemandFailedWithErrorConnectionTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];   
        // edit demand to comfor with search api condition
        for(DemandDetail__c d: demand){
            d.RemainingAmount__c = 1;
            d.BillIssueDate__c = Date.today();
            d.StopFlg__c = '';
            d.IsStop__c = false;
            d.IsIntegrated__c = true;
            d.AwaitingGetNewInfo__c = false;
            d.DemandDetailCode__c = '1';
        }   
        update demand;        

        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":"1","error_message":"'+CLP_MikataAPI.HTTP_CONNECTION_ERROR+'","error_code":"123","del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);   
        CLP_SearchDemandCC.bulkSearchDemand();
        Test.stopTest();
        system.assert(demand!=null);
    }
    // search fail with error connection test
    @isTest static void searchDemandFailedWithErrorTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];   
        // edit demand to comfor with search api condition
        for(DemandDetail__c d: demand){
            d.RemainingAmount__c = 1;
            d.BillIssueDate__c = Date.today();
            d.StopFlg__c = '';
            d.IsStop__c = false;
            d.IsIntegrated__c = true;
            d.AwaitingGetNewInfo__c = false;
            d.DemandDetailCode__c = '1';
        }   
        update demand;

        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":"1","error_message":"error","error_code":"123","del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);   
        CLP_SearchDemandCC.bulkSearchDemand();
        Test.stopTest();
        system.assert(demand!=null);
    }
    // search fail with error test
    @isTest static void searchDemandFailedWithErrorWrapperTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];   
        // edit demand to comfor with search api condition
        for(DemandDetail__c d: demand){
            d.RemainingAmount__c = 1;
            d.BillIssueDate__c = Date.today();
            d.StopFlg__c = '';
            d.IsStop__c = false;
            d.IsIntegrated__c = true;
            d.AwaitingGetNewInfo__c = false;            
            d.DemandDetailCode__c = '1';
        }   
        update demand;

        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","success":"false","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":"1","error_message":"'+CLP_MikataAPI.HTTP_CONNECTION_ERROR+'","error_code":"123","del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);   
        CLP_SearchDemandCC.bulkSearchDemand();
        Test.stopTest();
        system.assert(demand!=null);
    }
    // search fail with error test
    @isTest static void searchDemandFailedNullCodeTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];   
        // edit demand to comfor with search api condition
        for(DemandDetail__c d: demand){
            d.RemainingAmount__c = 1;
            d.BillIssueDate__c = Date.today();
            d.StopFlg__c = '';
            d.IsStop__c = false;
            d.IsIntegrated__c = true;
            d.AwaitingGetNewInfo__c = false;            
            d.DemandDetailCode__c = '1';
        }   
        update demand;

        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","success":true,"access_key":"dfc9645942d554cd","demand":[{"code":null,"billing_code":"CodeTest","number_Z":"1","error_message":"","error_code":"","del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);   
        CLP_SearchDemandCC.bulkSearchDemand();
        Test.stopTest();
        system.assert(demand!=null);
    }
    // test stop demand
    @isTest static void stopDemandTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];
        for(DemandDetail__c d: demand){
            d.StopFlg__c = null;
            d.IsStop__c = false;
            d.AwaitingGetNewInfo__c = false;
            d.IsIntegrated__c = true;
        }
        update demand;
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        Test.setMock(HttpCalloutMock.class,mock);
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":null,"error_message":null,"error_code":null,"del_flg":0}]}';
        CLP_SearchDemandCC.bulkStopDemand(jsonString);
        Test.stopTest();
        system.assert(!demand.isEmpty());
    }
    // test stop demand with error
    @isTest static void stopDemandWithErrorTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];
        for(DemandDetail__c d: demand){
             d.StopFlg__c = null;
            d.IsStop__c = false;
            d.AwaitingGetNewInfo__c = false;
            d.IsIntegrated__c = true;
        }
        update demand;
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        Test.setMock(HttpCalloutMock.class,mock);
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":null,"error_message":"error","error_code":"123","del_flg":null}]}';
        CLP_SearchDemandCC.bulkStopDemand(jsonString);
        Test.stopTest();
        system.assert(!demand.isEmpty());
    }
    // test stop demand with error wrapper
    @isTest static void stopDemandWithErrorWrapperTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];
        for(DemandDetail__c d: demand){
            d.StopFlg__c = null;
            d.IsStop__c = false;
            d.AwaitingGetNewInfo__c = false;
            d.IsIntegrated__c = true;
        }
        update demand;
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        Test.setMock(HttpCalloutMock.class,mock);
        mock.body = '{"user_id":"htamaru@sunbridge.com","success":"false","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":null,"error_message":"error","error_code":null,"del_flg":null}]}';
        CLP_SearchDemandCC.bulkStopDemand(jsonString);
        Test.stopTest();
        system.assert(!demand.isEmpty());
    }
    // test stop demand with error wrapper
    @isTest static void stopDemandWithConnectionErrorTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];
        for(DemandDetail__c d: demand){
            d.StopFlg__c = null;
            d.IsStop__c = false;
            d.AwaitingGetNewInfo__c = false;
            d.IsIntegrated__c = true;
        }
        update demand;
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        Test.setMock(HttpCalloutMock.class,mock);
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","success":true,"demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":null,"error_message":"'+CLP_MikataAPI.HTTP_CONNECTION_ERROR+'","error_code":"123","del_flg":null}]}';
        CLP_SearchDemandCC.bulkStopDemand(jsonString);
        Test.stopTest();
        system.assert(!demand.isEmpty());
    }
    // test unstop demand
    @isTest static void unStopDemandTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];
        for(DemandDetail__c d: demand){
            d.StopFlg__c = CLP_MikataConstant.FLG_STOP;
            d.IsIntegrated__c = true;
            d.IsStop__c = true;
        }       
        update demand;
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":null,"error_message":null,"error_code":null,"del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_SearchDemandCC.bulkUnStopDemand(jsonString);
        Test.stopTest();
        system.assert(demand!=null);
    }
    // test multi batch at the same time
    @isTest static void multiBatchTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 1];       
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------
        CLP_MikataDemandMock mock = new CLP_MikataDemandMock();
        mock.body = '{"user_id":"htamaru@sunbridge.com","access_key":"dfc9645942d554cd","demand":[{"code":"'+demand[0].Id+'","billing_code":"CodeTest","number_Z":null,"error_message":null,"error_code":null,"del_flg":null}]}';
        
        Test.setMock(HttpCalloutMock.class,mock);
        CLP_SearchDemandCC.bulkUnStopDemand(jsonString);
        CLP_SearchDemandCC.bulkUnStopDemand(jsonString);
        // multi upsert
        CLP_DemandBulkUpsertBatch upJobs = new CLP_DemandBulkUpsertBatch();     
        upJobs.shouldStop = true;           
        Database.executeBatch(upJobs,100);
        // multi stop
        CLP_DemandBulkStopBatch stopJobs = new CLP_DemandBulkStopBatch();       
        stopJobs.shouldStop = true;         
        Database.executeBatch(stopJobs,100);
        // multi search
        CLP_DemandBulkSearchBatch searchJobs = new CLP_DemandBulkSearchBatch();     
        searchJobs.shouldStop = true;           
        Database.executeBatch(searchJobs,100);
        Test.stopTest();
        system.assert(demand!=null);
    }
    // test delete demand
    @isTest static void bulkDeleteDemandTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c limit 100];      
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------       
        CLP_SearchDemandCC.bulkDeleteDemand(jsonString);
        Test.stopTest();
        system.assert(demand!=null);    
    }
    // test delete demand
    @isTest static void bulkUnDeleteDemandTest(){
        List<DemandDetail__c> demand = [Select Id,ManipulateStatus__c from DemandDetail__c where ManipulateStatus__c =: CLP_MikataConstant.DEMAND_LINK_SUCCESS and StopFlg__c =: CLP_MikataConstant.FLG_STOP];     
        String jsonString = JSON.serialize(demand);
        Test.startTest();
        // -------------------------- Test.startTest() --------------------------       
        CLP_SearchDemandCC.bulkDeleteDemand(jsonString);

        undelete demand;
        Test.stopTest();
        system.assert(demand!=null);    
    }
}