trigger CLP_PaymentMethodTrigger on PaymentMethod__c (before delete, after undelete) {
	if (Trigger.isDelete) {
		if (Trigger.isBefore) {
			CLP_PaymentMethodTriggerHandler.beforeDeletePaymentMethod(Trigger.oldMap);
		}
	} else if (Trigger.isUndelete) {
		if (Trigger.isAfter) {
			CLP_CommonUtil.restoreData(Trigger.new, CLP_MikataConstant.SOBJECT_PAYMENT_METHOD);
		}	
	}
}