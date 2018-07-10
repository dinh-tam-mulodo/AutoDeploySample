@isTest
private class MF_ListViewObjectCCTest {
	@testSetup static void setup() {
        Account acc = MF_DummyDataMaker.createAccounts( 1 )[0];
    	//Insert 50 test external contacts, 1 internal contact
	    MF_DummyDataMaker.createContacts( acc, 50, true );
	    MF_DummyDataMaker.createMFDisplay();
    }

    @isTest static void testGetListSObject() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":2,"perPage":"5"}';
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.getListExternalContact(condition, 'contact').externalList;
	    Test.stopTest();
	    System.assertEquals( 5, contacts.size(), 'Contact list size should match amount of records per page' );
	}

	@isTest static void testGetListSObjectInvalidSName() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":2,"perPage":"5"}';
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.getListExternalContact(condition, 'dfgfdgdfg').externalList;
	    Test.stopTest();
	    System.assertEquals( 0, contacts.size(), 'Contact list size should equal 0 beause of invalid SObject name' );
	}

	@isTest static void testGetListSObjectWrongJson() {
		String condition = '{"abcxhyz":"Name"}';
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.getListExternalContact(condition, 'contact').externalList;
	    Test.stopTest();
	    System.assertEquals( 51, contacts.size(), 'Contact list size should match amount of created test records size' );
	}

	@isTest static void testGetListSObjectInvalidJson() {
		String condition = '';
		Test.startTest();
	    MF_ListSObject contacts = MF_ListViewObjectCC.getListExternalContact(condition, 'contact');
	    Test.stopTest();
	    System.assertEquals( null, contacts, 'Contact list size should be null' );
	}

	@isTest static void testGetListSObjectOverPage() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":100,"perPage":"5"}';
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.getListExternalContact(condition, 'contact').externalList;
	    Test.stopTest();
	    System.assertEquals( 0, contacts.size(), 'Contact list size should be 0 because max page is 10 if record per page is 5' );
	}

	@isTest static void testGetListSObjectOverRecord() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":1,"perPage":"500"}';
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.getListExternalContact(condition, 'contact').externalList;
	    Test.stopTest();
	    System.assertEquals( 51, contacts.size(), 'Contact list size should be 51 because total records are 51' );
	}

	@isTest static void testMassDeleteMultiRecords() {
		List<Contact> conLst = [Select Id From Contact Limit 5];
		List<String> recordsList = new List<String>();
		for(Contact con:conLst){
			recordsList.add(con.Id);
		}
		Test.startTest();
	    Integer delRows = MF_ListViewObjectCC.massDeleteRecords(recordsList, 'Contact');
	    Test.stopTest();
	    System.assert(delRows == 5, 'Number of rows deleted size should be equal 5 because record list has 5 valid Id' );
	}

	@isTest static void testMassDeleteNoRecord() {
		List<String> recordsList = new List<String>();
		Test.startTest();
	    Integer delRows = MF_ListViewObjectCC.massDeleteRecords(recordsList, 'contact');
	    Test.stopTest();
	    System.assert(delRows == 0, 'Number of rows deleted size should be equal 0 because record list is empty' );
	}

	@isTest static void testMassDeleteInvalidId() {
		List<String> recordsList = new List<String>{'dfgdfg'};
		Test.startTest();
	    Integer delRows = MF_ListViewObjectCC.massDeleteRecords(recordsList, 'contact');
	    Test.stopTest();
	    System.assert(delRows == 0, 'Number of rows deleted size should be equal 0 because contact id is invalid' );
	}

	@isTest static void testMassDelete1Record() {
		Contact con = [Select Id From Contact Limit 1];
		List<String> recordsList = new List<String>{con.Id};
		Test.startTest();
	    Integer delRows = MF_ListViewObjectCC.massDeleteRecords(recordsList, 'contact');
	    Test.stopTest();
	    System.assert(delRows == 1, 'Number of rows deleted size should be equal 1 because record list has 1 valid Id' );
	}

	@isTest static void testMassDeleteInvalidSName() {
		Contact con = [Select Id From Contact Limit 1];
		List<String> recordsList = new List<String>{con.Id};
		Test.startTest();
	    Integer delRows = MF_ListViewObjectCC.massDeleteRecords(recordsList, 'gfdgdf');
	    Test.stopTest();
	    System.assert(delRows == 0, 'Number of rows deleted size should be equal 0 because of invalid SObject name' );
	}

	@isTest static void testGetFieldsOfSObject() {
		Map<String, Schema.SObjectField> fsMap = Schema.getGlobalDescribe().get('contact').getDescribe().fields.getMap();
		Test.startTest();
	    List<FieldDisplayObject> fieldLst = MF_ListViewObjectCC.getListFields('contact');
	    Test.stopTest();
	    System.assert(fsMap.size() == fieldLst.size(), 'Number of SObject fields should equal' );
	}

	@isTest static void testGetFieldsOfSObjectInvalid() {
		Test.startTest();
	    List<FieldDisplayObject> fieldLst = MF_ListViewObjectCC.getListFields('abcxyzfedg');
	    Test.stopTest();
	    System.assert(fieldLst.size() == 0, 'Number of SObject fields should equal 0 because of invalid sobject name' );
	}

	@isTest static void testSaveFieldsAndGetSObjectList() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":1,"perPage":"5"}';
		List<String> fieldList = new List<String>{'Contact_Type__c','AccountId'};
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.saveDisplayFieldsAndGetExternalContact(condition,fieldList,'contact').externalList;
	    Test.stopTest();
	    SObject conn;
	    Map<String, Object> m = new Map<String, Object>();
	    if(contacts.size() > 0)
	    {
	    	conn = contacts[0];
	    	m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(conn));
	    }
	    System.assert(contacts.size() == 5, 'Number of SObject records should equal 5 because of perPage=5' );	    
	    System.assertEquals(true, m.get(String.valueOf(Contact.Contact_Type__c)) != null);
	    System.assertEquals(true, m.get(String.valueOf(Contact.AccountId)) != null);
	    System.assertEquals(false, m.get(String.valueOf(Contact.Name)) != null);
	}

	@isTest static void testSaveFieldsAndGetSObjectListInvalidField() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":1,"perPage":"5"}';
		List<String> fieldList = new List<String>{'ffggfhf'};
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.saveDisplayFieldsAndGetExternalContact(condition,fieldList,'contact').externalList;
	    Test.stopTest();
	    SObject conn;
	    Map<String, Object> m = new Map<String, Object>();
	    System.assert(contacts.size() == 0, 'Number of SObject records should equal 0 because of invalid field name' );
	}

	@isTest static void testSaveFieldsAndGetSObjectListEmptyField() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":1,"perPage":"5"}';
		List<String> fieldList = new List<String>();
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.saveDisplayFieldsAndGetExternalContact(condition,fieldList,'contact').externalList;
	    Test.stopTest();
	    SObject conn;
	    Map<String, Object> m = new Map<String, Object>();
	    if(contacts.size() > 0)
	    {
	    	conn = contacts[0];
	    	m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(conn));
	    }
	    System.assert(contacts.size() == 5, 'Number of SObject records should equal 5 because of perPage=5' );	    
	    System.assertEquals(true, m.get(String.valueOf(Contact.Name)) != null);
	    System.assertEquals(true, m.get(String.valueOf(Contact.Id)) != null);
	}

	@isTest static void testSaveFieldsAndGetSObjectListInvalidSName() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":1,"perPage":"5"}';
		List<String> fieldList = new List<String>{'Contact_Type__c','AccountId'};
		Test.startTest();
	    List<SObject> contacts = MF_ListViewObjectCC.saveDisplayFieldsAndGetExternalContact(condition,fieldList,'fdgfdgdf').externalList;
	    Test.stopTest();
	    System.assert(contacts.size() == 0, 'Number of SObject records should equal 0 because of invalid sname' );	 
	}
	
}