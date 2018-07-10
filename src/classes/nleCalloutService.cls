public class nleCalloutService
{
    public static nleCalloutResult up_getToken(Nle_Org_Config__c orgConfig) {
        nleCalloutResult result = new nleCalloutResult('up_getToken');
        String base_URL = nleMetadataObjectConstant.SFDC_AUTH;
        base_URL += '/token?';
        base_URL += 'grant_type=password&';
        base_URL += '&client_id=' + EncodingUtil.urlEncode(orgConfig.Client_Id__c, 'UTF-8');
        base_URL += '&client_secret=' + EncodingUtil.urlEncode(orgConfig.Client_Secret__c, 'UTF-8');
        base_URL += '&username=' + EncodingUtil.urlEncode(orgConfig.Username__c, 'UTF-8');
        base_URL += '&password=' + EncodingUtil.urlEncode(orgConfig.Password__c, 'UTF-8');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setMethod('POST');
        req.setTimeout(60000);
        Http http = new Http();
        
        system.debug('ConnectToOrg base_URL: ' + base_URL);
        
        
        try {
            string responseBody = '';
        //system.debug(req);[]
            HttpResponse res = http.send(req);
        //    System.debug(res);
            responseBody = res.getBody();
            //system.debug(responseBody);
            
            NleToken tokenObject = (NleToken)(JSON.deserialize(responseBody, NleToken.class));
            orgConfig.Environment_URL__c = tokenObject.instance_url;
            orgConfig.Access_Token__c = tokenObject.access_token;
            Integer sectionTimeout = orgConfig.Session_Timeout__c == null ? 120 : Integer.valueOf(orgConfig.Session_Timeout__c);
            orgConfig.Token_Expire_On__c = system.now().addMinutes(sectionTimeout).addSeconds(-1);
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;   
                result.data = tokenObject;
            } else {
                result.hasError = true;
                result.error_message = tokenObject.error + '. ' + tokenObject.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        
        }
        system.debug(result);
        
        return result;
    }
    
    //@future (callout=true)
    public static nleCalloutResult getObjects(Nle_Org_Config__c orgConfig) {
        nleCalloutResult result = new nleCalloutResult('getObjects');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/';
        base_URL += 'sobjects';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        system.debug('getObjects base_URL: ' + base_URL);
        
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            //System.debug(responseBody);
            
            nleCalloutJSONObjects objs = (nleCalloutJSONObjects)(JSON.deserialize(responseBody, nleCalloutJSONObjects.class));
            result.data = objs;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = objs.error + '. ' + objs.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        
        system.debug('getObjects result:' + result);
        system.debug('getObjects data:' + result.data);
        
        return result;
    }
    
    public static nleCalloutResult getObject(Nle_Org_Config__c orgConfig,String objectName){
        nleCalloutResult result = new nleCalloutResult('GetObject');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/sobjects/';
        base_URL += objectName;
        base_URL += '/describe';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        system.debug('getObject base_URL: ' + base_URL);
        
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            //System.debug(responseBody);
            
            nleCalloutJSONObject objs = (nleCalloutJSONObject)(JSON.deserialize(responseBody, nleCalloutJSONObject.class));
            result.data = objs;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = objs.error + '. ' + objs.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        
        system.debug('getObject result:' + result);
        system.debug('getObject data:' + result.data);
        
        return result;
    }
    
    //get all validation rule in org
    public static nleCalloutResult getValidationRules(Nle_Org_Config__c orgConfig) {
        nleCalloutResult result = new nleCalloutResult('getValidationRules');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/tooling/query';
        base_URL += '?q=Select+Id+,+EntityDefinition.QualifiedApiName+From+ValidationRule';
        system.debug(orgConfig);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        system.debug('getValidationRules base_URL: ' + base_URL);
        //system.debug('getValidationRules req: ' + req);
        
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            System.debug(res);
            
            Tools_ValidationRule objs = (Tools_ValidationRule)(JSON.deserialize(responseBody, Tools_ValidationRule.class));
            result.data = objs;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = objs.error + '. ' + objs.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        
        system.debug('getValidationRules result:' + result);
        system.debug('getValidationRules data:' + result.data);
        
        return result;
    }

    //get validation rule detail
    //get all validation rule in org
    public static nleCalloutResult getValidationRuleDetail(Nle_Org_Config__c orgConfig,String url) {
        nleCalloutResult result = new nleCalloutResult('getValidationRuleDetail');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += url;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        //system.debug('getValidationRuleDetail base_URL: ' + base_URL);
        //system.debug('getValidationRules req: ' + req);
        
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            System.debug('getValidationRuleDetail: '+ res);
            
            Tools_ValidationRuleDetail objs = (Tools_ValidationRuleDetail)(JSON.deserialize(responseBody, Tools_ValidationRuleDetail.class));
            result.data = objs;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = objs.error + '. ' + objs.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        
        //system.debug('Tools_ValidationRuleDetail result:' + result);
        //system.debug('Tools_ValidationRuleDetail data:' + result.data);
        
        return result;
    }
    // get list profile
    public static nleCalloutResult getProfiles(Nle_Org_Config__c orgConfig){
        nleCalloutResult result = new nleCalloutResult('getProfile');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/tooling/query';
        base_URL += '?q=Select+Id+,+Name+,+description+From+Profile';
        system.debug(orgConfig);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        system.debug('getProfile base_URL: ' + base_URL);
        //system.debug('getValidationRules req: ' + req);
        
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            System.debug(res);
            
            Tools_calloutJSONProfiles profiles = (Tools_calloutJSONProfiles)(JSON.deserialize(responseBody, Tools_calloutJSONProfiles.class));
            result.data = profiles;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = profiles.error + '. ' + profiles.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        
        system.debug('getProfile result:' + result);
        system.debug('getProfile data:' + result.data);
        
        return result;
    }
    // get profile detail
    public static nleCalloutResult getProfile(Nle_Org_Config__c orgConfig,String profileId){
        nleCalloutResult result = new nleCalloutResult('getProfile data');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/tooling/sobjects/Profile/'+profileId;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            System.debug('Profile Detail===='+res);
            
            Tools_calloutJSONProfile objs = (Tools_calloutJSONProfile)(JSON.deserialize(responseBody, Tools_calloutJSONProfile.class));
            result.data = objs;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = objs.error + '. ' + objs.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        return result;
    }

    /* Begin Tuan 29/08/17 */
    // Get List Permission Set
    public static nleCalloutResult getPermissionSets(Nle_Org_Config__c orgConfig){
        // Init result
        nleCalloutResult result = new nleCalloutResult('getPermissionSets');
        
        // Connect to org
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        // Init request URL
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/tooling/query';
        base_URL += '?q=Select+Id+,+Label+,+Name+,+description+From+PermissionSet+where+ProfileId+=+null';
        system.debug(orgConfig);

        // Init Request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        system.debug('getPermissionSets base_URL: ' + base_URL);

        // Get response
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            System.debug(res);
            
            Tools_calloutJSONPermissionSets permissionSets = (Tools_calloutJSONPermissionSets)(JSON.deserialize(responseBody, Tools_calloutJSONPermissionSets.class));
            result.data = permissionSets;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = permissionSets.error + '. ' + permissionSets.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        
        system.debug('getPermissionSet result:' + result);
        system.debug('getPermissionSet data:' + result.data);
        
        return result;
    }
    /* End Tuan 29/08/17 */

    /* 30/08/17 Tuan */
    // Get permission set detail
    public static nleCalloutResult getPermissionSet(Nle_Org_Config__c orgConfig,String permissionSetId){
        nleCalloutResult result = new nleCalloutResult('getPermissionSet data');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/tooling/sobjects/PermissionSet/'+permissionSetId;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            System.debug('PermissionSet Detail===='+res);
            
            Tools_calloutJSONPermissionSet objs = (Tools_calloutJSONPermissionSet)(JSON.deserialize(responseBody, Tools_calloutJSONPermissionSet.class));
            result.data = objs;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = objs.error + '. ' + objs.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        return result;
    }
    /* 30/08/17 Tuan */

    // get object permission
    public static nleCalloutResult getObjectPermission(Nle_Org_Config__c orgConfig,String profileId,String objectList){
        nleCalloutResult result = new nleCalloutResult('objectPermission data');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/query?q=';
        base_URL += 'SELECT+Id+,+ParentId+,+SobjectType+,+PermissionsRead+,+PermissionsCreate+';
        base_URL += ',+PermissionsEdit+,+PermissionsDelete+,+PermissionsViewAllRecords+';
        base_URL += ',+PermissionsModifyAllRecords+,+Parent.ProfileId+FROM+ObjectPermissions+';
        base_URL += 'where+SobjectType+in+('+objectList+')'+'+and+Parent.ProfileId+=+\''+profileId+'\'';
        system.debug(base_URL);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            
            Tools_calloutJSONPermissionObjects objs = (Tools_calloutJSONPermissionObjects)(JSON.deserialize(responseBody, Tools_calloutJSONPermissionObjects.class));
            result.data = objs;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = objs.error + '. ' + objs.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        system.debug(result);
        return result;
    }

    /* 31/08/17 Tuan */
    // get object permission for permission set
    // orgConfig: current Org
    // parentId: Permission Set - Profile Id
    // objectList: Selected objects
    public static nleCalloutResult getObjectPermissionByParentId(Nle_Org_Config__c orgConfig,String parentId,String objectList){
        nleCalloutResult result = new nleCalloutResult('objectPermission data');
        
        nleCalloutResult connect = getConnect(orgConfig);
        if (connect.hasError) {
            return connect;
        }
        
        // Init http request to get settings for selected objects of permission set with id = parentId  
        String base_URL = orgConfig.Environment_URL__c;
        base_URL += '/services/data/v37.0/query?q=';
        base_URL += 'SELECT+Id+,+ParentId+,+SobjectType+,+PermissionsRead+,+PermissionsCreate+';
        base_URL += ',+PermissionsEdit+,+PermissionsDelete+,+PermissionsViewAllRecords+';
        base_URL += ',+PermissionsModifyAllRecords+,+Parent.ProfileId+FROM+ObjectPermissions+';
        base_URL += 'where+SobjectType+in+('+objectList+')'+'+and+ParentId+=+\''+parentId+'\'';
        system.debug(base_URL);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(base_URL);
        req.setHeader('Authorization', 'Bearer ' + orgConfig.Access_Token__c);
        req.setMethod('GET');
        req.setTimeout(60000);
        try {
            string responseBody = '';
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            
            Tools_calloutJSONPermissionObjects objs = (Tools_calloutJSONPermissionObjects)(JSON.deserialize(responseBody, Tools_calloutJSONPermissionObjects.class));
            result.data = objs;
            
            if (res.getStatusCode() == 200) {
                result.hasError = false;
            } else {
                result.hasError = true;
                result.error_message = objs.error + '. ' + objs.error_description;
            }
        } 
        catch (Exception ex) {
            result.hasError = true;
            result.error_message = ex.getMessage();
        }
        system.debug(result);
        return result;
    }
    /* 31/08/17 Tuan End */

    /**************************** Private methods ****************************/ 
    
    private static nleCalloutResult getConnect(Nle_Org_Config__c orgConfig) {
        nleCalloutResult result = new nleCalloutResult('getConnect');
        
        if (String.isEmpty(orgConfig.Access_Token__c)) {
            result.hasError = true;
            result.error_message = 'Connection issue. Plz try re-connect!';
        }
        //system.debug(orgConfig);
        if (orgConfig.Token_Expire_On__c < system.now()) {//up_getToken
            //if (orgConfig.RecordType.Name == nleMetadataObjectConstant.UA_FLOW 
            //    && String.isNotEmpty(orgConfig.Client_Id__c)) {
            //        result = ua_refreshToken(orgConfig);
            //    } else 
            if (orgConfig.RecordType.Name == nleMetadataObjectConstant.UP_FLOW 
                       && String.isNotEmpty(orgConfig.Client_Id__c)
                       && String.isNotEmpty(orgConfig.Client_Secret__c)
                       && String.isNotEmpty(orgConfig.Username__c)
                       && String.isNotEmpty(orgConfig.Password__c)) {
                           result = up_getToken(orgConfig);
                       }
        }       
        
        return result;
    }
    
    /******* RefreshToken For User-Agent OAuth Authentication Flow Implementation *********/ 
    //private static nleCalloutResult ua_refreshToken(Nle_Org_Config__c orgConfig) {
    //    nleCalloutResult result = new nleCalloutResult('refreshToken');
        
    //    if (orgConfig == null || String.isEmpty(orgConfig.Access_Token__c)) {
    //        result.hasError = true;
    //        result.error_message = 'RefreshToken. Org Config issue';
    //        return result;
    //    }
        
    //    if (orgConfig.Token_Expire_On__c >= system.now()) {
    //        return result;
    //    }
        
    //    Http http = new Http();
    //    HttpRequest req = new HttpRequest();
        
    //    String base_URL = nleMetadataObjectConstant.SFDC_AUTH;
    //    base_URL += '/grant_type=refresh_token';
    //    base_URL += '/grant_type=refresh_token';
    //    base_URL += '&refresh_token=' + EncodingUtil.urlEncode(orgConfig.Refresh_Token__c, 'UTF-8');
    //    base_URL += '&client_id=' + EncodingUtil.urlEncode(orgConfig.Client_Id__c, 'UTF-8');
    //    base_URL += '&client_secret=' + EncodingUtil.urlEncode(orgConfig.Client_Secret__c, 'UTF-8');
        
    //    req.setEndpoint(base_URL);
    //    req.setMethod('POST');
    //    req.setTimeout(60000);
        
    //    system.debug('refreshToken base_URL: ' + base_URL);
        
    //    try {
    //        string responseBody = '';
    //        HttpResponse res = http.send(req);
    //        responseBody = res.getBody();
    //        System.debug(responseBody);
            
    //        NleToken tokenObject = (NleToken)(JSON.deserialize(responseBody, NleToken.class));
    //        result.data = tokenObject;
            
    //        if (res.getStatusCode() == 200) {
    //            result.hasError = false;   
    //        } else {
    //            result.hasError = true;
    //            result.error_message = tokenObject.error + '. ' + tokenObject.error_description;
    //        }
    //    } 
    //    catch (Exception ex) {
    //        result.hasError = true;
    //        result.error_message = ex.getMessage();
    //    }
        
    //    system.debug(result);
        
    //    return result;
    //}
}