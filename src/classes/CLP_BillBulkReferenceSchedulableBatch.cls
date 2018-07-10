global with sharing class CLP_BillBulkReferenceSchedulableBatch implements Schedulable  {
	
	global CLP_BillBulkReferenceSchedulableBatch() {
		
	}
	
	global void execute(SchedulableContext SC) {
		Date lastRefDate = setLastReferenceDate();      
        List<LastReference__c> lastRefList = [SELECT Id, LastModifiedById, LastReferenceDate__c FROM LastReference__c];

        // LastReference__c object must exist only one record
        if (lastRefList == null || lastRefList.isEmpty()) {
            // Create new last reference record
            LastReference__c newLastRef = new LastReference__c();
            newLastRef.LastReferenceDate__c = lastRefDate;
            String[] listField = new String[] {'LastReferenceDate__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
            && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)) {             
                Savepoint sp;
                if (!Test.isRunningTest()) {
                    sp = Database.setSavepoint();    
                }
                try {
                    insert newLastRef;  
                    
                } catch (DmlException dmlEx) {
                    if (!Test.isRunningTest()) {
                        Database.rollback(sp);
                    }
                    throw dmlEx;
                }   
            }  
            
        } else {
            LastReference__c lastRef = lastRefList.get(0);
            if (lastRef.LastReferenceDate__c == null) {
                lastRef.LastReferenceDate__c = lastRefDate; 
                String[] listField = new String[] {'LastReferenceDate__c'};
                if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
                && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_LAST_REFERENCE, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)) {             
                    Savepoint sp;
                    if (!Test.isRunningTest()) {
                        sp = Database.setSavepoint();    
                    }
                    try {
                        update lastRefList; 
                        
                    } catch (DmlException dmlEx) {
                        if (!Test.isRunningTest()) {
                            Database.rollback(sp);
                        }
                        throw dmlEx;
                    }    
                } 
            }
        }

		String billNumber = '';
		Integer indexPage = 0;
      	CLP_BillBulkReferenceMikataBatch.startBatch(true, billNumber, indexPage);
    }
    
    private static Date setLastReferenceDate() {
        return Date.today();
    }
}