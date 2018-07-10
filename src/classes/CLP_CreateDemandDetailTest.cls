@isTest
public with sharing class CLP_CreateDemandDetailTest {
    @isTest
    static void createDemandDetailTest(){
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
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prd.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        Opportunity opp = new Opportunity(  Name = 'opp'
                                          , StageName= 'Prospecting'
                                          , CloseDate = Date.today()
                                          , AccountId = acc.Id
                                          , PaymentMethodId__c = pay.Id
                                          , Seikyuusakibusho__c = sei.Id);
        insert opp;

        OpportunityLineItem oppline = new OpportunityLineItem(OpportunityId = opp.Id
                                                            ,Quantity = 1
                                                            ,TotalPrice = 1
                                                            ,PricebookEntryId = standardPrice.Id);
        insert oppline;

        CLP_CreatingDemandDetail.createDemandDetail(opp.Id);

        system.assert(opp!=null);
    }
}