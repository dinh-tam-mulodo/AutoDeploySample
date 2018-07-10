@isTest
public with sharing class CLP_DemandBulkEmptyRecycleBinBatchTest {
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
        
        upsert demandList;
    }
    @isTest static void deleteDemandWhenDeleteSeikyuusakibushoAccountTest(){
        List<Seikyusakibusho__c> billings = [Select Id from Seikyusakibusho__c limit 2];
        for(Seikyusakibusho__c b : billings){
            b.IsIntegrated__c = false;
        }
        upsert billings;

        Database.DeleteResult[] rs = Database.delete(billings);
        system.assert(rs[0].isSuccess());
    }
    @isTest static void deleteDemandWhenDeleteAccountTest(){
        List<Account> accs = [Select Id from Account limit 2];
        for(Account a: accs){
            a.IsIntegrated__c = false;
        }
        upsert accs;
        
        Database.DeleteResult[] rs = Database.delete(accs);
        system.assert(rs[0].isSuccess());
    }
}