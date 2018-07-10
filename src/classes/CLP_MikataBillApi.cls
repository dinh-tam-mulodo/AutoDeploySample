public with sharing class CLP_MikataBillApi {
    public CLP_MikataBillApi() {
        
    }

    public static CLP_BulkBillWrapper referenceFromMikata(List<LastReference__c> lastRefList, String billNumber, 
                                                          Integer indexPage, Integer limitCount) {
        String request = '';
        String response = '';
        try {    
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillWrapper billWrapper = new CLP_BulkBillWrapper(mikataApi.userId, mikataApi.accessKey, null); 
            billWrapper.limit_count = (limitCount == null) ? 20 : limitCount;
            billWrapper.page_count = (indexPage == null) ? 0 : indexPage;
            billWrapper.setListBillToSearch(lastRefList, billNumber);
            system.debug('CLP_MikataBillApi.referenceFromMikata.billWrapper= ' + billWrapper);  

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILL_SEARCH_PATH);
            request = JSON.serialize(billWrapper);
            system.debug('CLP_MikataBillApi.referenceFromMikata.request= ' + request);

            response = mikataApi.runApi(endpoint, request.replace('"number_z"','"number"'));
            system.debug('CLP_MikataBillApi.referenceFromMikata.response= ' + response);
           
            CLP_BulkBillWrapper obj = (CLP_BulkBillWrapper)JSON.deserialize(response.replace('"number"','"number_z"'), CLP_BulkBillWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillWrapper obj = new CLP_BulkBillWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataBillApi.referenceFromMikata.obj exception= ' + obj);
            return obj;
        }
    }

    public static CLP_BulkBillWrapper billBulkGetUrl(List<Bill__c> listBill) {
        String request = '';
        String response = '';
        try {    
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillWrapper billWrapper = new CLP_BulkBillWrapper(mikataApi.userId, mikataApi.accessKey, null);  
            billWrapper.setListBillToGetUrl(listBill);  
            system.debug('CLP_MikataBillApi.billBulkGetUrl.billWrapper= ' + billWrapper);  

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILL_SEARCH_PATH);
            request = JSON.serialize(billWrapper);
            system.debug('CLP_MikataBillApi.billBulkGetUrl.request= ' + request);

            response = mikataApi.runApi(endpoint, request.replace('"number_z"','"number"'));
            system.debug('CLP_MikataBillApi.billBulkGetUrl.response= ' + response);
           
            CLP_BulkBillWrapper obj = (CLP_BulkBillWrapper)JSON.deserialize(response.replace('"number"','"number_z"'), CLP_BulkBillWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillWrapper obj = new CLP_BulkBillWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataBillApi.billBulkGetUrl.obj exception= ' + obj);
            return obj;
        }
    }

    public static CLP_BulkBillWrapper billBulkUpsert(List<Bill__c> listBill) {
        String request = '';
        String response = '';
        try {    
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillWrapper billWrapper = new CLP_BulkBillWrapper(mikataApi.userId, mikataApi.accessKey, null);  
            billWrapper.setListBillToUpsert(listBill);
            system.debug('CLP_MikataBillApi.billBulkUpsert.billWrapper= ' + billWrapper);  

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILL_UPDATE_PATH);
            request = JSON.serialize(billWrapper);
            system.debug('CLP_MikataBillApi.billBulkUpsert.request= ' + request);

            response = mikataApi.runApi(endpoint, request.replace('"number_z"','"number"'));
            system.debug('CLP_MikataBillApi.billBulkUpsert.response= ' + response);
           
            CLP_BulkBillWrapper obj = (CLP_BulkBillWrapper)JSON.deserialize(response.replace('"number"','"number_z"'), CLP_BulkBillWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillWrapper obj = new CLP_BulkBillWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataBillApi.billBulkUpsert.obj exception= ' + obj);
            return obj;
        }
    }

    public static CLP_BulkBillWrapper billBulkStop(List<Bill__c> listBill) {
        String request = '';
        String response = '';
        try {    
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillWrapper billWrapper = new CLP_BulkBillWrapper(mikataApi.userId, mikataApi.accessKey, null);  
            billWrapper.setListBillToStop(listBill);
            system.debug('CLP_MikataBillApi.billBulkStop.billWrapper= ' + billWrapper);  

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILL_STOP_PATH);
            request = JSON.serialize(billWrapper);
            system.debug('CLP_MikataBillApi.billBulkStop.request= ' + request);

            response = mikataApi.runApi(endpoint, request.replace('"number_z"','"number"'));
            system.debug('CLP_MikataBillApi.billBulkStop.response= ' + response);
           
            CLP_BulkBillWrapper obj = (CLP_BulkBillWrapper)JSON.deserialize(response.replace('"number"','"number_z"'), CLP_BulkBillWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillWrapper obj = new CLP_BulkBillWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataBillApi.billBulkStop.obj exception= ' + obj);
            return obj;
        }
    }

    public static String getApiRequest(LastReference__c lastRef, CLP_MikataApi.ApiType apiFunction, String billNumber, 
                                       Integer indexPage, Integer limitCount){
        try {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillWrapper billWrapper;

            if (apiFunction == null) {
                billWrapper = new CLP_BulkBillWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
                billWrapper.limit_count = (limitCount == null) ? 20 : limitCount;
                billWrapper.page_count = (indexPage == null) ? 0 : indexPage;
                billWrapper.setListBillToSearch(new List<LastReference__c>{ lastRef }, billNumber);
            }
            return JSON.serialize(billWrapper); 

        } catch(Exception ex){
            system.debug('@@@getApiRequest1.ex= ' + ex);
            return 'CLP_MikataBillApi.getApiRequest1.exception= ' + ex.getMessage();
        }
    }

    public static String getApiRequest(Bill__c billReq, BillDetail__c billDetReq){
        try {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillWrapper billWrapper = new CLP_BulkBillWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
            billWrapper.setListBillDetail(billReq, billDetReq);
            return JSON.serialize(billWrapper); 

        } catch(Exception ex){
            system.debug('@@@getApiRequest2.ex= ' + ex);
            return 'CLP_MikataBillApi.getApiRequest2.exception= ' + ex.getMessage();
        }
    }

    public static String getApiRequest(Bill__c billReq, CLP_MikataApi.ApiType apiFunction){
        try {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillWrapper billWrapper;

            if(apiFunction == CLP_MikataApi.ApiType.F_UPSERT || apiFunction == CLP_MikataApi.ApiType.F_UNSTOP) {
                billWrapper = new CLP_BulkBillWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
                billWrapper.setListBillToUpsert(new List<Bill__c>{ billReq });

            } else if(apiFunction == CLP_MikataApi.ApiType.F_STOP) { 
                billWrapper = new CLP_BulkBillWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
                billWrapper.setListBillToStop(new List<Bill__c>{ billReq });
            }
            return JSON.serialize(billWrapper); 

        } catch(Exception ex){
            system.debug('@@@getApiRequest3.ex= ' + ex);
            return 'CLP_MikataBillApi.getApiRequest3.exception= ' + ex.getMessage();
        }
    }

    public static String getApiRequest(Bill__c billReq) {
        try {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillWrapper billWrapper;

            billWrapper = new CLP_BulkBillWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
            billWrapper.setListBillToGetUrl(new List<Bill__c>{ billReq });
            return JSON.serialize(billWrapper); 

        } catch(Exception ex){
            system.debug('@@@getApiRequest4.ex= ' + ex);
            return 'CLP_MikataBillApi.getApiRequest4.exception= ' + ex.getMessage();
        }
    }

    public static String getApiResponse(CLP_BulkBillWrapper.Bill billResponse) {
        if (billResponse == null) {
            return null;
        }
        MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
        CLP_BulkBillWrapper billWrapper = new CLP_BulkBillWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
        billWrapper.bill.add(billResponse);
        return JSON.serialize(billWrapper); 
    }
}