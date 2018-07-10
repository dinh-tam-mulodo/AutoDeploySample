trigger CLP_BillTrigger on Bill__c (before delete, after undelete) {
	if (Trigger.isDelete) {
		if (Trigger.isBefore) {
			CLP_BillTriggerHandler.beforeDeleteBill(Trigger.oldMap);
		}
	} else if (Trigger.isUndelete) {
		if (Trigger.isAfter) {
			CLP_CommonUtil.restoreData(Trigger.new, CLP_MikataConstant.SOBJECT_BILL);
		}	
	}
}