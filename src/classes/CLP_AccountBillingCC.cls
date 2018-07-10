/**
 * CLP_AccountBillingCC.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_AccountBillingCC
 */
global with sharing class CLP_AccountBillingCC {

	// stop billing to mikata 
	@RemoteAction
    webservice static String stopAccountBillToMikata(List<Id> recordIds){
    	return handleDataAccountBillToMikata(recordIds, false);
    } 

    // upsert billing to mikata 
	@RemoteAction
    webservice static String unstopAccountBillToMikata(List<Id> recordIds){
    	return handleDataAccountBillToMikata(recordIds, true);
    }

    /*handle to stop or unstop account
	params: 
	 - RecordIds: list account id
	 - isUnstop: to separate stop or unstop action
    */
    private static String handleDataAccountBillToMikata(List<Id> recordIds, Boolean isUnStop){
    	CLP_JsonResult result = new CLP_JsonResult(); 
    	Boolean success = true;
    	String errorMessage = '';
    	try{
    		// raise error don't config mikata before
    		CLP_MikataApi mikataApi = new CLP_MikataApi();
    		List<Account> listAcc = [SELECT Id, Name, StopFlg__c, IsStop__c, ManipulateStatus__c,
    								IsIntegrated__c, SeikyusakiCode__c FROM Account WHERE Id IN :recordIds];
			if (listAcc != null && !listAcc.isEmpty()){
				//assign status
				assignAccountPreStatus(listAcc, isUnStop);
				Integer countError = updateAccountStatus(listAcc);
		        // call batch to stop into mikata		        
	        	Id jobId;
	        	if(isUnStop){
	        		jobId = CLP_AccountBillingBulkUpsertBatch.startBatch(true);
	        	}else{
	        		jobId = CLP_AccountBillingBulkStopBatch.startBatch(true);
	        	}	
	        	if(jobId == null){
	        		//success = false;
	        		//errorMessage = 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。';
                    success=true;
                    errorMessage='';
	        	}
	        	// get number of record error
	        	if(countError > 0){
	        		errorMessage = 'エラー：計 '+countError+' 件の入力不備があります。';
	        	}
			}
		} catch(Exception ex){
			success = false;
			errorMessage = ex.getMessage();
		}
		// return json result
		result.success = success;
		result.errorMessage = errorMessage;
		return JSON.serialize(result);
    }
    // update account status to link into mikata
    private static void assignAccountPreStatus(List<Account> listAcc, Boolean isUnStop){
    	for(Account acc : listAcc){
    		if(acc.IsIntegrated__c==false){
    			acc.ErrorMessage__c = 'エラー：取引先がまだ連携されていません。';
    			acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
    		}else{
    			if(isUnstop==true && (acc.IsStop__c == false || acc.StopFlg__c==null)){
    				acc.ErrorMessage__c = 'エラー202:対象レコードは停止されていません。';
    				acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
    				continue;
    			}
    			acc.ErrorMessage__c = '';
            	acc.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
            	acc.StopFlg__c = isUnStop ? null : CLP_MikataConstant.FLG_STOP; // if unstop ==> set stopflag was null				
        	}
		}	
    }
    // validation list account
    private static Integer updateAccountStatus(List<Account> listAcc){
        Integer countError = 0;
        for(Account acc : listAcc){
        	if(acc.ManipulateStatus__c==CLP_MikataConstant.DEMAND_DATA_DEFECT)
        		countError++;
        }
        String[] listField = new String[]{'ManipulateStatus__c', 'StopFlg__c' , 'ErrorMessage__c', 'IsIntegrated__c'};
        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_ACCOUNT, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){    
            Savepoint sp;
            if(!Test.isRunningTest()){
                sp = Database.setSavepoint();
            }
            Database.SaveResult[] saveResults = Database.update(listAcc, false);
            List<Account> failedList = new List<Account>();
            for (Integer i=0; i<saveResults.size(); i++){
				if (!saveResults[i].isSuccess()) { // validation rule for field required
					countError++;
					String errMessage = '';
                    for(Database.Error e : saveResults[i].getErrors()){
                        errMessage+= e.getMessage() + '\n';
                    }
					listAcc[i].ErrorMessage__c = errMessage;
					listAcc[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;				
					failedList.add(listAcc[i]);
				}  
            } 
            if(!failedList.isEmpty())
			{
				try{
	        		update failedList;	
	        	}catch(DmlException ex){	        		
	                if(!Test.isRunningTest()){
	                   Database.rollback(sp);
	                }
	        	}
			}    
        }
        return countError;
    }    
}