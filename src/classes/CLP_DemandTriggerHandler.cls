/**
 * CLP_DemandTriggerHandler.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_DemandTriggerHandler class
 */
public with sharing class CLP_DemandTriggerHandler {
	
	// before delete function
	public static void beforeDeleteDemand(Map<Id,DemandDetail__c> triggerMaps){
		List<DemandDetail__c> demands = new List<DemandDetail__c>();
		
		List<DemandDetail__c> recordDeleted = [Select Id,IsStop__c,IsIntegrated__c,ManipulateStatus__c,
					 PaymentMethod__r.IsStop__c,Seikyuusakibusho__r.IsStop__c,Account__r.IsStop__c from DemandDetail__c where Id in: triggerMaps.keyset()];
    	system.debug('recordDeleted:'+ recordDeleted );
		for(DemandDetail__c demand : recordDeleted) {
			if(demand.IsIntegrated__c==true){
				if(demand.IsStop__c==false 
					&& demand.Account__r.IsStop__c==false
					&& demand.PaymentMethod__r.IsStop__c==false
					&& demand.Seikyuusakibusho__r.IsStop__c==false)	{
					triggerMaps.get(demand.Id).addError('エラー203：該当の請求情報明細、取引先、請求先部署、決済方法がまだ停止されていないため、削除できません。');
				}
				/*else{
					demands.add(new DemandDetail__c(Id=demand.Id,
	        							IsIntegrated__c = false,
	        							StopFlg__c = null,
	        							IsStop__c = false,
	        							ManipulateStatus__c = CLP_MikataConstant.DEMAND_IN_EDIT));
				}*/
			}	
  		}
  		/*if(!demands.isEmpty())
  		{  			
	        // update deleted demand
	        String[] demandField = new String[]{'IsIntegrated__c','StopFlg__c','IsStop__c','ManipulateStatus__c'};
	        if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,demandField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
	              // update demand
	              update demands;
	        }
  		}*/
	}
	// update flag 
	public static void updateFlag(List<DemandDetail__c> demands){

		System.debug(demands);

		List<String> oppIds = new List<String>();
		List<String> productIds = new List<String>();

		for(DemandDetail__c demand:demands){
			OppIds.add(demand.OpportunityId__c);
			ProductIds.add(demand.Product__c);

		}
		//Set<Id> resultIds = (new Map<Id,KEIRINOMIKATA__DemandDetail__c>(demands)).keySet();

		List<OpportunityLineItem> oppProducts= [SELECT IsCreated__c
		FROM OpportunityLineItem
		WHERE (OpportunityId IN :OppIds AND Product2Id IN :ProductIds)];

		for(OpportunityLineItem oppProduct:oppProducts){
				oppProduct.IsCreated__c = false;            
		}
		String[] fields = new String[]{'IsCreated__c'};
		if(CLP_CommonUtil.checkFLS('OpportunityLineItem',fields, CLP_CommonUtil.FLSType.UPDATE_OBJECT)) 
        {
            update oppProducts;
        }
	}
}