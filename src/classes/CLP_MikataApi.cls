/**
 * CLP_MikataApi.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: Common Mikata class
 */
public with sharing class CLP_MikataApi {

    public enum ApiType {F_UPSERT, F_STOP, F_UNSTOP,F_DELETE}
    private static final String HTTP_REQUEST_METHOD = 'POST';
    private static final Integer HTTP_REQUEST_TIMEOUT = Integer.valueOf(Label.CLP_HttpRequestTimeoutLabel);
    public static final String HTTP_CONNECTION_ERROR = 'http connection error';

    // public variable to call from Util class
    public static final String BILLING_BULK_UPSERT_PATH = '/api/v1.0/billing/bulk_upsert';
    public static final String BILLING_BULK_STOP_PATH = '/api/v1.0/billing/bulk_stop';
    public static final String BILLING_BULK_DOWNLOAD_PDF = '/api/v1.0/billing/bulk_download_pdf';
    public static final String GOODS_BULK_UPSERT_PATH = '/api/v1.0/goods/bulk_upsert';
    public static final String GOODS_BULK_STOP_PATH = '/api/v1.0/goods/bulk_stop';
    public static final String DEMAND_BULK_UPSERT_PATH = '/api/v1.0/demand/bulk_upsert';
    public static final String DEMAND_BULK_STOP_PATH = '/api/v1.0/demand/bulk_stop';
    public static final String DEMAND_SEARCH_PATH = '/api/v1.0/demand/search';
    public static final String BILL_UPDATE_PATH = '/api/v1.0/bill/update';
    public static final String BILL_STOP_PATH = '/api/v1.0/bill/stop';
    public static final String BILL_SEARCH_PATH = '/api/v1.0/bill/search_list';

    private static final String USER_ID_KEY = 'user_id';
    private static final String ACCESS_KEY_KEY = 'access_key';
    private static final String ERROR_KEY = 'error';
    private static final String ERROR_CODE_KEY = 'code';
    private static final String ERROR_MESSAGE_KEY = 'message';
    private static final String BILLING_KEY = 'billing';
    private static final String DEMAND_KEY = 'demand';

    private static final String CONFIG_BLANK_ERROR_MESSAGE = '請求管理ロボへの接続情報を入力してください。';
    private static final String HOST_BLANK_ERROR_MESSAGE = 'カスタム設定「経理のミカタ設定」の「APIホスト」を設定してください。';
    public MikataConfig__c mikataConfig;
    public String host;
    public String userId;
    public String accessKey;
    public String taxRate;

    // コンストラクタ
    public CLP_MikataApi() {
        mikataConfig = CLP_MikataConstant.mikataConfig;

        if (mikataConfig != null) {
            this.host = mikataConfig.ApiHost__c;
            this.userId = mikataConfig.ApiUserId__c;
            this.accessKey = mikataConfig.ApiAccessKey__c;
            this.taxRate = (mikataConfig.Tax__c == null) ? null : String.valueOf(mikataConfig.Tax__c); 
        } else {
            throw new CLP_MikataApiException(CONFIG_BLANK_ERROR_MESSAGE);
        }
        if (String.isBlank(this.host) 
            || String.isBlank(this.userId)
            || String.isBlank(this.accessKey)) {
            throw new CLP_MikataApiException(CONFIG_BLANK_ERROR_MESSAGE);
        }
    }

    // get api endpoint
    public String getEndpoint(String apiPath) {
        return this.host + apiPath;
    }
    // API実行
    public String runApi(String endpoint, String requestBody) {
        try{
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(HTTP_REQUEST_METHOD);
        request.setTimeout(HTTP_REQUEST_TIMEOUT);
        request.setBody(requestBody);

        Http h = new Http();
        HttpResponse response = h.send(request);
        system.debug(response.getBody());
        Map<String, Object> responseBodyMap = getBodyMap(response.getBody());

        String errorMessage = getErrorMessage(responseBodyMap);

        if (String.isNotBlank(errorMessage)) {            
            throw new CLP_MikataApiException(errorMessage);
        }
        return response.getBody();
        }catch(Exception ex){
            system.debug('ErrorMessage:' + ex.getMessage());
            throw ex;
            return '';
        }
    }

    private static String getErrorMessage(Map<String, Object> bodyMap) {
        //system.debug('bodyMap:'+ bodyMap);
        Map<String, Object> errorMap = (Map<String, Object>)bodyMap.get(ERROR_KEY);
        String errorMessage;
        //system.debug('errorMap:'+ errorMap);
        if (errorMap != null) {
            Integer errorCode = (Integer)errorMap.get(ERROR_CODE_KEY);
            errorMessage = String.valueOf(errorCode) + ': ' + (String)errorMap.get(ERROR_MESSAGE_KEY);
        }
        return errorMessage;
    }

    // レスポンスをApexオブジェクトに変換する
    private static Map<String, Object> getBodyMap(String jsonBody) {
        return (Map<String, Object>)Json.deserializeUntyped(jsonBody);
    }
    
    // send email complete batch to user
    public static void sendEmailComplete(String emailTemplate,String className){
        try{
            List<Logger__c> logs = [Select Id,Name,Request__c,Response__c,Content__c,Operation__c,CreatedDate,CreatedBy.Name,Origin__c,
                                    LK_DemandDetail__c,LK_RelatedUser__c,LK_RelatedUser__r.Name,LK_RelatedUser__r.Email from Logger__c where LK_RelatedUser__c != null
                                    and Origin__c =: className order by LK_RelatedUser__c /*limit 100*/];
            if(logs.isEmpty())
                return;
            String userId = '';
            //String userEmail = '';
            // get log by user
            Map<String,List<Logger__c>> mapLogs = new Map<String,List<Logger__c>>();
            List<Logger__c> logByUser;
            Integer cnt = 0;
            // loop log and determine log per user
            for(Logger__c l : logs){
                cnt++;
                // reset list logger by user
                if(userId != String.valueOf(l.LK_RelatedUser__c)){
                    if(logByUser!=null && !logByUser.isEmpty()){
                        mapLogs.put(userId,logByUser);
                    }
                    logByUser = new List<Logger__c>();
                    userId = l.LK_RelatedUser__c;
                }
                if(logByUser!=null){
                    logByUser.add(l);
                    // put last log by user id
                    if(cnt == logs.size()){
                        mapLogs.put(userId,logByUser);
                    }
                }
            }

            // send Email to User
            EmailTemplate mail = [Select Id,Body,Subject from EmailTemplate Where DeveloperName =: emailTemplate limit 1];
            
            for(String us : mapLogs.keySet()){
                List<Logger__c> csvLogs = mapLogs.get(us);
                // create CSV file
                Id csvId = CLP_LoggerUtil.createCsv(csvLogs);
                CLP_LoggerUtil.deleteLogs(csvLogs);
                // keyMaps binding into Email
                Map<String,String> keyMaps = new Map<String,String>();
                
                CLP_LoggerUtil.sendEmail(csvId,us,mail,keyMaps);                
                // remove log file
                if(!CLP_MikataConstant.mikataConfig.DebugLogFlag__c)
                    CLP_LoggerUtil.deleteDocument(csvId);
            }
        }catch(Exception ex){
            system.debug('Error: Send Email failed '+ex.getMessage());
        }
    }
}