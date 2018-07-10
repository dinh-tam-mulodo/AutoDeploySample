@isTest
private class MF_InternalContactCCTest {

    @testSetup static void setup() {
        MF_DummyDataMaker.createDummyData();
    }
    
    @isTest static void constructorTest() {
        Contact contactInfo = [ SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
        ApexPages.currentPage().getParameters().put('contactId', contactInfo.Id);
        MF_InternalContactCC mfInternal = new MF_InternalContactCC();
    }
    @isTest static void constructorCookieIsNullTest() {
        //Contact contactInfo = [ SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
        //ApexPages.currentPage().getParameters().put('contactId', contactInfo.Id);
        MF_InternalContactCC mfInternal = new MF_InternalContactCC();
    }

    @isTest static void getInfoOfContactTest() {
        Contact contactCond = [ SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
        Contact contactTest = MF_InternalContactCC.getInfoOfContact(contactCond.Id);
    }
    @isTest static void getCompanyInfoTest() {
        MF_Company__c company = [ SELECT Id, Name FROM MF_Company__c ORDER BY CreatedDate DESC LIMIT 1];
        List<MF_CompanysObject> companyDetail = MF_InternalContactCC.getCompanyInfo(company.Id);
    }
    @isTest static void getListInternalContact() {
        MF_Company__c company = [ SELECT Id, Name FROM MF_Company__c ORDER BY CreatedDate DESC LIMIT 1];
        MF_Branch__c branch = [ SELECT Id, Name FROM MF_Branch__c ORDER BY CreatedDate DESC LIMIT 1];
        MF_Department__c dept = [ SELECT Id, Name FROM MF_Department__c WHERE ParentId__c = '' ORDER BY CreatedDate DESC LIMIT 1];
        MF_Department__c child = [ SELECT Id, Name FROM MF_Department__c WHERE ParentId__c != '' ORDER BY CreatedDate DESC LIMIT 1];
        MF_InternalContactSearchObject cond = new MF_InternalContactSearchObject();
        cond.currentPage = 1;
        cond.perPage = 10;
        cond.sortBy = 'Name';
        cond.sortOrder = 'DESC';
        String condJson = JSON.serialize(cond);
        MF_InternalContactListObject contactList = MF_InternalContactCC.getListInternalContact(condJson);
        // search with company condition
        cond.company = company.Id;
        condJson = JSON.serialize(cond);
        contactList = MF_InternalContactCC.getListInternalContact(condJson);
        // search with branch condition
        cond.branch = branch.Id;
        condJson = JSON.serialize(cond);
        contactList = MF_InternalContactCC.getListInternalContact(condJson);
        // search with department condition
        cond.dept = dept.Id;
        condJson = JSON.serialize(cond);
        contactList = MF_InternalContactCC.getListInternalContact(condJson);
        // search with child department condtion
        cond.child = child.Id;
        condJson = JSON.serialize(cond);
        contactList = MF_InternalContactCC.getListInternalContact(condJson);
        // search with name keyword
        cond.kname = 'a';
        condJson = JSON.serialize(cond);
        contactList = MF_InternalContactCC.getListInternalContact(condJson);
        // search with department name keyword
        cond.kdept = 'a';
        condJson = JSON.serialize(cond);
        contactList = MF_InternalContactCC.getListInternalContact(condJson);
        // search with phone keyword
        cond.ktel = '9';
        condJson = JSON.serialize(cond);
        contactList = MF_InternalContactCC.getListInternalContact(condJson);
        // search with email keyword
        cond.kemail = 'vo.yen';
        condJson = JSON.serialize(cond);
        contactList = MF_InternalContactCC.getListInternalContact(condJson);
    }

    @isTest static void getDetailContactTest() {
        Contact contactCond = [ SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
        Contact info = MF_InternalContactCC.getDetailContact(contactCond.Id);
    }

    @isTest static void requiredUpdateProfileTest() {
        Contact contactCond = [ SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
        List <Id> contactId = new List <Id>();
        contactId.add(contactCond.Id);
        MF_InternalContactSearchObject cond = new MF_InternalContactSearchObject();
        cond.contactId = contactId;
        String condJson = JSON.serialize(cond);
        MF_InternalContactCC.requiredUpdateProfile(condJson);
    }

    @isTest static void logoutTest() {
        Contact contactInfo = [ SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
        ApexPages.currentPage().getParameters().put('contactId', contactInfo.Id);
        MF_InternalContactCC mfInternal = new MF_InternalContactCC();
        MF_UserAuthentication.logout();
    }

    @isTest static void userAuthenticationTest() {
        MF_UserAuthentication auth = new MF_UserAuthentication();
        auth.userAuthentication();
    }
    @isTest static void userAuthenticationHaveCookieTest() {
        Contact contactInfo = [ SELECT Id FROM Contact ORDER BY CreatedDate DESC LIMIT 1];
        ApexPages.currentPage().getParameters().put('contactId', contactInfo.Id);
        MF_InternalContactCC mfInternal = new MF_InternalContactCC();
        MF_UserAuthentication auth = new MF_UserAuthentication();
        auth.userAuthentication();
    }
}