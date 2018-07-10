/**
 * SPP_Utils.
 * @author Mulodo VN
 * @version 1.0
 * @Description: Common class
 */
 
public with sharing class SPP_Utils {
    public static final String NAMESPACE = getNameSpace();
    public static final String ENV_PREFIX = getPrefix();
    public static final String SITE_DOMAIN = getDomain();
    public static final String SITE_TYPE = getCurrentProfile();
    //public static final String PRIVATE_KEY = '1234567890123456';
    //public enum StringType {UPPER, DIGIT, SPECIAL}
    //public static final Map<String, String> SITEMAP = getSiteMap();
    //static final String ALG_NAME = 'AES128';

   /**
    *   @Name: SPP_Utils.encryptURL
    *   @Parameter: @String data
    *   @Description: Encrypt the given data
    *   @Return: @String data after encrypted
    **/
    public static String encryptURL(String username){
        /*
        Blob data = Blob.valueOf(username);
        Blob key = Blob.valueOf(PRIVATE_KEY);
        Blob encrypted = Crypto.encryptWithManagedIV(ALG_NAME, key, data);
        return EncodingUtil.base64Encode(encrypted);
        */
        Blob data = Blob.valueOf(username);
        return EncodingUtil.base64Encode(data);
    }

    /**
    *   @Name: SPP_Utils.dencryptURL
    *   @Parameter: @String data
    *   @Description: Dencrypt the given data
    *   @Return: @String data after dencrypted
    **/
    public static String decryptURL(String encryptedUsername){
        /*
        Blob data =  EncodingUtil.base64Decode(encryptedUsername);
        Blob key = Blob.valueOf(PRIVATE_KEY);
        Blob decrypted = Crypto.decryptWithManagedIV(ALG_NAME, key, data);
        return decrypted.toString();
        */
        Blob data = EncodingUtil.base64Decode(encryptedUsername);
        return data.toString();
    }

    /**
    *   @Name: SPP_Utils.generateRandomString
    *   @Parameter: Length of string
    *   @Description: generate random string with given length
    *   @Return: @String result
    **/
    static String generateRandomString(Integer length){
        Blob b = Crypto.GenerateAESKey(128);
        String randomString = EncodingUtil.ConvertTohex(b);
        return randomString.substring(0,length);
    }

    /**
    *   @Name: SPP_Utils.generateSessionID
    *   @Parameter: None
    *   @Description: generate random string with 32 digits
    *   @Return: @String result
    **/
    public static String generateSessionID(){
        return generateRandomString(SPP_Constant.ID_DIGIT_COUNT);
    }

    /**
    *   @Name: SPP_Utils.genRandomKey
    *   @Parameter: @String value
    *   @Description: combining given value with random string
    *   @Return: @String result
    **/
    public static String genRandomKey(String keyValue){
        String randomValue = '';
        if(String.isNotBlank(keyValue)){
            Integer keyLength = keyValue.length();
            String filler = generateRandomString(keyLength);
            for(integer i = 0; i < keyLength; i++){
                randomValue += keyValue.substring(i,i+1) + filler.substring(i,i+1);
            }
        }
        return randomValue;
    }

    /**
    *   @Name: SPP_Utils.getKeyFromRandom
    *   @Parameter: @String key
    *   @Description: parse value from given key
    *   @Return: @String key
    **/
    public static String getKeyFromRandom(String randomValue){
        String keyValue = '';
        if(String.isNotBlank(randomValue)){
            for(integer i = 0; i < randomValue.length(); i++){
                if(Math.mod(i,2) == 0){
                    keyValue += randomValue.substring(i,i+1);
                }
            }
        }
        return keyValue;
    }

    /**
    *   @Name: SPP_Utils.GetUserIPAddress
    *   @Parameter: None
    *   @Description: get ip address of client
    *   @Return: @String ip address
    **/
    public static String GetUserIPAddress() {
        String returnValue = '';     
        try{
            // True-Client-IP has the value when the request is coming via the caching integration.
            returnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');
    
            // X-Salesforce-SIP has the value when no caching integration or via secure URL.
            if (String.isEmpty(returnValue)) {
                returnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            } // get IP address when no caching (sandbox, dev, secure urls)
    
            if (String.isEmpty(returnValue)) {
                returnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
            } // get IP address from standard header if proxy in use
        } catch (Exception ex) {
            System.debug('SPP_Utils.GetUserIPAddress -> could not get ip address, ex: ' + SPP_Utils.getExcMsg(ex));
        }
        return returnValue;
    }

    /**
    *   @Name: SPP_Utils.getNameSpace
    *   @Parameter: None
    *   @Description: get name space of current class
    *   @Return: @String namespace
    **/
    private static String getNameSpace(){
        if(String.isBlank(NAMESPACE)){
            ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'SPP_Utils'];
            return cs.NamespacePrefix;
        }
        return NAMESPACE;
    }

    /**
    *   @Name: SPP_Utils.getPrefix
    *   @Parameter: None
    *   @Description: generate class prefix
    *   @Return: @String class prefic
    **/
    private static String getPrefix(){
        if (String.isEmpty(NAMESPACE)){
            return '';
        }
        return NAMESPACE + '__';
    }

    /**
    *   @Name: SPP_Utils.getDomain
    *   @Parameter: None
    *   @Description: get current domain
    *   @Return: @String Current domain
    **/
    private static String getDomain(){
        if(String.isBlank(SITE_DOMAIN)){
            SPP_Domain__c domain = SPP_Domain__c.getInstance();
            if(domain != null) {
                return domain.SiteDomain__c;
            }
        }
        return SITE_DOMAIN;
    }

    /**
    *   @Name: SPP_Utils.createLog
    *   @Parameter: External user @Id, @Username , Action to log
    *   @Description: insert new log for external user
    *   @Return: Log Id
    **/
    /*public static String createLog(String extUserId, String username, String action){
        CustomLog__c log = new CustomLog__c();
        log.CustomUser__c = extUserId;   
        log.IpAddress__c = GetUserIPAddress();
        log.Content__c = username + ' ' + action;
        log.Time__c = Datetime.now();
        insert log;
        return log.Id;
    }*/

    /**
    *   @Name: SPP_Utils.createInteralLog
    *   @Parameter: Internal user @Id, @Username , Action to log
    *   @Description: insert new log for internal user
    *   @Return: Log Id
    **/
    /*public static String createInteralLog(String userId, String username, String action){
        CustomLog__c log = new CustomLog__c();
        log.InternalUser__c = userId;   
        log.IpAddress__c = GetUserIPAddress();
        log.Content__c = username + ' ' + action;
        log.Time__c = Datetime.now();
        insert log;
        return log.Id;
    }*/

    /**
    *   @Name: SPP_Utils.createSearchLog
    *   @Parameter: @Integer total records, @String soql query
    *   @Description: create content of search log
    *   @Return: log content
    **/
    /*public static String createSearchLog(Integer totalRecords, String soql){
        return ': 検索履歴 '+totalRecords +'件 :' + soql;
    }*/

    /**
    *   @Name: SPP_Utils.createCSVLog
    *   @Parameter: @Integer total records
    *   @Description: create content of csv log
    *   @Return: log content
    **/
    /*public static String createCSVLog(Integer countTotal){
        return ': CSV出力 '+countTotal+' 件';
    }*/

    /**
    *   @Name: SPP_Utils.createLogWithoutInsert
    *   @Parameter: External user @Id, @Username , Action to log
    *   @Description: create log for external user
    *   @Return: Log Id
    **/
    /*public static CustomLog__c createLogWithoutInsert(String extUserId, String username, String action){
        CustomLog__c log = new CustomLog__c();
        log.CustomUser__c = extUserId;   
        log.IpAddress__c = GetUserIPAddress();
        log.Content__c = username + ' ' + action;
        log.Time__c = Datetime.now();
        return log;
    }*/

    /**
    *   @Name: SPP_Utils.getCurrentProfile
    *   @Parameter: None
    *   @Description: get user type of current url
    *   @Return: @String user type
    **/
    private static String getCurrentProfile(){
        if(String.isBlank(SITE_TYPE)){
            System.debug('@@@ Site.getPathPrefix()= ' + Site.getPathPrefix());
            return Site.getPathPrefix();
        }
        return '';
    }

    /**
    *   @Name: SPP_Utils.getSiteMap
    *   @Parameter: None
    *   @Description: load and mapping user type and site path
    *   @Return: @Map<String, String> user type <=> site path
    **/
    /*private static Map<String, String> getSiteMap(){
        Map<String, String> temp;
        if(SITEMAP == null || SITEMAP.size() == 0){
            try{
                SPP_ObjectSearchSetting__c sm = [SELECT Setting__c FROM SPP_ObjectSearchSetting__c WHERE Name = 'SiteMap' LIMIT 1];
                temp = (Map<String, String>)System.Json.deserialize(sm.Setting__c, Map<String, String>.class);
            }catch(Exception e){
                System.debug('SPP_Utils.getSiteMap '+SPP_Utils.getExcMsg(e));
                temp = new Map<String, String>();
                //temp = new Map<String, String>{'組織長' => '/managers', '一般社員' => '/regulars'}; //userType => sitePath
            }
        }
        return temp;
    }*/

    /**
    *   @Name: SPP_Utils.removeCookie
    *   @Parameter: None
    *   @Description: set cookie data of username and session to empty
    *   @Return: None
    **/
    public static void removeCookie(){
        Cookie usernameCookie = new Cookie('SPP_Username', '', null, 0, false);
        Cookie sessionIdCookie = new Cookie('SPP_SessionId', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie, sessionIdCookie});
    }

    /**
    *   @Name: SPP_Utils.returnMainPage
    *   @Parameter: None
    *   @Description: redirect to main page
    *   @Return: Main Page
    **/
    public static PageReference returnMainPage(){
        PageReference homepage = Page.SPP_MainPage;
        homepage.setRedirect(true);
        Cookie usernamefromCookie = ApexPages.currentPage().getCookies().get('SPP_Username');
        return homepage;
    }

    /**
    *   @Name: SPP_Utils.returnLoginPage
    *   @Parameter: None
    *   @Description: redirect to login page
    *   @Return: Login Page
    **/
    public static PageReference returnLoginPage(){
        PageReference loginPage = Page.SPP_LoginPage;
        loginPage.setRedirect(true);
        return loginPage;
    }
    
    /**
    *   @Name: SPP_Utils.getExcMsg
    *   @Parameter: @Exception e
    *   @Description: Show information of exception
    *   @Return: @String error message
    **/
    public static String getExcMsg(Exception ex){
        String message = SPP_Constant.MSG_ERROR_OCCURRED;
        message += '\n';
        message += ex.getMessage();
        message += '\n';
        message += ex.getStackTraceString();
        return message;
    }

    /**
    *   @Name: SPP_Utils.findAPIVersionOfOrg
    *   @Parameter: None
    *   @Description: Get latest api version in org
    *   @Return: @Decimal api version
    **/
    public static Decimal findAPIVersionOfOrg(){
        Decimal last_api_version;
        try{
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data');
            req.setMethod('GET');

            Http h = new Http();
            HttpResponse res = h.send(req);
            List<Decimal> versionList = new List<Decimal>();
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    String fieldName = parser.getText();
                    if(fieldName == 'version'){
                        parser.nextToken(); 
                        versionList.add(Decimal.valueof(parser.getText()));
                    }
                }
            }
            versionList.sort();
            last_api_version = versionList[versionList.size()-1];
        }catch(Exception e){
            System.debug('SPP_Utils.findAPIVersionOfOrg ' + getExcMsg(e));
            last_api_version = 41.0;
        }
        return last_api_version;
    }
}