public with sharing class CLP_MikataPaymentMethodApi {
    public CLP_MikataPaymentMethodApi() {
    }

    // call product bulk upsert api
    public static CLP_BulkBillingWrapper paymentMethodBulkUpsert(List<PaymentMethod__c> payMetsList) {
        String request = '';
        String response = '';
        try {
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);  
            billingPaymentWrapper.setListBillPayment(payMetsList);

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_UPSERT_PATH);
            request = JSON.serialize(billingPaymentWrapper);
            system.debug('@@@@paymentMethodBulkUpsert.request= ' + request);

            response = mikataApi.runApi(endpoint, request);
            system.debug('@@@@paymentMethodBulkUpsert.response= ' + response);
           
            CLP_BulkBillingWrapper obj = (CLP_BulkBillingWrapper)JSON.deserialize(response, CLP_BulkBillingWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillingWrapper obj = new CLP_BulkBillingWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataPaymentMethodApi.paymentMethodBulkUpsert.obj exception= ' + obj);
            return obj;
        }
    }
    
    // call product bulk stop api
    public static CLP_BulkBillingWrapper paymentMethodBulkStop(List<PaymentMethod__c> payMetsList) {
        String request = '';
        String response = '';
        try {
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);
            billingPaymentWrapper.setListBillPaymentStop(payMetsList);  

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_STOP_PATH);
            request = JSON.serialize(billingPaymentWrapper);
            system.debug('@@@@paymentMethodBulkStop.request= ' + request);

            response = mikataApi.runApi(endpoint, request);
            system.debug('@@@@paymentMethodBulkStop.response= ' + response);
           
            CLP_BulkBillingWrapper obj = (CLP_BulkBillingWrapper)JSON.deserialize(response, CLP_BulkBillingWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillingWrapper obj = new CLP_BulkBillingWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataPaymentMethodApi.paymentMethodBulkStop.obj exception= ' + obj);
            return obj;
        }
    }

    // call product bulk delete api
    public static CLP_BulkBillingWrapper paymentMethodBulkDelete(List<MikataInteBuffer__c> bufferPayMetsList) {
        String request = '';
        String response = '';
        try {
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);
            billingPaymentWrapper.setListBillPaymentDelete(bufferPayMetsList);  

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_STOP_PATH);
            request = JSON.serialize(billingPaymentWrapper);
            system.debug('@@@@paymentMethodBulkDelete.request= ' + request);

            response = mikataApi.runApi(endpoint, request);
            system.debug('@@@@paymentMethodBulkDelete.response= ' + response);
           
            CLP_BulkBillingWrapper obj = (CLP_BulkBillingWrapper)JSON.deserialize(response, CLP_BulkBillingWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillingWrapper obj = new CLP_BulkBillingWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataPaymentMethodApi.paymentMethodBulkDelete.obj exception= ' + obj);
            return obj;
        }
    }

    public static CLP_BulkBillingWrapper paymentMethodReqAccTrans(List<PaymentMethod__c> payMetsList) {
        String request = '';
        String response = '';
        try {
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);  
            billingPaymentWrapper.setListBillPaymentAccountTransfer(payMetsList);

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_DOWNLOAD_PDF);
            request = JSON.serialize(billingPaymentWrapper);
            system.debug('@@@@paymentMethodReqAccTrans.request= ' + request);

            response = mikataApi.runApi(endpoint, request);
            system.debug('@@@@paymentMethodReqAccTrans.response= ' + response);
           
            CLP_BulkBillingWrapper obj = (CLP_BulkBillingWrapper)JSON.deserialize(response, CLP_BulkBillingWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillingWrapper obj = new CLP_BulkBillingWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataPaymentMethodApi.paymentMethodReqAccTrans.obj exception= ' + obj);
            return obj;
        }
    }

    public static CLP_BulkBillingWrapper paymentMethodCreditCard(List<PaymentMethod__c> payMetsList) {
        String request = '';
        String response = '';
        try {
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkBillingWrapper billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataApi.userId, mikataApi.accessKey, null);  
            billingPaymentWrapper.setListBillPaymentCreditCard(payMetsList);

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.BILLING_BULK_UPSERT_PATH);
            request = JSON.serialize(billingPaymentWrapper);
            system.debug('@@@@paymentMethodCreditCard.request= ' + request);

            response = mikataApi.runApi(endpoint, request);
            system.debug('@@@@paymentMethodCreditCard.response= ' + response);
           
            CLP_BulkBillingWrapper obj = (CLP_BulkBillingWrapper)JSON.deserialize(response, CLP_BulkBillingWrapper.class);
            obj.success = true;
            obj.error_message = '';
            return obj;

        } catch(Exception ex){
            CLP_BulkBillingWrapper obj = new CLP_BulkBillingWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataPaymentMethodApi.paymentMethodCreditCard.obj exception= ' + obj);
            return obj;
        }
    }

    // get request by payment method for function F_UPSERT, F_UNSTOP, F_STOP
    public static String getApiRequest(PaymentMethod__c aPayMet, CLP_MikataApi.ApiType apiFunction) {
        try {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillingWrapper billingPaymentWrapper;

            if(apiFunction == CLP_MikataApi.ApiType.F_UPSERT || apiFunction == CLP_MikataApi.ApiType.F_UNSTOP) { 
                billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
                billingPaymentWrapper.setListBillPayment(new List<PaymentMethod__c>{aPayMet});
            }

            else if(apiFunction == CLP_MikataApi.ApiType.F_STOP) {
                billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
                billingPaymentWrapper.setListBillPaymentStop(new List<PaymentMethod__c>{aPayMet});
            }
            return JSON.serialize(billingPaymentWrapper); 

        } catch(Exception ex){
            system.debug('@@@@@ex= ' + ex);
            return 'CLP_MikataPaymentMethodApi.getApiRequest exception= ' + ex.getMessage();
        }
    }

    // get request by payment method for function F_DELETE
    public static String getApiRequest(MikataInteBuffer__c buf, CLP_MikataApi.ApiType apiFunction) {
        try {
            if(apiFunction != CLP_MikataApi.ApiType.F_DELETE) { 
                return null;
            }
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillingWrapper billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
            billingPaymentWrapper.setListBillPaymentDelete(new List<MikataInteBuffer__c>{buf});  
            system.debug('@@@@@billingPaymentWrapper XXX= ' + billingPaymentWrapper);
            return JSON.serialize(billingPaymentWrapper); 

        } catch(Exception ex){
            system.debug('@@@@@ex= ' + ex);
            return 'CLP_MikataPaymentMethodApi.getApiRequest exception= ' + ex.getMessage();
        }
    }

    // get request by payment method for "Check register status" and "Request bank account transfer form (PDF)" 
    public static String getApiRequest(PaymentMethod__c aPayMet, Integer apiFunction) {
        // 1 --> Check register status
        // 2 --> Request bank account transfer form (PDF)
        try {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            CLP_BulkBillingWrapper billingPaymentWrapper;

            if (apiFunction == 1) {
                billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
                billingPaymentWrapper.setListBillPayment(new List<PaymentMethod__c>{aPayMet});

            } else if (apiFunction == 2) {
                billingPaymentWrapper = new CLP_BulkBillingWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
                billingPaymentWrapper.setListBillPaymentAccountTransfer(new List<PaymentMethod__c>{aPayMet});
            }
            return JSON.serialize(billingPaymentWrapper); 

        } catch(Exception ex){
            system.debug('@@@@@ex= ' + ex);
            return 'CLP_MikataPaymentMethodApi.getApiRequest exception= ' + ex.getMessage();
        }
    }

    // get response by billing payment
    public static String getApiResponse(CLP_BulkBillingWrapper.Payment aPayment) {
        if (aPayment == null) {
            return null;
        }
        MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
        CLP_BulkBillingWrapper billingWrapper = new CLP_BulkBillingWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
        CLP_BulkBillingWrapper.Billing aBilling = new CLP_BulkBillingWrapper.Billing();
        aBilling.payment.add(aPayment);
        billingWrapper.billing.add(aBilling);
        return JSON.serialize(billingWrapper); 
    }

    // get response by billing payment
    public static String getApiResponse(CLP_BulkBillingWrapper.Billing aBilling, Boolean isAtLevelBilling) {
        if (aBilling == null || !isAtLevelBilling) {
            return null;
        }
        MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
        CLP_BulkBillingWrapper billingWrapper = new CLP_BulkBillingWrapper(mikataConfig.ApiUserId__c, mikataConfig.ApiAccessKey__c, null);
        billingWrapper.billing.add(aBilling);
        return JSON.serialize(billingWrapper); 
    }
}