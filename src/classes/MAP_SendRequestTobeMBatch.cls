global with sharing class MAP_SendRequestTobeMBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    private List<String> companys;  
    global MAP_SendRequestTobeMBatch(List<String> listCompanys){
        companys = listCompanys;
    }

    global Iterable<String> start(Database.BatchableContext BC) {
        return companys;
    }

    global void execute(Database.BatchableContext BC, List<String> scope) {
        List<String> companyIds = (List<String>) scope;
        System.debug(companyIds);
        MAP_ConnectionSetting__c setting = MAP_ConnectionSetting__c.getInstance();
        
        if (!companyIds.isEmpty() && setting != null) {
             try{
                MAP_TobemRequestBody body = new MAP_TobemRequestBody();
                body.organizationId = UserInfo.getOrganizationId();
                body.registedTotalCount = companyIds.size();
                body.registedDate = Datetime.now();
                body.registedList = JSON.serialize(companyIds);
                String bodyJson = JSON.serialize(body);
                String result = MAP_CommonUtil.calloutRESTApiMethodPost(setting.TobeMEndpoint__c,bodyJson);
                System.debug(result);
            } catch(Exception e){
                System.debug(e);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    public class MAP_TobemRequestBody {
        public String organizationId{get;set;}
        public Integer registedTotalCount{get;set;}
        public Datetime registedDate{get;set;}
        public String registedList{get;set;}
    }
}