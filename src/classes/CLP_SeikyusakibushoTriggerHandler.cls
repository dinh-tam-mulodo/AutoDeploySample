/**
 * CLP_SeikyusakibushoTriggerHandler.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_SeikyusakibushoTriggerHandler class
 */
public with sharing class CLP_SeikyusakibushoTriggerHandler {
	// before delete function
	public static void beforeDeleteDemand(Map<Id,Seikyusakibusho__c> triggerMaps){
		List<Seikyusakibusho__c> billIndividuals = new List<Seikyusakibusho__c>();
		
		List<Seikyusakibusho__c> recordDeleted = [Select Id,IsStop__c,billing_individual_number__c,Seikyusakimei__c,Seikyusakimei__r.IsStop__c,IsIntegrated__c,ManipulateStatus__c from Seikyusakibusho__c
							where Id in: triggerMaps.keyset()];
    		system.debug('recordDeleted:'+ recordDeleted );
		for(Seikyusakibusho__c sei : recordDeleted) {
			if(sei.IsIntegrated__c==true){
				if(sei.IsStop__c==false && sei.Seikyusakimei__r.IsStop__c==false)	{
					triggerMaps.get(sei.Id).addError('エラー203：停止されていないため、削除できません。');
				}else{
					billIndividuals.add(new Seikyusakibusho__c(Id=sei.Id,
										Seikyusakimei__c = sei.Seikyusakimei__c,
										billing_individual_number__c = sei.billing_individual_number__c,
	        							StopFlg__c = CLP_MikataConstant.FLG_DELETE,
	        							ManipulateStatus__c= CLP_MikataConstant.DEMAND_LINK_SUCCESS));
				}
			}
			
  		}
  		if(!billIndividuals.isEmpty())
  		{  			
        	// update deleted billIndividuals
	        String[] listFields = new String[]{'StopFlg__c','ManipulateStatus__c'};
	        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL,listFields, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
	              // update billIndividuals
	              update billIndividuals;
	        }
	        List<MikataInteBuffer__c> buffers = new List<MikataInteBuffer__c>();
	        // create buffer data
	        for(Seikyusakibusho__c bi : billIndividuals){
	        	MikataInteBuffer__c bf = new MikataInteBuffer__c();
	        	bf.RecordID__c = bi.Id;
	        	bf.RecordCode__c = bi.billing_individual_number__c;
	        	bf.AccountId__c = bi.Seikyusakimei__c;
	        	bf.SObjectType__c = CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL;
	        	bf.ManipulateStatus__c =  CLP_MikataConstant.DEMAND_LINK_AWAITING;
	        	buffers.add(bf);
	        }
	        String[] bufferFields = new String[]{'RecordID__c','RecordCode__c','AccountId__c','SObjectType__c','ManipulateStatus__c'};
	        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BUFFER,bufferFields, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
	              // insert buffer
	              insert buffers;
	        }
  		}

  		// start batch delete
  		Id jobId = CLP_BillingIndividualBulkDeleteBatch.startBatch(true);
	}
}