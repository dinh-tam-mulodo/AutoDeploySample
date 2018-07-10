public with sharing class TestMapCC {
	public Account acc {get; set;}

	public TestMapCC() {
		String accId = ApexPages.currentPage().getParameters().get('id');
		if (String.isNotBlank(accId)) {
			List<Account> accs = [Select Id, Name, BillingStreet, BillingCity, BillingState, 
								  	(Select Id, Name, Lastname, Firstname, MailingStreet, MailingCity, MailingState From Contacts Order By Lastname asc)
								  From Account Where Id = :accId];
		  	if (!accs.isEmpty()) {
		  		this.acc = accs[0];
		  	}
		}
	}
}