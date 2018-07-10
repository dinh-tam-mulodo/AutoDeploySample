public with sharing class CLP_BillTriggerHandler {
	public CLP_BillTriggerHandler() {
		
	}

	public static void beforeDeleteBill(Map<Id, Bill__c> mapBills) {
		// Update record payment method StopFlg__c = 1, ManipulateStatus__c = DEMAND_LINK_SUCCESS before move to recycle bin 
		List<Bill__c> listBillDeleted = new List<Bill__c>();
		for (Bill__c billDeleted : [SELECT Id, IsIntegrated__c, IsStop__c, StopFlg__c, AccountId__c, number__c	  
                 					FROM Bill__c
	                 				WHERE Id IN :mapBills.keySet()]) {
				
			if (billDeleted.IsIntegrated__c && !billDeleted.IsStop__c) {
				mapBills.get(billDeleted.Id).addError('エラー203:停止されていないため、削除できません。');

		    } else if (billDeleted.IsIntegrated__c && billDeleted.IsStop__c && billDeleted.StopFlg__c == CLP_MikataConstant.FLG_STOP) {
				Bill__c bi = new Bill__c(AccountId__c = billDeleted.AccountId__c);
				bi.Id = billDeleted.Id;
				bi.StopFlg__c = CLP_MikataConstant.FLG_DELETE;
				bi.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
				bi.number__c = billDeleted.number__c;
				listBillDeleted.add(bi);
			}
		}

		// update listPayMet
		if (listBillDeleted != null && !listBillDeleted.isEmpty()){
			String[] listField = new String[]{'StopFlg__c', 'ManipulateStatus__c', 'number__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
               && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){                
                upsert listBillDeleted;
            }
		}
	}
}