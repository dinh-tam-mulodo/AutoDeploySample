global with sharing class CLP_BulkBufferClearScheduleBatch implements Schedulable  {
	
	global CLP_BulkBufferClearScheduleBatch() { }
	
	global void execute(SchedulableContext SC) {
		// select all buffers that handle negative response from Mikata
		List<MikataInteBuffer__c> failedBufs = new List<MikataInteBuffer__c>();
		for (MikataInteBuffer__c buf : ([SELECT Id, ManipulateStatus__c 
								  		 FROM MikataInteBuffer__c
								  		 WHERE ManipulateStatus__c =: CLP_MikataConstant.DEMAND_FAILED_DATA_DEFECT
								  		 OR ManipulateStatus__c =: CLP_MikataConstant.DEMAND_FAILED_INTERFACE])) {
			buf.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
			failedBufs.add(buf);
		}

		// Reset awaiting status
		if (failedBufs != null && !failedBufs.isEmpty()) {
			String[] listField = new String[]{'ManipulateStatus__c'};	
			if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)) {
                update failedBufs;
            }
		}

		// Call all batch to delete buffer again
		CLP_AccountBillingBulkDeleteBatch.startBatch(true);
		CLP_BillingIndividualBulkDeleteBatch.startBatch(true);
		CLP_PaymentMethodBulkDeleteBatch.startBatch(true);
		CLP_ProductBulkDeleteBatch.startBatch(true);
   	}
}