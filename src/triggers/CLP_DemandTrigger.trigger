trigger CLP_DemandTrigger on DemandDetail__c (before delete,after undelete) {
    if(Trigger.isDelete){
        if(Trigger.isBefore){
        	// reset record
            CLP_DemandTriggerHandler.beforeDeleteDemand(Trigger.oldMap);
            //update flag
            CLP_DemandTriggerHandler.updateFlag(Trigger.old);
        }
    }else if(Trigger.isUnDelete){
        if(Trigger.isAfter){
            //CLP_CommonUtil.restoreData(Trigger.new,CLP_MikataConstant.SOBJECT_DEMAND_DETAIL);
        }
    }
}