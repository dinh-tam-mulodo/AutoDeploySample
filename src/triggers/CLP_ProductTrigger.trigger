trigger CLP_ProductTrigger on Product2 (before delete, after undelete) {
	if (Trigger.isDelete) {
		if (Trigger.isBefore) {
			CLP_ProductTriggerHandler.beforeDeleteProduct(Trigger.oldMap);
		}
	} else if (Trigger.isUndelete) {
		if (Trigger.isAfter) {
			CLP_CommonUtil.restoreData(Trigger.new, CLP_MikataConstant.SOBJECT_PRODUCT);
		}	
	}
}