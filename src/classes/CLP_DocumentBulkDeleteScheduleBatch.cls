global class CLP_DocumentBulkDeleteScheduleBatch implements Schedulable  {
	
	global CLP_DocumentBulkDeleteScheduleBatch() { }

	global void execute(SchedulableContext SC) {
		List<Document> docs = [SELECT Id FROM Document WHERE Folder.DeveloperName = 'FolderCustomLog'];
		if (docs != null && !docs.isEmpty()) {
			if (Document.sObjectType.getDescribe().isDeletable()) {	
				delete docs;
			}
		}
   	}
}