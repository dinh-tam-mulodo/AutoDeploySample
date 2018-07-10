public with sharing class CLP_MikataProductApi {
	public CLP_MikataProductApi() {
		
	}

    // call product bulk upsert api
    public static CLP_BulkProductWrapper productBulkUpsert(List<Product2> productList) {
        String request = '';
        String response = '';
        try {
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkProductWrapper productWrapper = new CLP_BulkProductWrapper(mikataApi.userId, mikataApi.accessKey, mikataApi.taxRate, productList);
            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.GOODS_BULK_UPSERT_PATH);
            request = JSON.serialize(productWrapper);
            system.debug('@@@@@productBulkUpsert.request= ' + request);
            response = mikataApi.runApi(endpoint, request);
            system.debug('@@@@@productBulkUpsert.response= ' + response);
           
            CLP_BulkProductWrapper obj = (CLP_BulkProductWrapper)JSON.deserialize(response, CLP_BulkProductWrapper.class);
            obj.success = true;
            return obj;

        } catch(Exception ex){
            CLP_BulkProductWrapper obj = new CLP_BulkProductWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataProductApi.productBulkUpsert.obj exception= ' + obj);
            return obj;
        }
    }
    
    // call product bulk stop api
    public static CLP_BulkProductWrapper productBulkStop(List<Product2> productList) {
        String request = '';
        String response = '';
        try {
        	CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkProductWrapper productWrapper = new CLP_BulkProductWrapper();
            productWrapper.user_id = mikataApi.userId;
            productWrapper.access_key = mikataApi.accessKey;   
            List<CLP_BulkProductWrapper.Goods> goodsList = new List<CLP_BulkProductWrapper.Goods>();
            for(Product2 pp : productList){
                CLP_BulkProductWrapper.Goods p = new CLP_BulkProductWrapper.Goods();
                p.item_code = pp.Item_Code__c;
                p.del_flg = Integer.valueOf(pp.StopFlg__c);
                goodsList.add(p);
            }
            productWrapper.goods = goodsList;

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.GOODS_BULK_STOP_PATH);
            request = JSON.serialize(productWrapper);
            response = mikataApi.runApi(endpoint, request);
            system.debug('@@@@@productBulkStop.response= ' + response);
           
            CLP_BulkProductWrapper obj = (CLP_BulkProductWrapper)JSON.deserialize(response, CLP_BulkProductWrapper.class);
            obj.success = true;
            return obj;

        } catch(Exception ex){
            CLP_BulkProductWrapper obj = new CLP_BulkProductWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataProductApi.productBulkStop.obj exception= ' + obj);
            return obj;
        }
    }

    // call product bulk stop api
    public static CLP_BulkProductWrapper productBulkDelete(List<MikataInteBuffer__c> bufferProductsList) {
        String request = '';
        String response = '';
        try {
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            CLP_BulkProductWrapper productWrapper = new CLP_BulkProductWrapper();
            productWrapper.user_id = mikataApi.userId;
            productWrapper.access_key = mikataApi.accessKey;   
            List<CLP_BulkProductWrapper.Goods> goodsList = new List<CLP_BulkProductWrapper.Goods>();          
            for(MikataInteBuffer__c bufferProduct : bufferProductsList){
                CLP_BulkProductWrapper.Goods p = new CLP_BulkProductWrapper.Goods();
                p.item_code = bufferProduct.RecordCode__c;
                p.del_flg = Integer.valueOf(CLP_MikataConstant.FLG_DELETE);  
                goodsList.add(p);
            }
            productWrapper.goods = goodsList;

            String endpoint = mikataApi.getEndpoint(CLP_MikataApi.GOODS_BULK_STOP_PATH);
            request = JSON.serialize(productWrapper);
            //system.debug('@@@@CLP_MikataProductApi.productBulkDelete.request= ' + request);
            response = mikataApi.runApi(endpoint, request);           
            system.debug('@@@@CLP_MikataProductApi.productBulkDelete.response= ' + response);
           
            CLP_BulkProductWrapper obj = (CLP_BulkProductWrapper)JSON.deserialize(response, CLP_BulkProductWrapper.class);
            obj.success = true;
            return obj;

        } catch(Exception ex){
            CLP_BulkProductWrapper obj = new CLP_BulkProductWrapper();
            obj.success = false;
            obj.error_message = ex.getMessage();
            system.debug('CLP_MikataProductApi.productBulkDelete.obj exception= ' + obj);
            return obj;
        }
    }

    // get request by product detail object
    public static String getApiRequest(Product2 aProduct, CLP_MikataApi.ApiType apiFunction){
        try {
            MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
            String taxRate = (mikataConfig.Tax__c == null) ? null : String.valueOf(mikataConfig.Tax__c);
            CLP_BulkProductWrapper productWrapper = new CLP_BulkProductWrapper();

            if(apiFunction == CLP_MikataApi.ApiType.F_UPSERT || apiFunction == CLP_MikataApi.ApiType.F_UNSTOP) {
                productWrapper = new CLP_BulkProductWrapper(mikataConfig.ApiUserId__c,mikataConfig.ApiAccessKey__c, taxRate, new List<Product2>{aProduct});
            
            } else if(apiFunction == CLP_MikataApi.ApiType.F_STOP || apiFunction == CLP_MikataApi.ApiType.F_DELETE) {
                productWrapper.user_id = mikataConfig.ApiUserId__c;
                productWrapper.access_key = mikataConfig.ApiAccessKey__c;
                List<CLP_BulkProductWrapper.Goods> goodsList = new List<CLP_BulkProductWrapper.Goods>();
                CLP_BulkProductWrapper.Goods aGoods = new CLP_BulkProductWrapper.Goods();
                aGoods.item_code = aProduct.Item_Code__c;
                aGoods.del_flg = Integer.valueOf(aProduct.StopFlg__c);
                goodsList.add(aGoods);
                productWrapper.goods = goodsList;
            }
            return JSON.serialize(productWrapper); 

        } catch(Exception ex){
            return 'CLP_MikataProductApi.getApiRequest exception= ' + ex.getMessage();
        }
    }

    // get response by product detail object
    public static String getApiResponse(CLP_BulkProductWrapper.Goods aGoods){
        if (aGoods == null) {
            return null;
        }
        MikataConfig__c mikataConfig =  CLP_MikataConstant.mikataConfig;
        CLP_BulkProductWrapper wrap = new CLP_BulkProductWrapper();
        wrap.user_id = mikataConfig.ApiUserId__c;
        wrap.access_key = mikataConfig.ApiAccessKey__c;
        wrap.goods = new List<CLP_BulkProductWrapper.Goods>{aGoods};
        return JSON.serialize(wrap); 
    }
}