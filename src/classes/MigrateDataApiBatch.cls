global with sharing class MigrateDataApiBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	// WRAPPER DATA FROM 3RD JSON STRING
	global API_Wrapper wrapper;
	// LIST DATA WANNA SYNC
	global List<contact> updateList;
	global MigrateDataApiBatch() {
		updateList = new List<contact>();
		// GET DATA FROM 3RD API
		//wrapper = getDataFromAPI();
	}
	// GET DATA FROM API AND SYNC TO SFDC
	global List<contact> start(Database.BatchableContext BC) {
		Map<String,API_Wrapper> mapApiWrappers = new Map<String,API_Wrapper>();
		return [Select id,email,lastname,firstname from Contact Limit 10000];
	}
	// MAP DATA
	global void execute(Database.BatchableContext BC,List<contact> scope){
	}
	// Finish SYNC DATA TO SFDC 
	global void finish(Database.BatchableContext BC){
	}
}