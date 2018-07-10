/**
 * CLP_AccountTriggerHanlder.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_AccountTriggerHanlder class
 */
public with sharing class CLP_AccountTriggerHanlder {
	// before delete function
	public static void beforeDeleteAccount(Map<Id,Account> triggerMaps){
		List<Account> accounts = new List<Account>();
		
		List<Account> recordDeleted = [Select Id,IsStop__c,SeikyusakiCode__c,IsIntegrated__c,ManipulateStatus__c from Account
							where Id in: triggerMaps.keyset()];
		for(Account acc : recordDeleted) {
			if(acc.IsIntegrated__c==true){
				if(acc.IsStop__c==false)	{
					triggerMaps.get(acc.Id).addError('エラー：停止されていないため、削除できません。');				
				}else if(acc.IsStop__c==true){
					accounts.add(new Account(Id=acc.Id,
										SeikyusakiCode__c = acc.SeikyusakiCode__c,									
	        							StopFlg__c = CLP_MikataConstant.FLG_DELETE,
	        							ManipulateStatus__c= CLP_MikataConstant.DEMAND_LINK_SUCCESS));
				}
			}
			
  		}
  		if(!accounts.isEmpty())
  		{  			
        	// update deleted accounts
	        String[] listFields = new String[]{'StopFlg__c','ManipulateStatus__c'};
	        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_ACCOUNT,listFields, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
	              // update accounts
	              update accounts;
	        }
	        List<MikataInteBuffer__c> buffers = new List<MikataInteBuffer__c>();
	        // create buffer data
	        for(Account acc : accounts){
	        	MikataInteBuffer__c bf = new MikataInteBuffer__c();
	        	bf.RecordID__c = acc.Id;
	        	bf.RecordCode__c = acc.SeikyusakiCode__c;
	        	bf.SObjectType__c = CLP_MikataConstant.SOBJECT_ACCOUNT;
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
  		Id jobId = CLP_AccountBillingBulkDeleteBatch.startBatch(true);
	}
}