public with sharing class CLP_ProductTriggerHandler {
	public CLP_ProductTriggerHandler() {
		
	}

	public static void beforeDeleteProduct(Map<Id, Product2> mapProducts) {
		try {
			// Update record product StopFlg__c = 1, ManipulateStatus__c = DEMAND_LINK_SUCCESS before move to recycle bin 
			List<Product2> listPrd = new List<Product2>();
			for (Product2 prdDeleted : [SELECT Id, IsIntegrated__c, IsStop__c, Item_Code__c, StopFlg__c  
				                 		FROM Product2
				                 		WHERE Id IN :mapProducts.keySet()]) {
				
				if (prdDeleted.IsIntegrated__c && !prdDeleted.IsStop__c) {
					mapProducts.get(prdDeleted.Id).addError('エラー203:停止されていないため、削除できません。');

				} else if (prdDeleted.IsIntegrated__c && prdDeleted.IsStop__c && prdDeleted.StopFlg__c == CLP_MikataConstant.FLG_STOP) {
					Product2 prd = new Product2();
					prd.Id = prdDeleted.Id;
					prd.StopFlg__c = CLP_MikataConstant.FLG_DELETE;
					prd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_SUCCESS;
					prd.Item_Code__c = prdDeleted.Item_Code__c;
					listPrd.add(prd);
				}
			}
			
			// update listPrd
			if (listPrd != null && !listPrd.isEmpty()){
				String[] listField = new String[]{'StopFlg__c', 'ManipulateStatus__c', 'Item_Code__c'};
	            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
	               && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PRODUCT, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){                
	                upsert listPrd;
	            }
			}

			// create object buffer base on listPrd
			if (listPrd != null & !listPrd.isEmpty()) {
				List<MikataInteBuffer__c> buffers = new List<MikataInteBuffer__c>();
				for (Product2 prd : listPrd){
					MikataInteBuffer__c bf = new MikataInteBuffer__c();
					bf.RecordCode__c = prd.Item_Code__c;
					bf.SObjectType__c = CLP_MikataConstant.SOBJECT_PRODUCT;
	      			bf.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
	      			buffers.add(bf);
				}

				// insert buffer object
	            String[] listField = new String[]{'RecordCode__c', 'SObjectType__c', 'ManipulateStatus__c'};
	            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
	               && CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){                
	                insert buffers;
	            }
			}

			// call batch delete products
			Id jobId = CLP_ProductBulkDeleteBatch.startBatch(true);
	       	if (jobId == null){
	       		system.debug('CLP_ProductTriggerHandler.beforeDeleteProduct.jobId is NULL');
	       	}

	    } catch (Exception ex){
	    	system.debug('CLP_ProductTriggerHandler.beforeDeleteProduct.ex= ' + ex.getMessage());
	    }			
	}
}