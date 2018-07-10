global class CLP_ProductDeleteBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global CLP_ProductDeleteBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}