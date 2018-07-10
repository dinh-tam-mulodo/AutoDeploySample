global class CLP_DemandBulkEmptyRecycleBinBatch 
    implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts { 
    global String router;

    
    global CLP_DemandBulkEmptyRecycleBinBatch() {
    }

    public static Id startBatch(Boolean checkRunning,String router){
        if (checkRunning){
            List<AsyncApexJob> aajList = [SELECT Id FROM AsyncApexJob WHERE CompletedDate = NULL AND JobType = 'BatchApex'
                                          AND ApexClass.Name = 'CLP_DemandBulkEmptyRecycleBinBatch'
                                          AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing' OR Status = 'Holding')
                                          LIMIT 1];                          
            if (aajList.size() != 0) { return null ;}
        }
        CLP_DemandBulkEmptyRecycleBinBatch processor = new CLP_DemandBulkEmptyRecycleBinBatch();
        processor.router = router; 
        return Database.executeBatch(processor, Integer.valueOf(Label.CLP_BatchSizeLabel));
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(router == CLP_MikataConstant.SOBJECT_ACCOUNT){
            return Database.getQueryLocator([Select Id from DemandDetail__c 
                Where Account__c = null]);
        }else {
            return Database.getQueryLocator([Select Id from DemandDetail__c 
                Where Seikyuusakibusho__c = null]);
        }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<DemandDetail__c> demandList = (List<DemandDetail__c>) scope;       
        // delete related demand detail record
        if(!demandList.isEmpty()){
            if (DemandDetail__c.sObjectType.getDescribe().isDeletable()) {            
                delete demandList;
                Database.emptyRecycleBin(demandList);               
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }   
}