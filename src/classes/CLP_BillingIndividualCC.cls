/**
 * CLP_BillingIndividualCC.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_BillingIndividualCC
 */
global with sharing class CLP_BillingIndividualCC {

	// register billing individual into mikata 
	@RemoteAction
    webservice static String registerBillToMikata(List<Id> recordIds){
    	CLP_JsonResult result = new CLP_JsonResult(); 
    	Boolean success = true;
    	String errorMessage = '';
    	try{
    		// raise error don't config mikata before
    		CLP_MikataApi mikataApi = new CLP_MikataApi();
    		List<Seikyusakibusho__c> listBI = [SELECT Id, Name,billing_individual_number__c,Seikyusakimei__r.SeikyusakiCode__c
    											,IsStop__c,Seikyusakimei__r.ManipulateStatus__c
    											, ManipulateStatus__c,IsIntegrated__c,ErrorMessage__c, ExternalKey__c  
    											FROM Seikyusakibusho__c WHERE Id IN :recordIds];
			
			if (listBI != null && !listBI.isEmpty()){
				// update status
				Integer countError = 0;
				List<Seikyusakibusho__c> newList = new List<Seikyusakibusho__c>();
				for(Seikyusakibusho__c billInd : listBI ){
					if(billInd.IsIntegrated__c == true 
					   && billInd.ManipulateStatus__c==CLP_MikataConstant.DEMAND_LINK_SUCCESS
					   && billInd.IsStop__c == false 
					   && billInd.Seikyusakimei__r.ManipulateStatus__c != CLP_MikataConstant.DEMAND_IN_EDIT){
						continue;
					}
					billInd.ExternalKey__c = String.format('{0}_{1}'
											,new String[]{billInd.Seikyusakimei__r.SeikyusakiCode__c,billInd.billing_individual_number__c});
					billInd.ErrorMessage__c = '';
					billInd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
					newList.add(billInd);
				}							
				//update database
				List<Seikyusakibusho__c> failedList = new List<Seikyusakibusho__c>();
		        String[] listField = new String[]{'ErrorMessage__c','ExternalKey__c','ManipulateStatus__c'};
		        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){    
		            /* Edit 26/09/2017 
		               If update error this section will be rollback all transaction
		            */
		            Savepoint sp;
	                if(!Test.isRunningTest()){
	                    sp = Database.setSavepoint();
	                }
		            Database.SaveResult[] saveResults = Database.update(newList, false);
		            for (Integer i=0; i<saveResults.size(); i++){
						if (!saveResults[i].isSuccess()) { // validation rule for field required
							String errMessage = '';
	                        for(Database.Error e : saveResults[i].getErrors()){
                                if(e.getMessage().contains('duplicate value found')){
                                    errMessage+= '請求先部署コードは重複です。' + '\n';
                                }else
	                            errMessage+= e.getMessage() + '\n';
	                        }
	                        newList[i].ExternalKey__c = ''; // reset key if error
							newList[i].ErrorMessage__c = errMessage;
							newList[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
							failedList.add(newList[i]);					
						}  
		            }  
		            // update failed list
		            if(!failedList.isEmpty())
		            {
			            try{  
			            	update failedList;  
			            }catch(DmlException ex){
			                if(!Test.isRunningTest()){
			                   Database.rollback(sp);
			                }
			            	throw ex;
			            }     
		        	}
		        }

		        // call batch to register into mikata		        
	        	Id jobId = CLP_BillingIndividualBulkUpsertBatch.startBatch(true);	
	        	if(jobId == null){
	        		success = false;
	        		errorMessage = 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。';
	        	}
	        	// get number of record error
	        	countError+= failedList.size();
	        	errorMessage = countError > 0 ? 'エラー：計'+countError+'件の入力不備があります。' : '';
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

	// stop billing individual to mikata 
	@RemoteAction
    webservice static String stopBillToMikata(List<Id> recordIds){
    	CLP_JsonResult result = new CLP_JsonResult(); 
    	Boolean success = true;
    	String errorMessage = '';
    	try{
    		// raise error don't config mikata before
    		CLP_MikataApi mikataApi = new CLP_MikataApi();
    		List<Seikyusakibusho__c> listBI = [SELECT Id, Name, IsStop__c, StopFlg__c, ManipulateStatus__c,IsIntegrated__c,ErrorMessage__c  FROM Seikyusakibusho__c WHERE Id IN :recordIds];
			
			if (listBI != null && !listBI.isEmpty()){
				// update status
				Integer countError = 0;
				for(Seikyusakibusho__c billInd : listBI ){					
					billInd.ErrorMessage__c = '';
					billInd.StopFlg__c = CLP_MikataConstant.FLG_STOP;
					billInd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
				}							
				//update database
				List<Seikyusakibusho__c> failedList = new List<Seikyusakibusho__c>();
		        String[] listField = new String[]{'ErrorMessage__c','ManipulateStatus__c'};
		        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){    
		            Savepoint sp;
	                if(!Test.isRunningTest()){
	                    sp = Database.setSavepoint();
	                }
		            Database.SaveResult[] saveResults = Database.update(listBI, false);
		            for (Integer i=0; i<saveResults.size(); i++){
						if (!saveResults[i].isSuccess()) { // validation rule for field required
							String errMessage = '';
	                        for(Database.Error e : saveResults[i].getErrors()){
	                            errMessage+= e.getMessage() + '\n';
	                        }
							// reset StopFlg
							if(listBI[i].IsStop__c!=true)
								listBI[i].StopFlg__c = null;
							listBI[i].ErrorMessage__c = errMessage;
							listBI[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
							failedList.add(listBI[i]);					
						}  
		            }  
		            // update failed list
		            if(!failedList.isEmpty())  
		            {
		            	try{  
			            	update failedList;  
			            }catch(DmlException ex){
			                if(!Test.isRunningTest()){
			                   Database.rollback(sp);
			                }
			            	throw ex;
			            }  
		            }      
		        }

		        // call batch to stop into mikata		        
	        	Id jobId = CLP_BillingIndividualBulkStopBatch.startBatch(true);	
	        	if(jobId == null){
	        		success = false;
	        		errorMessage = 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。';
	        	}
	        	// get number of record error
	        	countError+= failedList.size();
	        	errorMessage = countError > 0 ? 'エラー：計'+countError+'件の入力不備があります。' : '';
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

    // unStop billing individual to mikata 
    @RemoteAction
    webservice static String unStopBillToMikata(List<Id> recordIds){
    	CLP_JsonResult result = new CLP_JsonResult(); 
    	Boolean success = true;
    	Integer countError = 0;
    	String errorMessage = '';
    	try{
    		// raise error don't config mikata before
    		CLP_MikataApi mikataApi = new CLP_MikataApi();
    		List<Seikyusakibusho__c> listBI = [SELECT Id, Name, StopFlg__c, IsStop__c, ManipulateStatus__c,IsIntegrated__c,ErrorMessage__c  FROM Seikyusakibusho__c WHERE Id IN :recordIds];
			
			if (listBI != null && !listBI.isEmpty()){
				// update status
				for(Seikyusakibusho__c billInd : listBI ){
					// record was not integrated or was not stop before
					if(billInd.StopFlg__c == null || billInd.IsStop__c == false)
	                {
	                    countError++;
	                    billInd.ErrorMessage__c = 'エラー：対象レコードは停止されていません。';
	                    billInd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
	                }
	                else
	                {					
						billInd.ErrorMessage__c = '';
						billInd.StopFlg__c = null;
						billInd.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
					}	
				}						
				//update database
				List<Seikyusakibusho__c> failedList = new List<Seikyusakibusho__c>();
		        String[] listField = new String[]{'ErrorMessage__c','ManipulateStatus__c'};
		        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_BILL_INDIVIDUAL, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){    
		            Savepoint sp;
	                if(!Test.isRunningTest()){
	                    sp = Database.setSavepoint();
	                }
		            Database.SaveResult[] saveResults = Database.update(listBI, false);
		            for (Integer i=0; i<saveResults.size(); i++){
						if (!saveResults[i].isSuccess()) { // validation rule for field required
							String errMessage = '';
	                        for(Database.Error e : saveResults[i].getErrors()){
	                            errMessage+= e.getMessage() + '\n';
	                        }
							listBI[i].ErrorMessage__c = errMessage;
							listBI[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
							failedList.add(listBI[i]);					
						}  
		            }  
		            // update failed list
		            if(!failedList.isEmpty())  
		            {
		            	try{  
			            	update failedList;  
			            }catch(DmlException ex){	
			                if(!Test.isRunningTest()){
			                   Database.rollback(sp);
			                }
			            	throw ex;
			            }  
		            }           
		        }

		        // call batch to stop into mikata		        
	        	Id jobId = CLP_BillingIndividualBulkUpsertBatch.startBatch(true);	
	        	if(jobId == null){
	        		success = false;
	        		errorMessage = 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。';
	        	}
	        	// get number of record error
	        	countError+= failedList.size();
	        	errorMessage = countError > 0 ? 'エラー：計'+countError+'件の入力不備があります。' : '';
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

}