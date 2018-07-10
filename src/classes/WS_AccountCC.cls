global with sharing class WS_AccountCC {
	@RemoteAction
	global static Account[] getAccts(){
		return [Select Id,Name,Phone,Fax From Account];
	}
	@RemoteAction
	global static Account[] addAccount(String accName){
		Account acc = new Account();
		acc.Name = accName;
		insert acc;

		return [Select Id,Name,Phone,Fax From Account];
	}

	@RemoteAction
	global static Account[] deleteAccount(String accId){
		Account acc = [Select Id From Account Where Id=: accId];
		delete acc;
		return [Select Id,Name,Phone,Fax From Account];
	}
}