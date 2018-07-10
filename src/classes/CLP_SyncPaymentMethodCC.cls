/**
 * CLP_SyncPaymentMethodCC.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: 
 */
  global with sharing class CLP_SyncPaymentMethodCC {
	public CLP_SyncPaymentMethodCC() {
	}

	@RemoteAction
	webservice static String registerMikata(List<Id> recordIds){
		CLP_JSONResult jsonRes;
		try {    	
			// Check config
         	CLP_MikataApi mikataConfig = new CLP_MikataApi();
         	//
			List<PaymentMethod__c> listPayMets = getPaymentMethodRecords(recordIds);
			List<PaymentMethod__c> listPayMetsChoosen = new List<PaymentMethod__c>();
			List<PaymentMethod__c> listFailed = new List<PaymentMethod__c>();
			Integer countFailed = 0;

			// Fill error when clicked a payment method:
			// - already Stop Mikata
			for (PaymentMethod__c pm : listPayMets) {
				if (pm.IsIntegrated__c && !pm.IsStop__c 
					&& pm.ManipulateStatus__c == CLP_MikataConstant.DEMAND_LINK_SUCCESS
					&& pm.AccountId__r.ManipulateStatus__c != CLP_MikataConstant.DEMAND_IN_EDIT) {
					continue;

				} else {
					pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
					pm.ErrorMessage__c = '';
					pm.ExternalKey__c = setExternalKey(pm);
					listPayMetsChoosen.add(pm);
				}
			}

			// update status before run batch
			String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c'};
			if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
			&& CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){    
				Savepoint sp;
				if (!Test.isRunningTest()) {
					sp = Database.setSavepoint();    
				}
				Database.SaveResult[] saveResults = Database.update(listPayMetsChoosen, false);
				for (Integer i=0; i<saveResults.size(); i++){
				  	if (!saveResults[i].isSuccess()) {
				  		String totalErrorMsg = getErrorValidationMessage(saveResults[i].getErrors());
						listPayMetsChoosen[i].ErrorMessage__c = totalErrorMsg;  
						listPayMetsChoosen[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
						listPayMetsChoosen[i].ExternalKey__c = null;
						listFailed.add(listPayMetsChoosen[i]);
						countFailed++;
				  	}  
				}   
				if (!listFailed.isEmpty()) {
					try {
						update listFailed; 
						
					} catch (DmlException dmlEx) {
						if (!Test.isRunningTest()) {
							Database.rollback(sp);
						}
						throw dmlEx;
					}	
				}
			}

			Id jobId = null;
			jobId = CLP_PaymentMethodBulkUpsertBatch.startBatch(true);
			if (jobId == null){
			 	jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
			 	return JSON.serialize(jsonRes);  

			} else {
				if (countFailed > 0) {		// show list of payment method error (cannot call to Mikata)
					String alertMessage = buildAlertMessage(countFailed);
					jsonRes = new CLP_JSONResult(true, null, alertMessage); 
					return JSON.serialize(jsonRes);
				}
			 	jsonRes = new CLP_JSONResult(true, null, null);
			 	return JSON.serialize(jsonRes);
			}   
		  
		} catch(Exception ex){
			System.debug('CLP_SyncPaymentMethodCC.registerMikata.ex= ' + ex.getMessage());
			jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
			return JSON.serialize(jsonRes); 
		}
	}    

	@RemoteAction
	webservice static String stopMikata(List<Id> recordIds){
		CLP_JSONResult jsonRes;
	    try {     
	    	// Check config
         	CLP_MikataApi mikataConfig = new CLP_MikataApi();
         	//
			List<PaymentMethod__c> listPayMets = getPaymentMethodRecords(recordIds);
			List<PaymentMethod__c> listFailed = new List<PaymentMethod__c>();
			Map<Id, List<DemandDetail__c>> ddlistByPmId = createDemandDetailListByPaymentId(listPayMets);
			Integer countFailed = 0;

			// Fill error when clicked a payment method:
			//  - Not yet register Mikata
			//  - already Stop Mikata
			List<PaymentMethod__c> listPayMetsBackup = setBackupList(listPayMets);
			for (PaymentMethod__c pm : listPayMets) {
				if (pm.IsIntegrated__c && !pm.IsStop__c) {
					Boolean isCheckDemandDetailOK = checkRelatedDemandDetailToStop(pm, ddlistByPmId);
					if (isCheckDemandDetailOK) {
						pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
					 	pm.StopFlg__c = CLP_MikataConstant.FLG_STOP;
					 	pm.ErrorMessage__c = '';
					 	//pm.ExternalKey__c = setExternalKey(pm);

				 	} else {
				 		pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
				 		pm.ErrorMessage__c = 'エラー303:この決済手段は使用中です。';
				 		listFailed.add(pm);
				    	countFailed++;	
				 	}					
				
				} else {
					pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
				 	pm.StopFlg__c = CLP_MikataConstant.FLG_STOP;	
				 	pm.ErrorMessage__c = '';
				 	//pm.ExternalKey__c = setExternalKey(pm);
				}
			}

			// update status before run batch
			String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'StopFlg__c'};
			if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
			&& CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){   
				Savepoint sp;
				if (!Test.isRunningTest()) {
					sp = Database.setSavepoint();    
				}
				Database.SaveResult[] saveResults = Database.update(listPayMets, false);
	            for (Integer i=0; i<saveResults.size(); i++){
	               	if (!saveResults[i].isSuccess()) {
						listPayMets[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
						listPayMets[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
						listPayMets[i].StopFlg__c = listPayMetsBackup[i].StopFlg__c;
						listFailed.add(listPayMets[i]);
						countFailed++;
	               	}  
	            }
	            if (!listFailed.isEmpty()) {
					try {
						update listFailed; 
						
					} catch (DmlException dmlEx) {
						if (!Test.isRunningTest()) {
							Database.rollback(sp);
						}	
						throw dmlEx;
					}	
				}
			}

			Id jobId = null; 
			jobId = CLP_PaymentMethodBulkStopBatch.startBatch(true);
			if (jobId == null) {
				jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
			 	return JSON.serialize(jsonRes); 

			} else {
				if (countFailed > 0) {		// show list of payment method error (cannot call to Mikata)
					String alertMessage = buildAlertMessage(countFailed);
					jsonRes = new CLP_JSONResult(true, null, alertMessage); 
					return JSON.serialize(jsonRes);
				}
				jsonRes = new CLP_JSONResult(true, null, null);
			 	return JSON.serialize(jsonRes);
			}
		  
	    } catch(Exception ex){
			System.debug('CLP_SyncPaymentMethodCC.stopMikata.ex= ' + ex.getMessage());
			jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
			return JSON.serialize(jsonRes);
	    }
	} 

	@RemoteAction
	webservice static String unstopMikata(List<Id> recordIds){
		CLP_JSONResult jsonRes;
		try {   
			// Check config
         	CLP_MikataApi mikataConfig = new CLP_MikataApi();
         	//
			List<PaymentMethod__c> listPayMets = getPaymentMethodRecords(recordIds);
			List<PaymentMethod__c> listFailed = new List<PaymentMethod__c>();
			Integer countFailed = 0;

			// Fill error when on a payment method:
			//  - Not yet register Mikata
			//  - Register Mikata but not yet Stop
			List<PaymentMethod__c> listPayMetsBackup = setBackupList(listPayMets);
			for (PaymentMethod__c pm : listPayMets) {
			  	if (!pm.IsIntegrated__c) {
				 	pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
				 	pm.ErrorMessage__c = 'エラー204:対象レコードは未連携です。';
				 	countFailed++;

			  	} else if (pm.IsIntegrated__c && !pm.IsStop__c) {
	  				pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
				 	pm.ErrorMessage__c = 'エラー202:対象レコードは停止されていません。';
				 	countFailed++;

			  	} else if (pm.IsIntegrated__c && pm.IsStop__c) {
		  			pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
				 	pm.StopFlg__c = null;
				 	pm.ErrorMessage__c = '';
				 	//pm.ExternalKey__c = setExternalKey(pm);
			  	}
			}
			
			// update status before run batch
			String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c', 'StopFlg__c'};
			if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
			&& CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){ 
				Savepoint sp;
				if (!Test.isRunningTest()) {
					sp = Database.setSavepoint();    
				}
				Database.SaveResult[] saveResults = Database.update(listPayMets, false);
	            for (Integer i=0; i<saveResults.size(); i++){
	               	if (!saveResults[i].isSuccess()) {
						listPayMets[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
						listPayMets[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
						listPayMets[i].StopFlg__c = listPayMetsBackup[i].StopFlg__c;
						listFailed.add(listPayMets[i]);
						countFailed++;
	               	}  
	            }
	            if (!listFailed.isEmpty()) {
					try {
						update listFailed; 
						
					} catch (DmlException dmlEx) {
						if (!Test.isRunningTest()) {
							Database.rollback(sp);
						}	
						throw dmlEx;
					}	
				}
			}

			Id jobId = null;
			jobId = CLP_PaymentMethodBulkUpsertBatch.startBatch(true);
			if (jobId == null){
				jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
			 	return JSON.serialize(jsonRes); 

			} else {
				if (countFailed > 0) {		// show list of payment method error (cannot call to Mikata)
					String alertMessage = buildAlertMessage(countFailed);
					jsonRes = new CLP_JSONResult(true, null, alertMessage); 
					return JSON.serialize(jsonRes);
				}
				jsonRes = new CLP_JSONResult(true, null, null);
			 	return JSON.serialize(jsonRes); 
			}

	   	} catch(Exception ex){
			System.debug('CLP_SyncPaymentMethodCC.unstopMikata.ex= ' + ex.getMessage());
			jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
			return JSON.serialize(jsonRes); 
	   	}
	}    

	@RemoteAction
	webservice static String registerCreditCardMikata(List<Id> recordIds){
		CLP_JSONResult jsonRes;
		try {    	
			// Check config
         	CLP_MikataApi mikataConfig = new CLP_MikataApi();
         	//
			List<PaymentMethod__c> listPayMets = getPaymentMethodRecords(recordIds);
			List<PaymentMethod__c> listFailed = new List<PaymentMethod__c>();
			Integer countFailed = 0;
			
			// Create list payment type Credit card
			List<PaymentMethod__c> subListPayMets = new List<PaymentMethod__c>();
			for (PaymentMethod__c pm : listPayMets) {
				if (pm.PaymentMethod__c == CLP_MikataConstant.PM_CREDIT_CARD) {
					subListPayMets.add(pm);	
				}
			}

			if (subListPayMets == null || subListPayMets.isEmpty()) {
				String errorMsg = 'エラー：「クレジットカード」タイプの決済方法が見つかりません。';
				jsonRes = new CLP_JSONResult(false, null, errorMsg);
			 	return JSON.serialize(jsonRes);  	
			}

			// Fill error when:
			// - Payment method isn't integrated 
			for (PaymentMethod__c pm : subListPayMets) {
				if (!pm.IsIntegrated__c) {
					pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
					pm.ErrorMessage__c = 'エラー204:対象レコードは未連携です。';
					listFailed.add(pm);
					countFailed++;

				} else {
					pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
					pm.ErrorMessage__c = '';
					//pm.ExternalKey__c = setExternalKey(pm);
				}
			}

			// update status before run batch
			String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c'};
			if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
			&& CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){    
				Savepoint sp;
				if (!Test.isRunningTest()) {
					sp = Database.setSavepoint();    
				}
				Database.SaveResult[] saveResults = Database.update(subListPayMets, false);
	            for (Integer i=0; i<saveResults.size(); i++){
	               	if (!saveResults[i].isSuccess()) {
						subListPayMets[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
						subListPayMets[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
						listFailed.add(subListPayMets[i]);
						countFailed++;
	               	}  
	            }
	            if (!listFailed.isEmpty()) {
					try {
						update listFailed; 
						
					} catch (DmlException dmlEx) {
						if (!Test.isRunningTest()) {
							Database.rollback(sp);
						}
						throw dmlEx;
					}	
				}
			}

			Id jobId = null;
			jobId = CLP_PaymentMethodBulkCreditCardBatch.startBatch(true);
			if (jobId == null) {
			 	jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
			 	return JSON.serialize(jsonRes);  

			} else {
				if (countFailed > 0) {		// show list of payment method error (cannot call to Mikata)
					String alertMessage = buildAlertMessage(countFailed);
					jsonRes = new CLP_JSONResult(true, null, alertMessage); 
					return JSON.serialize(jsonRes);
				}
			 	jsonRes = new CLP_JSONResult(true, null, null);
			 	return JSON.serialize(jsonRes);
			}   
		  
		} catch(Exception ex){
			System.debug('CLP_SyncPaymentMethodCC.registerCreditCardMikata.ex= ' + ex.getMessage());
			jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
			return JSON.serialize(jsonRes); 
		}
	}

	@RemoteAction
	webservice static String requestAccountTransferMikata(List<Id> recordIds){
		CLP_JSONResult jsonRes;
		try {    	
			// Check config
         	CLP_MikataApi mikataConfig = new CLP_MikataApi();
         	//
			List<PaymentMethod__c> listPayMets = getPaymentMethodRecords(recordIds);
			List<PaymentMethod__c> listFailed = new List<PaymentMethod__c>();

			// Fill error when:
			// - Payment method isn't integrated 
			// - Payment method type isn't CP_ACCOUNT_TRANSFER
			for (PaymentMethod__c pm : listPayMets) {
				if (!pm.IsIntegrated__c) {
					pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
					pm.ErrorMessage__c = 'エラー204:対象レコードは未連携です。';
					listFailed.add(pm);
				
				} else {
					pm.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
					pm.ErrorMessage__c = '';
					//pm.ExternalKey__c = setExternalKey(pm);
				}
			}

			// update status before run batch
			String[] listField = new String[]{'ErrorMessage__c', 'ManipulateStatus__c'};
			if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT) 
			&& CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_PAYMENT_METHOD, listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){    
				Savepoint sp;
				if (!Test.isRunningTest()) {
					sp = Database.setSavepoint();    
				}
				Database.SaveResult[] saveResults = Database.update(listPayMets, false);
	            for (Integer i=0; i<saveResults.size(); i++){
	               	if (!saveResults[i].isSuccess()) {
						listPayMets[i].ErrorMessage__c = getErrorValidationMessage(saveResults[i].getErrors());
						listPayMets[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
						listFailed.add(listPayMets[i]);
	               	}  
	            }
	            if (!listFailed.isEmpty()) {
					try {
						update listFailed; 
						
					} catch (DmlException dmlEx) {
						if (!Test.isRunningTest()) {
							Database.rollback(sp);
						}
						throw dmlEx;
					}	
				}
			}

			Id jobId = null;
			jobId = CLP_PaymentMethodBulkReqAccTransBatch.startBatch(true);
			if (jobId == null){
			 	jsonRes = new CLP_JSONResult(false, null, 'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
			 	return JSON.serialize(jsonRes);  

			} else {
			 	jsonRes = new CLP_JSONResult(true, null, null);
			 	return JSON.serialize(jsonRes);
			}   
		  
		} catch(Exception ex){
			System.debug('CLP_SyncPaymentMethodCC.requestAccountTransferMikata.ex= ' + ex.getMessage());
			jsonRes = new CLP_JSONResult(false, null, ex.getMessage());
			return JSON.serialize(jsonRes); 
		}
	}

	private static List<PaymentMethod__c> getPaymentMethodRecords(List<Id> recordIds){
		try {
			List<PaymentMethod__c> pms = [Select Id, PaymentMethodCode__c, PaymentMethod__c, IsIntegrated__c, IsStop__c, StopFlg__c, ManipulateStatus__c, ErrorMessage__c, 
			                                     AccountId__r.IsIntegrated__c, AccountId__r.IsStop__c,
			                                     AccountId__r.ManipulateStatus__c,AccountId__r.SeikyusakiCode__c, ExternalKey__c 
										  From PaymentMethod__c
										  Where Id In :recordIds];
			  
		  	if (pms != null && !pms.isEmpty()){
			 	return pms;
		  	}
		  	return null;

		} catch(Exception ex){
			System.debug('CLP_SyncPaymentMethodCC.getPaymentMethodRecords.ex= ' + ex.getMessage());
			return null;
		}
	}

	private static Boolean checkRelatedDemandDetailToStop(PaymentMethod__c pm, Map<Id, List<DemandDetail__c>> ddlistByPmId) {
		Boolean isOk = true;
		List<DemandDetail__c> ddList =  ddlistByPmId.get(pm.Id);

		// payment method has zero demandDetail linked
		if (ddList == null) {
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

	private static String buildAlertMessage(Integer countFailed) {
		return 'エラー：計 ' + countFailed + ' 件の入力不備があります。';
	}

	private static Map<Id, List<DemandDetail__c>> createDemandDetailListByPaymentId(List<PaymentMethod__c> listPm) {
		List<Id> listPmIds = new List<Id>();
		for (PaymentMethod__c pm : listPm) {
			listPmIds.add(pm.Id);	
		}

		Map<Id, List<DemandDetail__c>> maps = new Map<Id, List<DemandDetail__c>>();
		for (DemandDetail__c dd : [Select Id, Name, IsIntegrated__c, IsStop__c, PaymentMethod__c From DemandDetail__c Where PaymentMethod__c In :listPmIds]) {

			if (maps.get(dd.PaymentMethod__c) == null) {
				List<DemandDetail__c> ddList = new List<DemandDetail__c>();
				ddList.add(dd);
				maps.put(dd.PaymentMethod__c, ddList);	

			} else {
				List<DemandDetail__c> ddList = maps.get(dd.PaymentMethod__c);
				ddList.add(dd);
				maps.put(dd.PaymentMethod__c, ddList);	
			} 									   							   
		} 
		return maps;
	}

	private static List<PaymentMethod__c> setBackupList(List<PaymentMethod__c> listPayMets) {
		List<PaymentMethod__c> tempList = new List<PaymentMethod__c>();
      	for (PaymentMethod__c payMet : listPayMets) {
			PaymentMethod__c tempPayMet = new PaymentMethod__c();
			tempPayMet.StopFlg__c = payMet.StopFlg__c;
			tempPayMet.PaymentMethodCode__c = payMet.PaymentMethodCode__c;
			tempList.add(tempPayMet);  
      	}
      	return tempList;
	}

	private static String getErrorValidationMessage(List<Database.Error> listErr) {
		// Check if exist error duplicate
		String errorMessageTotal = '';
		String errorStatusTotal = '';
		Integer count = 0;
		for (Database.Error err : listErr) {
			count++;
			errorStatusTotal += err.getStatusCode() + (count == listErr.size() ? '' : '\n');
            errorMessageTotal += err.getMessage() + (count == listErr.size() ? '' : '\n');
		} 
		if (String.isNotBlank(errorStatusTotal)) {
			if (errorStatusTotal.contains('DUPLICATE_VALUE')){
				return '決済情報コードは重複です。';
			}		
		}
		return errorMessageTotal;
   	}

   	private static String setExternalKey(PaymentMethod__c pm) {
   		/*if (String.isNotBlank(pm.ExternalKey__c)) {
            return pm.ExternalKey__c;
        } */  
        return (pm.AccountId__r.SeikyusakiCode__c + '_' + pm.PaymentMethodCode__c);
   	}
}