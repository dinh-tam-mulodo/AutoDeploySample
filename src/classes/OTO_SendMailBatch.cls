global class OTO_SendMailBatch implements Database.Batchable<sObject> {

	public OTO_SendMailBatch() {
		
	}

	public List<SObject> prospects {get;set;} 

    global Iterable<sObject> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        prospects = OTO_Pardot.getAllProspect();
        system.debug(prospects);
        return null;
    }

    global void execute(Database.BatchableContext bc, List<sObject> records){
        // process each batch of records
       
    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

}