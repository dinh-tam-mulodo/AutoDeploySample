public with sharing class CLP_PaymentMethodTriggerHandler {
	public CLP_PaymentMethodTriggerHandler() {
		
	}

	public static void beforeDeletePaymentMethod (Map<Id, PaymentMethod__c> mapPayMets) {
		try {
			// Update record payment method StopFlg__c = 1, ManipulateStatus__c = DEMAND_LINK_SUCCESS before move to recycle bin 
			List<PaymentMethod__c> listPayMet = new List<PaymentMethod__c>();
			for (PaymentMethod__c pmDeleted : [SELECT Id, IsIntegrated__c, IsStop__c, PaymentMethodCode__c, StopFlg__c, AccountId__c, AccountId__r.IsStop__c,
			 									(SELECT Id, IsIntegrated__c, IsStop__c From demand_detail__r)	  
				                 				FROM PaymentMethod__c
				                 				WHERE Id IN :mapPayMets.keySet()]) {
				
				if (pmDeleted.IsIntegrated__c && !pmDeleted.IsStop__c) {
					mapPayMets.get(pmDeleted.Id).addError('エラー203:停止されていないため、削除できません。');

			    } else if (pmDeleted.IsIntegrated__c && pmDeleted.IsStop__c) {
			    	Boolean isCheckDemandDetailOK = checkRelatedDemandDetailToDelete(pmDeleted);
			    	if (isCheckDemandDetailOK) {
						PaymentMethod__c pm = new PaymentMethod__c(AccountId__c = pmDeleted.AccountId__c);
						pm.Id = pmDeleted.Id;
						pm.StopFlg__c = CLP_MikataConstant.FLG_DELETE;
						pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
						pm.PaymentMethodCode__c = pmDeleted.PaymentMethodCode__c;
						listPayMet.add(pm);
		    		
		    		} else {
		    			mapPayMets.get(pmDeleted.Id).addError('エラー303:この決済手段は使用中です。');
		    		} 
				}
			}
			
			// update listPayMet
			if (listPayMet != null && !listPayMet.isEmpty()){
				String[] listField = new String[]{'StopFlg__c', 'ManipulateStatus__c', 'PaymentMethodCode__c'};
	            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
	               && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){                
	                upsert listPayMet;
	            }
			}

			// create object buffer base on listPayMet
			if (listPayMet != null & !listPayMet.isEmpty()) {
				List<MikataInteBuffer__c> buffers = new List<MikataInteBuffer__c>();
				for (PaymentMethod__c pm : listPayMet){
					MikataInteBuffer__c bf = new MikataInteBuffer__c();
					bf.RecordCode__c = pm.PaymentMethodCode__c;
					bf.SObjectType__c = CLP_MikataConstant.SOBJECT_PAYMENT_METHOD;
	      			bf.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
	      			bf.AccountId__c = pm.AccountId__c;
	      			buffers.add(bf);
				}

				// insert buffer object
	            String[] listField = new String[]{'RecordCode__c', 'SObjectType__c', 'ManipulateStatus__c', 'AccountId__c'};
	            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
	               && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){                
	                insert buffers;
	            }
			}
			
			// call batch delete payment method
			Id jobId = null;
			jobId = CLP_PaymentMethodBulkDeleteBatch.startBatch(true);
	       	if (jobId == null){
	       		system.debug('CLP_PaymentMethodTriggerHandler.beforeDeletePaymentMethod.jobId is NULL');
	       	}

	    } catch (Exception ex){
	    	system.debug('CLP_PaymentMethodTriggerHandler.beforeDeletePaymentMethod.ex= ' + ex.getMessage());
	    }
	}

	private static Boolean checkRelatedDemandDetailToDelete(PaymentMethod__c pmDeleted) {
		Boolean isOk = true;
		List<DemandDetail__c> ddList =  pmDeleted.demand_detail__r;
		system.debug('@@@@checkRelatedDemandDetailToDelete.ddList= ' + ddList);

		// payment method has zero demandDetail linked
		if (ddList == null || ddList.isEmpty()) {
			return isOk;		// still = true
		
		// The related demandDetail of payment method must be stopped ALL
		} else {
			for (DemandDetail__c dd : ddList) {
				if (dd.IsIntegrated__c && !dd.IsStop__c) {
					isOk = false;
					break;	
				} 
			}
			return isOk;
		}					
	}
}