// tam test 1
trigger CLP_AccountTrigger on Account (before delete,after undelete) {
	if(Trigger.isDelete){
		if(Trigger.isBefore){
			CLP_AccountTriggerHanlder.beforeDeleteAccount(Trigger.oldMap);
		}
	}else if(Trigger.isUnDelete){
		if(Trigger.isAfter){
			CLP_CommonUtil.restoreData(Trigger.new,CLP_MikataConstant.SOBJECT_ACCOUNT);
		}
	}
}