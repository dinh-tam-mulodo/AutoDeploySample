public with sharing class CLP_MikataDemandAPI {

	// call demand bulk upsert api
	public static CLP_BulkDemandWrapper demandBulkUpsert(List<DemandDetail__c> demandList,Boolean isUnStop) {
        String request = '';
        String response = '';
        try{
        	CLP_MikataApi mikataApi = new CLP_MikataApi();

	        CLP_BulkDemandWrapper demandWrapper = new CLP_BulkDemandWrapper(mikataApi.userId,mikataApi.accessKey,demandList,isUnStop);
	        String endpoint = mikataApi.getEndpoint(CLP_MikataApi.DEMAND_BULK_UPSERT_PATH);
	        request = JSON.serialize(demandWrapper);
            system.debug(request.replace('"number_Z"','"number"'));
	        response = mikataApi.runApi(endpoint, request.replace('"number_Z"','"number"'));
	        system.debug('response:'+response.replace('"number"','"number_Z"'));
	        CLP_BulkDemandWrapper obj = (CLP_BulkDemandWrapper)JSON.deserialize(response.replace('"number"','"number_Z"'), CLP_BulkDemandWrapper.class);
            obj.success = true;
	        return obj;
    	}catch(Exception ex){
    		CLP_BulkDemandWrapper obj = new CLP_BulkDemandWrapper();
            obj.success = false;
    		obj.error_message = ex.getMessage();
    		//system.debug(obj);
    		return obj;
    	}
    }
    // call demands bulk stop api
    public static CLP_BulkDemandWrapper demandBulkStop(List<DemandDetail__c> demandList){
        try{
        	CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkDemandWrapper demandWrapper = new CLP_BulkDemandWrapper();
            demandWrapper.user_id = mikataApi.userId;
            demandWrapper.access_key = mikataApi.accessKey;
            // collect demand to call stop api 
            List<CLP_BulkDemandWrapper.Demand> demands = new List<CLP_BulkDemandWrapper.Demand>();
            for(DemandDetail__c dd : demandList){
                CLP_BulkDemandWrapper.Demand d = new CLP_BulkDemandWrapper.Demand();
                d.number_Z = dd.DemandDetailCode__c;
                d.del_flg = Integer.valueOf(dd.StopFlg__c);
                demands.add(d);
            }
            demandWrapper.demand = demands;
            //system.debug('demandWrapper:'+demandWrapper);

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.DEMAND_BULK_STOP_PATH);
            String request = JSON.serialize(demandWrapper);
            system.debug('request: '+ request);
            String response = mikataApi.runApi(endpoint, request.replace('"number_Z"','"number"'));            
            system.debug('response: ' + response);
            CLP_BulkDemandWrapper obj = (CLP_BulkDemandWrapper)JSON.deserialize(response.replace('"number"','"number_Z"'), CLP_BulkDemandWrapper.class);
            obj.success = true;
            return obj;
        }catch(Exception ex){
            CLP_BulkDemandWrapper obj = new CLP_BulkDemandWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug(obj);
            return obj;
        }
    }
    // call demands bulk search demand api
    public static CLP_BulkDemandWrapper demandBulkSearch(List<DemandDetail__c> demandList){
        try{
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkDemandWrapper demandWrapper = new CLP_BulkDemandWrapper();
            demandWrapper.user_id = mikataApi.userId;
            demandWrapper.access_key = mikataApi.accessKey;
            // collect demand to call stop api 
            List<CLP_BulkDemandWrapper.Demand> demands = new List<CLP_BulkDemandWrapper.Demand>();
            for(DemandDetail__c dd : demandList){
                CLP_BulkDemandWrapper.Demand d = new CLP_BulkDemandWrapper.Demand();
                d.number_Z = dd.DemandDetailCode__c;
                demands.add(d);
            }
            demandWrapper.demand = demands;
            //system.debug('demandWrapper:'+demandWrapper);

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.DEMAND_SEARCH_PATH);
            String request = JSON.serialize(demandWrapper);
            system.debug('request: '+ request);
            String response = mikataApi.runApi(endpoint, request.replace('"number_Z"','"number"'));            
            system.debug('response: ' + response);
            CLP_BulkDemandWrapper obj = (CLP_BulkDemandWrapper)JSON.deserialize(response.replace('"number"','"number_Z"'), CLP_BulkDemandWrapper.class);
            obj.success = true;
            return obj;
        }catch(Exception ex){
            CLP_BulkDemandWrapper obj = new CLP_BulkDemandWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug(obj);
            return obj;
        }
    }
    /// get Request vs Reponse per record    
    public static String getApiRequest(DemandDetail__c d,CLP_MikataApi.ApiType apiFunction){
        try{
        	MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkDemandWrapper wrap;
            if(apiFunction == CLP_MikataApi.ApiType.F_UPSERT 
                || apiFunction == CLP_MikataApi.ApiType.F_UNSTOP){
                wrap = new CLP_BulkDemandWrapper(mikataConfig.ApiUserId__c,mikataConfig.ApiAccessKey__c, new List<DemandDetail__c>{d},apiFunction == CLP_MikataApi.ApiType.F_UNSTOP);
            }
            else if(apiFunction == CLP_MikataApi.ApiType.F_STOP                     
                    || apiFunction == CLP_MikataApi.ApiType.F_DELETE)
            {
                wrap = new CLP_BulkDemandWrapper();
                wrap.user_id = mikataConfig.ApiUserId__c;
                wrap.access_key = mikataConfig.ApiAccessKey__c;
                // get demand deleted
                List<CLP_BulkDemandWrapper.Demand> demandList = new List<CLP_BulkDemandWrapper.Demand>();
                CLP_BulkDemandWrapper.Demand wd = new CLP_BulkDemandWrapper.Demand();
                wd.number_Z = d.DemandDetailCode__c;
                wd.del_flg = Integer.valueOf(d.StopFlg__c);
                demandList.add(wd);
                // list demand to delete in mikata
                wrap.demand = demandList;
            }
        	return JSON.serialize(wrap); 
        }catch(Exception ex){
            return 'Error: ' + ex.getMessage();
        }
    }
    // get response by demand detail object
    public static String getApiResponse(CLP_BulkDemandWrapper.Demand d){
    	MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
    	CLP_BulkDemandWrapper wrap = new CLP_BulkDemandWrapper();
    	wrap.user_id = mikataConfig.ApiUserId__c;
    	wrap.access_key = mikataConfig.ApiAccessKey__c;
    	wrap.demand = new List<CLP_BulkDemandWrapper.Demand>{d};
    	return JSON.serialize(wrap); 
    }
}