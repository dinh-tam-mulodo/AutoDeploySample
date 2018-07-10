trigger CLP_SeikyusakibushoTrigger on Seikyusakibusho__c (before delete,after undelete) {
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            CLP_SeikyusakibushoTriggerHandler.beforeDeleteDemand(Trigger.oldMap);
        }
    }else if(Trigger.isUnDelete){
        if(Trigger.isAfter){
            CLP_CommonUtil.restoreData(Trigger.new,CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL);
        }
    }
}