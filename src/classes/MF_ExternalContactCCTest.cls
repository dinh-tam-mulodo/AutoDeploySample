@isTest
private class MF_ExternalContactCCTest {
	@testSetup static void setup() {
        Account acc = MF_DummyDataMaker.createAccounts( 1 )[0];
    	//Insert 50 test external contacts, 1 internal contact
	    MF_DummyDataMaker.createContacts( acc, 50, true );
    }
	
	@isTest static void testGetListInternal() {
	    Test.startTest();
	    List<Contact> contacts = MF_ExternalContactCC.getListInternalContact();
	    Test.stopTest();
	    System.assertEquals( 1, contacts.size(), 'Contact list size should match amount of created test records size' );
	}
	
	@isTest static void testGetListExternal() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":2,"perPage":"5"}';
		Test.startTest();
	    List<Contact> contacts = MF_ExternalContactCC.getListExternalContact(condition).externalList;
	    Test.stopTest();
	    System.assertEquals( 5, contacts.size(), 'Contact list size should match amount of records per page' );
	}

	@isTest static void testGetListExternalWrongJson() {
		String condition = '{"abcxhyz":"Name"}';
		Test.startTest();
	    List<Contact> contacts = MF_ExternalContactCC.getListExternalContact(condition).externalList;
	    Test.stopTest();
	    System.assertEquals( 50, contacts.size(), 'Contact list size should match amount of created test records size' );
	}

	@isTest static void testGetListExternalInvalidJson() {
		String condition = '';
		Test.startTest();
	    MF_ExternalContactListObject contacts = MF_ExternalContactCC.getListExternalContact(condition);
	    Test.stopTest();
	    System.assertEquals( null, contacts, 'Contact list size should be null' );
	}

	@isTest static void testGetListExternalOverPage() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":100,"perPage":"5"}';
		Test.startTest();
	    List<Contact> contacts = MF_ExternalContactCC.getListExternalContact(condition).externalList;
	    Test.stopTest();
	    System.assertEquals( 0, contacts.size(), 'Contact list size should be 0 because max page is 10 if record per page is 5' );
	}

	@isTest static void testGetListExternalOverRecord() {
		String condition = '{"sortBy":"Name","sortOrder":"DESC","currentPage":1,"perPage":"500"}';
		Test.startTest();
	    List<Contact> contacts = MF_ExternalContactCC.getListExternalContact(condition).externalList;
	    Test.stopTest();
	    System.assertEquals( 50, contacts.size(), 'Contact list size should be 50 because total records are 50' );
	}

	@isTest static void testGetListExternalByContactId() {
		Contact contact = [Select Id From Contact Limit 1];
		String condition = '{"contactId":"'+contact.Id+'"}';
		Test.startTest();
	    List<Contact> contacts = MF_ExternalContactCC.getListExternalContact(condition).externalList;
	    Test.stopTest();
	    System.assertEquals( 50, contacts.size(), 'Contact list size should be 0 because max page is 10 if record per page is 5' );
	}

	@isTest static void testGetListExternalBySearchName() {
		String condition = '{"fullname":"John"}';
		Test.startTest();
	    List<Contact> contacts = MF_ExternalContactCC.getListExternalContact(condition).externalList;
	    Test.stopTest();
	    System.assert(contacts.size() > 0, 'Contact list size should be bigger than 0 because have many records have name like John' );
	}

	@isTest static void testGetListExternalBySearchCompany() {
		String condition = '{"comp":"Account"}';
		Test.startTest();
	    List<Contact> contacts = MF_ExternalContactCC.getListExternalContact(condition).externalList;
	    Test.stopTest();
	    System.assert(contacts.size() > 0, 'Contact list size should be bigger than 0 because have many records have account name like Account' );
	}

	@isTest static void testMassDeleteNoRecord() {
		List<String> recordsList = new List<String>();
		Test.startTest();
	    Integer delRows = MF_ExternalContactCC.massDeleteRecords(recordsList);
	    Test.stopTest();
	    System.assert(delRows == 0, 'Number of rows deleted size should be equal 0 because record list is empty' );
	}

	@isTest static void testMassDeleteInvalidId() {
		List<String> recordsList = new List<String>{'dfgdfg'};
		Test.startTest();
	    Integer delRows = MF_ExternalContactCC.massDeleteRecords(recordsList);
	    Test.stopTest();
	    System.assert(delRows == 0, 'Number of rows deleted size should be equal 0 because contact id is invalid' );
	}

	@isTest static void testMassDelete1Record() {
		Contact con = [Select Id From Contact Limit 1];
		List<String> recordsList = new List<String>{con.Id};
		Test.startTest();
	    Integer delRows = MF_ExternalContactCC.massDeleteRecords(recordsList);
	    Test.stopTest();
	    System.assert(delRows == 1, 'Number of rows deleted size should be equal 1 because record list has 1 valid Id' );
	}

	@isTest static void testMassDeleteMultiRecords() {
		List<Contact> conLst = [Select Id From Contact Limit 5];
		List<String> recordsList = new List<String>();
		for(Contact con:conLst){
			recordsList.add(con.Id);
		}
		Test.startTest();
	    Integer delRows = MF_ExternalContactCC.massDeleteRecords(recordsList);
	    Test.stopTest();
	    System.assert(delRows == 5, 'Number of rows deleted size should be equal 5 because record list has 5 valid Id' );
	}
	
}