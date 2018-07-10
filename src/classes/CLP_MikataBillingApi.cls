public with sharing class CLP_MikataBillingApi {
    
    // call billing individual bulk upsert api
    public static CLP_BulkBillingResponseWrapper billingIndividualBulkUpsert(List<Seikyusakibusho__c> billIndList) {
        String request = '';
        String response = '';
        try{
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billIndWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);
            // set ListBillIndividual for bulk upsert (isStop = false)
            billIndWrapper.setListBillIndividual(billIndList,false);

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_UPSERT_PATH);
            request = JSON.serialize(billIndWrapper);
            system.debug('request: ' + request);
            response = mikataApi.runApi(endpoint, request.replace('"number_Z"','"number"'));
            system.debug('response: ' + request);
            
            CLP_BulkBillingResponseWrapper obj = (CLP_BulkBillingResponseWrapper)JSON.deserialize(response.replace('"number"','"number_Z"'), CLP_BulkBillingResponseWrapper.class);
            return obj;
        }catch(Exception ex){
            system.debug('CLP_MikataBillingApi.billingIndividualBulkUpsert.obj exception= ' + ex.getMessage());
            throw ex;
            return null;
        }
    }
    // call billing individual bulk stop api
    public static CLP_BulkBillingWrapper billingIndividualBulkStop(List<Seikyusakibusho__c> billIndList) {
        String request = '';
        String response = '';
        try{
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billIndWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);
            // set ListBillIndividual for bulk stop (isStop = true)
            billIndWrapper.setListBillIndividual(billIndList,true); 

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_STOP_PATH);
            request = JSON.serialize(billIndWrapper);
            system.debug('request: ' + request);
            response = mikataApi.runApi(endpoint, request);
            
            CLP_BulkBillingWrapper obj = (CLP_BulkBillingWrapper)JSON.deserialize(response, CLP_BulkBillingWrapper.class);
            return obj;
        }catch(Exception ex){
            throw ex;
            system.debug('CLP_MikataBillingApi.billingIndividualBulkStop.obj exception= ' + ex.getMessage());
            return null;
        }
    }

    // call billing individual bulk delete api
    public static CLP_BulkBillingWrapper billingIndividualBulkDelete(List<MikataInteBuffer__c> bufferList) {
        String request = '';
        String response = '';
        try{
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billIndWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);
            // set ListBillIndividual for bulk stop
            billIndWrapper.setListBillIndividualToDelete(bufferList); 

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_STOP_PATH);
            request = JSON.serialize(billIndWrapper);
            system.debug('request: ' + request);
            system.debug('endpoint:'+endpoint);
            response = mikataApi.runApi(endpoint, request);
            system.debug('response: ' + response);
            CLP_BulkBillingWrapper obj = (CLP_BulkBillingWrapper)JSON.deserialize(response, CLP_BulkBillingWrapper.class);
            system.debug(obj);
            return obj;
        }catch(Exception ex){
            system.debug('CLP_MikataBillingApi.billingIndividualBulkStop.obj exception= ' + ex.getMessage());
            //throw ex;            
            return null;
        }
    }

    public static String getApiRequestBillIndividual(Seikyusakibusho__c bi, CLP_MikataApi.ApiType apiFunction){
        try
        {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillingWrapper billWrapper = new CLP_BulkBillingWrapper();

            if(apiFunction == CLP_MikataApi.ApiType.F_UPSERT){
                billWrapper.user_id = mikataConfig.ApiUserId__c;
                billWrapper.access_key = mikataConfig.ApiAccessKey__c;
                billWrapper.setListBillIndividual(new List<Seikyusakibusho__c> {bi},false);
            }

            else if(apiFunction == CLP_MikataApi.ApiType.F_STOP 
                    || apiFunction == CLP_MikataApi.ApiType.F_UNSTOP
                    || apiFunction == CLP_MikataApi.ApiType.F_DELETE)
            {
                billWrapper.user_id = mikataConfig.ApiUserId__c;
                billWrapper.access_key = mikataConfig.ApiAccessKey__c;
                billWrapper.setListBillIndividual(new List<Seikyusakibusho__c> {bi},true);
            }
            return JSON.serialize(billWrapper); 

        }catch(Exception ex){
            return 'CLP_MikataBillingApi.getApiRequestBillIndividual exception= ' + ex.getMessage() + bi;
        }
    }
    // get request by buffer
    public static String getApiRequestBillIndividual(MikataInteBuffer__c bf){
        try
        {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillingWrapper billWrapper = new CLP_BulkBillingWrapper();

                billWrapper.user_id = mikataConfig.ApiUserId__c;
                billWrapper.access_key = mikataConfig.ApiAccessKey__c;
                billWrapper.setListBillIndividualToDelete(new List<MikataInteBuffer__c> {bf});
            return JSON.serialize(billWrapper); 

        }catch(Exception ex){
            return 'CLP_MikataBillingApi.getApiRequestBillIndividual exception= ' + ex.getMessage();
        }
    }

    // get response by product detail object
    public static String getApiResponseBillIndividual(CLP_BulkBillingWrapper.Individual resp_i){
        MikataConfig__c mikataConfig = CLP_MikataConstant.mikataConfig;
        CLP_BulkBillingWrapper billWrapper = new CLP_BulkBillingWrapper(mikataConfig.ApiUserId__c,mikataConfig.ApiAccessKey__c, null);
        CLP_BulkBillingWrapper.Billing billing = new CLP_BulkBillingWrapper.Billing();
        billing.individual.add(resp_i);
        billWrapper.billing.add(billing);
        return JSON.serialize(billWrapper); 
    }

    // call billing account bulk upsert api
    public static CLP_BulkBillingWrapper billingAccountBulkUpsert(List<Account> accList) {
        String request = '';
        String response = '';
        try{
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billIndWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);
            for(Account acc : accList){
                billIndWrapper.getBillingByCodeName(acc.SeikyusakiCode__c, acc.Name);
            }
            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_UPSERT_PATH);
            request = JSON.serialize(billIndWrapper);
            response = mikataApi.runApi(endpoint, request);
            CLP_BulkBillingWrapper obj = (CLP_BulkBillingWrapper)JSON.deserialize(response, CLP_BulkBillingWrapper.class);
            return obj;
        }catch(Exception ex){
            throw ex;
            system.debug('CLP_MikataBillingApi.billingAccountBulkUpsert.obj exception= ' + ex.getMessage());
            return null;
        }
    }

    // call billing account bulk stop api
    public static CLP_BulkAccountBillingWrapper billingAccountBulkStop(List<Account> accList) {
        String request = '';
        String response = '';
        try{
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkAccountBillingWrapper billIndWrapper = new CLP_BulkAccountBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);
            billIndWrapper.createListBillingByAccount(accList);

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_STOP_PATH);
            request = JSON.serialize(billIndWrapper);
            system.debug('request:'+ request);
            response = mikataApi.runApi(endpoint, request);
            CLP_BulkAccountBillingWrapper obj = (CLP_BulkAccountBillingWrapper)JSON.deserialize(response, CLP_BulkAccountBillingWrapper.class);
            return obj;
        }catch(Exception ex){
            throw ex;
            system.debug('CLP_MikataBillingApi.billingAccountBulkStop.obj exception= ' + ex.getMessage());
            return null;
        }
    }

    // call billing account bulk delete api
    public static CLP_BulkAccountBillingWrapper billingAccountBulkDelete(List<MikataInteBuffer__c> bufferList) {
        String request = '';
        String response = '';
        try{
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkAccountBillingWrapper billAccountWrapper = new CLP_BulkAccountBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);
            // set List billingAccount for bulk stop
            billAccountWrapper.createListBillingByBuffer(bufferList); 

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_STOP_PATH);
            request = JSON.serialize(billAccountWrapper);
            system.debug('request: ' + request);
            response = mikataApi.runApi(endpoint, request);
            
            CLP_BulkAccountBillingWrapper obj = (CLP_BulkAccountBillingWrapper)JSON.deserialize(response, CLP_BulkAccountBillingWrapper.class);
            return obj;
        }catch(Exception ex){
            throw ex;
            system.debug('CLP_MikataBillingApi.billingAccountBulkDelete.obj exception= ' + ex.getMessage());
            return null;
        }
    }
}