/* 
Created By: Rinkitori Tam
Created Date: 12/03/2017
Description: Tool Export Detail Design (Controller Export DD)
*/
global with sharing class Tools_ExportDetailDesignCC {
	public string BLANKVALUE {get;set;}
    public string HEADER_1 {
        get{ return '#000080';}
        set;
    }
    public string HEADER_2 {
        get{ return '#c1c1c1';}
        set;
    }
    public string HEADER_3 {
        get{ return '#f1f1f1';}
        set;
    }       
    public string HEADER_4 {
        get{ return '#FE9A00';}
        set;
    }

    private List<SelectOption> orgConfigSelectOptions;
    // current org
    public Nle_Org_Config__c currentOrgConfig {get;set;}
    // list object detail
    private List<nleCalloutJSONObject> jObjectDetails {get;set;}
    // list profile detail
    private List<Tools_calloutJSONProfile> jProfileDetails{get;set;}
    /* 30/08/17 Tuan */
    // list permission set detail
    private List<Tools_calloutJSONPermissionSet> jPermissionSetDetails{get;set;}
    /* 30/08/17 Tuan */
    // list object has been callout from sf API
    public List<JObject> jObjects {get;set;}
    // list profile has been callout from sf API
    public List<JProfile> jProfiles {get;set;}
    // list current Object has been selected to export
    public Set<String> currentSelectedObjects {get;set;}
    // list validation rule
    public List<Tools_ValidationRuleDetail> validationRuleDetails{get;set;}  
    public Id currentOrgConfigId {get;set;}

    public Set<String> defaultUserPermissions{get;set;}
    // profile user permission
    public List<Map_Object.ProfileUserPermission> profilePermissions{get;set;}  
    // profile standard object permission
    public List<Map_Object.ObjectPermission> standardObjectPermissons{get;set;}
    // profile custom object permission
    public List<Map_Object.ObjectPermission> customObjectPermissons{get;set;}

    /* 31/08/17 Tuan */
    // permission set user permission
    public List<Map_Object.ObjectPermission> objectSettings{get;set;}  
    /* 31/08/17 Tuan Eng*/

    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    } 
    //constructor
    public Tools_ExportDetailDesignCC() {
        PageReference currentPage = ApexPages.currentPage();
        String currentUrl = currentPage.getUrl();
        String orgConfigId = currentPage.getParameters().get('state');
        system.debug(orgConfigId);
        if(String.isNotBlank(orgConfigId)){
            // Tuan 29/08/17
            // Add Selected_Permission_Sets
            currentOrgConfig = [SELECT Id, Name, Client_Id__c,Refresh_Token__c, Client_Secret__c, Username__c, Password__c, Redirect_URL__c,
                                Access_Token__c, Token_Expire_On__c, Environment_URL__c, Selected_Objects__c,Selected_Profile__c, 
                                Selected_Permission_Sets__c, RecordType.Name
                                FROM Nle_Org_Config__c Where Id =: orgConfigId limit 1];
        }        
    }
    // get current org has been save in database
    public List<SelectOption> getOrgs(){    	
    	currentSelectedObjects = new Set<String>();
        
        // Tuan 29/08/17
        // Add Selected_Permission_Sets
        Map<String, Nle_Org_Config__c> orgConfigs = new Map<String, Nle_Org_Config__c>([SELECT Id, Name, Client_Id__c,Refresh_Token__c, Client_Secret__c, Username__c, Password__c, Redirect_URL__c,
                                                         Access_Token__c, Token_Expire_On__c, Environment_URL__c, Selected_Objects__c,Selected_Profile__c, 
                                                         Selected_Permission_Sets__c, RecordType.Name
                                                         FROM Nle_Org_Config__c ORDER BY CreatedDate]);
        
        this.orgConfigSelectOptions = new List<SelectOption>();
        this.orgConfigSelectOptions.add(new SelectOption('', 'None'));
        for (Nle_Org_Config__c orgConfig : orgConfigs.values()) {
            this.orgConfigSelectOptions.add(new SelectOption(orgConfig.id, orgConfig.Name));
        }
        return orgConfigSelectOptions;
    }

    /* 29/08/17 
       Tuan Add JpermissionSet List */
    @RemoteAction
    global static Tools_JsonResult connectToOrg(Id orgConfigId){
        //system.debug('start connect');
        // 29/08/17 Tuan 
        // Add Selected_Permission_Sets
        Nle_Org_Config__c currentOrgConfig = [SELECT Id, Name, Client_Id__c,Refresh_Token__c, Client_Secret__c, Username__c, Password__c, Redirect_URL__c,
                                                         Access_Token__c, Token_Expire_On__c, Environment_URL__c, Selected_Objects__c,Selected_Profile__c, 
                                                         Selected_Permission_Sets__c, RecordType.Name
                                                         FROM Nle_Org_Config__c Where Id =: orgConfigId limit 1];
        List<JObject> jObjects;
        List<JProfile> jProfiles;
        // Tuan Add jPermissionSets
        List<JPermissionSet> jPermissionSets;

        system.debug('action:'+currentOrgConfig);
        if (currentOrgConfig != null) {                            
            if (String.isNotEmpty(currentOrgConfig.Access_Token__c)) {
                jObjects = getObjects(currentOrgConfig);
                jProfiles = getProfiles(currentOrgConfig);
                // 29/08/17 Tuan
                jPermissionSets = getPermissionSets(currentOrgConfig);
                //update new orgConfig
                system.debug(currentOrgConfig);
                UPDATE currentOrgConfig;                
            } else if (currentOrgConfig.RecordType.Name == nleMetadataObjectConstant.UP_FLOW 
        		   && String.isNotEmpty(currentOrgConfig.Client_Id__c)
                   && String.isNotEmpty(currentOrgConfig.Client_Secret__c)
                   && String.isNotEmpty(currentOrgConfig.Username__c)
                   && String.isNotEmpty(currentOrgConfig.Password__c)){
            	if(connectWithUserPassword(currentOrgConfig)){
                    jObjects = getObjects(currentOrgConfig);
                    jProfiles = getProfiles(currentOrgConfig);
                    /* 29/08/17 Tuan */
                    jPermissionSets = getPermissionSets(currentOrgConfig);
                    /* 29/08/17 Tuan */
                    UPDATE currentOrgConfig;
                }else{
                    return new Tools_JsonResult(true,'Has error when connect with OAuth-UserPass!',null,null, null);
                }                
            } else {
            	return new Tools_JsonResult(true,'can\'t connect to this org!',null,null, null);           
            }                
        }    	
        //system.debug('success: '+jObjects);
        //getJProfileDetail();
    	return new Tools_JsonResult(false,'',jObjects,jProfiles, jPermissionSets);
    }
    // get Profiles has been callout from Orgs
    public static List<JProfile> getProfiles(Nle_Org_Config__c org) {        
        if (org == null) {
            return null;
        }        
        nleCalloutResult result = nleCalloutService.getProfiles(org);
        List<JProfile> jProfiles = new List<JProfile>();
        if (!result.hasError && result.data!=null) {
            Tools_calloutJSONProfiles pro = (Tools_calloutJSONProfiles) result.data;
            if (pro != null && pro.records!=null) {
                for (Tools_calloutJSONProfiles.JSONProfile obj : pro.records) {
                    jProfiles.add(new JProfile(obj, org.Selected_Profile__c));
                }
            }            
            //UPDATE org;
        } else {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.status + '. ' + result.error_message));
            return null;
        }        
        return jProfiles;
    }

    /* Tuan 29/08/17 */
    // get Permission Set has been callout from Orgs
    public static List<JPermissionSet> getPermissionSets(Nle_Org_Config__c org) {        
        if (org == null) {
            return null;
        }        

        nleCalloutResult result = nleCalloutService.getPermissionSets(org);
        /*system.debug('getPermissionSets: ' + result);*/
        List<JPermissionSet> jPermissionSets = new List<JPermissionSet>();
        if (!result.hasError && result.data != null) {
            Tools_calloutJSONPermissionSets pro = (Tools_calloutJSONPermissionSets) result.data;
            if (pro != null && pro.records!=null) {
                for (Tools_calloutJSONPermissionSets.JSONPermissionSet obj : pro.records) {
                    jPermissionSets.add(new JPermissionSet(obj, org.Selected_Permission_Sets__c));
                }
            }            
        } else {
            return null;
        }        
        return jPermissionSets;
    }
    /* Tuan 29/08/17 */

    // get Object has been callout from Orgs
    public static List<JObject> getObjects(Nle_Org_Config__c org) {        
        if (org == null) {
            return null;
        }        
        nleCalloutResult result = nleCalloutService.getObjects(org);
        List<JObject> jObjects;
        if (!result.hasError && result.data!=null) {
            jObjects = new List<JObject>();
            nleCalloutJSONObjects data = (nleCalloutJSONObjects) result.data;
            system.debug('debug:' +data.sobjects);
            if (data != null && data.sobjects!=null) {
                for (nleCalloutJSONObjects.JSONObjects obj : data.sobjects) {
                    jObjects.add(new JObject(obj, org.Selected_Objects__c));
                }
            }            
            //UPDATE org;
        }      
        return jObjects;
    }
    // connect with OAuth-UserPass
    public static Boolean connectWithUserPassword(Nle_Org_Config__c org){
       nleCalloutResult result = nleCalloutService.up_getToken(org);
       if (!result.hasError) {                                      
           return true;
       } else {
           return false;
       }
    }    

    // Save configuration of current org
    @RemoteAction
    global static Tools_JsonResult saveConfig(String currentOrg,String objects,String profiles, string permissionSets){
        try{
        //system.debug(objects);
        /* 30/08/17 Tuan */
        // Add Selected_Permission_Sets__c
        Nle_Org_Config__c org = [Select Id,Selected_Objects__c,Selected_Profile__c, Selected_Permission_Sets__c 
                                    From Nle_Org_Config__c Where Id =: currentOrg
                                    limit 1];
        org.Selected_Objects__c = objects;
        org.Selected_Profile__c = profiles;
        org.Selected_Permission_Sets__c = permissionSets;
        /* 30/08/17 Tuan */
        UPDATE org;
        return new Tools_JsonResult(false,'',null,null,null);
        }
        catch(QueryException ex){
            return new Tools_JsonResult(true,ex.getMessage(),null,null,null);
        }
    }
    // get Object Details in current Orgs
    public List<nleCalloutJSONObject> getJObjectDetails() {
        //this.getJProfileDetail();
        
        this.jObjectDetails = new List<nleCalloutJSONObject>();
        if (currentOrgConfig!= null && string.isNotEmpty(currentOrgConfig.Selected_Objects__c)) {
            system.debug(currentOrgConfig.Selected_Objects__c);
            List<String> objectNames = currentOrgConfig.Selected_Objects__c.split(';');
            for (String objectName : objectNames) {
                nleCalloutResult result = nleCalloutService.getObject(this.currentOrgConfig, objectName);
                if (!result.hasError) {
                    //System.debug('result.data: ' + result.data);
                    nleCalloutJSONObject data = (nleCalloutJSONObject) result.data;
                    List<nleCalloutJSONObject.Fields> fieldsNotManage = new List<nleCalloutJSONObject.Fields>();
                    for(nleCalloutJSONObject.Fields f : data.fields){
                        // not manged package fields
                        //if(f.name.split('__').size()>2){
                        //    continue;
                        //}
                        fieldsNotManage.add(f);
                    }
                    data.fields = fieldsNotManage;
                    jObjectDetails.add(data);
                }
            }
        }        
        //remove recordType Master
        for(nleCalloutJSONObject obj: jObjectDetails){
            integer cnt = 0;
            List<Tools_ValidationRuleDetail> validationRules = new List<Tools_ValidationRuleDetail>();
            //this.getValidationRuleDetail();
            validationRuleDetails = new List<Tools_ValidationRuleDetail>();
            if(validationRuleDetails.size()>0){
                for(Tools_ValidationRuleDetail rule: validationRuleDetails){
                    if(obj.name == rule.objectName){
                        validationRules.add(rule);
                    }
                }
                if(validationRules.size()>0){
                    obj.validationRules = validationRules;
                }
            }            
            /*if(obj.recordTypeInfos.size()>0){
                //remove recordType master
                for(nleCalloutJSONObject.RecordTypeInfos rt : obj.recordTypeInfos){
                    if(rt.name=='Master'){
                        break;
                    } 
                    cnt++;                
                }
                obj.recordTypeInfos.remove(cnt);
            }*/
        }
        system.debug('jObjectDetails: ' + jObjectDetails);
        return this.jObjectDetails;
    }	

    // Get Profile details in current org
    public List<Tools_calloutJSONProfile> getJProfileDetails(){
        try{
            system.debug('at here');
            this.jProfileDetails = new List<Tools_calloutJSONProfile>();
            if (currentOrgConfig!= null && string.isNotEmpty(currentOrgConfig.Selected_Profile__c)) {
                //system.debug(currentOrgConfig.Selected_Profile__c);
                List<String> profile = currentOrgConfig.Selected_Profile__c.split(';');
                for (String p : profile) {
                    nleCalloutResult result = nleCalloutService.getProfile(this.currentOrgConfig, p);
                    if (!result.hasError) {
                        //System.debug('result.data: ' + result.data);
                        this.jProfileDetails.add((Tools_calloutJSONProfile) result.data);
                    }
                }
            }           
            this.getDefaultUserPermissions();
            this.getProfileUserPermission();
            this.getProfileObjectPermission();
            return this.jProfileDetails;
        }
        catch (Exception ex){
            system.debug('lỗi getJProfileDetails:' + ex.getMessage());
            return null;
        }        
    }

    /* 30/08/17 Tuan */
    // Permission Set Details in current org
    public List<Tools_calloutJSONPermissionSet> getJPermissionSetDetails(){
        try{
            system.debug('at here');
            this.jPermissionSetDetails = new List<Tools_calloutJSONPermissionSet>();
            if (currentOrgConfig!= null && string.isNotEmpty(currentOrgConfig.Selected_Permission_Sets__c)) {
                //system.debug(currentOrgConfig.Selected_Profile__c);
                List<String> permissionSet = currentOrgConfig.Selected_Permission_Sets__c.split(';');
                for (String p : permissionSet) {
                    nleCalloutResult result = nleCalloutService.getPermissionSet(this.currentOrgConfig, p);
                    if (!result.hasError) {
                        //System.debug('result.data: ' + result.data);
                        this.jPermissionSetDetails.add((Tools_calloutJSONPermissionSet) result.data);
                    }
                }
            }           
            this.getObjectSettings();
            return this.jPermissionSetDetails;
        }
        catch (Exception ex){
            system.debug('lỗi jPermissionSetDetails:' + ex.getMessage());
            return null;
        }        
    }    
    /* 30/08/17 Tuan */

    // get default user permissions
    public Set<String> getDefaultUserPermissions(){
        try{
            defaultUserPermissions = new Set<String>();
            if(this.jProfileDetails.size()==0){
                return defaultUserPermissions;
            }        
            for(Tools_calloutJSONProfile profile : jProfileDetails){
                for(Tools_calloutJSONProfile.UserPermissions u: profile.Metadata.userPermissions){
                   if(!defaultUserPermissions.contains(u.Name)){
                        defaultUserPermissions.add(u.Name);                    
                    }
                }
            }
            return defaultUserPermissions;
        }catch(Exception ex){
            system.debug('lỗi getDefaultUserPermissions:' + ex.getMessage());
            return null;
        }
    }
    // re-index for Userpermission
    public List<Map_Object.ProfileUserPermission> getProfileUserPermission(){
        try{
            profilePermissions = new List<Map_Object.ProfileUserPermission>();
            for(String permission : defaultUserPermissions){
                Map_Object.ProfileUserPermission mObject = new Map_Object.ProfileUserPermission();
                mObject.name = permission;
                List<Boolean> lstChecked = new List<Boolean>();
                for(Tools_calloutJSONProfile profile : this.jProfileDetails){
                    Boolean isValidPermission = false;
                    Set<Tools_calloutJSONProfile.UserPermissions> permissions = new Set<Tools_calloutJSONProfile.UserPermissions>(profile.Metadata.userPermissions);
                    //get all permission from profile permission
                    for(Tools_calloutJSONProfile.UserPermissions p : permissions){
                        if(p.Name==permission){
                            lstChecked.add(p.enabled);
                            isValidPermission = true;
                            break;                    
                        }
                    }
                    if(!isValidPermission){
                        lstChecked.add(false);
                    }
                    mObject.isChecked = lstChecked;
                }
                profilePermissions.add(mObject);
            }
            //system.debug(profilePermissions);
            return profilePermissions; 
        }catch(Exception ex){
            system.debug('lỗi getProfileUserPermission:' + ex.getMessage());
            return null;
        }       
    }    
    public void getValidationRuleDetail(){
        try{
            validationRuleDetails = new List<Tools_ValidationRuleDetail>();
            Tools_ValidationRule validationRules = new Tools_ValidationRule();
            if(currentOrgConfig!=null){
                nleCalloutResult result = nleCalloutService.getValidationRules(currentOrgConfig);
                if (!result.hasError) {
                    validationRules = (Tools_ValidationRule) result.data;
                    //system.debug('record size:' +validationRules.Records.size());
                }
                if(validationRules!=null){
                    for(Tools_ValidationRule.Records record : validationRules.records){
                        result = nleCalloutService.getValidationRuleDetail(currentOrgConfig,record.attributes.url);
                        if (!result.hasError) {
                            Tools_ValidationRuleDetail validationDetail = (Tools_ValidationRuleDetail) result.data;
                            validationDetail.objectName = record.EntityDefinition.QualifiedApiName;
                            validationRuleDetails.add(validationDetail);
                        }
                    }
                }
            }
            system.debug('validationRuleDetails: ' + validationRuleDetails);
        }catch(Exception ex){
            system.debug('lỗi ValidationRuleDetail:' + ex.getMessage());
        }
        //system.debug(validationRuleDetails);        
        //return validationRuleDetails;
    }

    public void getProfileObjectPermission(){
        try{
            standardObjectPermissons = new List<Map_Object.ObjectPermission>();
            customObjectPermissons = new List<Map_Object.ObjectPermission>();
            if (currentOrgConfig!= null 
                && string.isNotEmpty(currentOrgConfig.Selected_Profile__c)
                && string.isNotEmpty(currentOrgConfig.Selected_Objects__c)) {
                String selectObjects = '';
                for(String obj : currentOrgConfig.Selected_Objects__c.split(';')){
                    selectObjects += string.isNotEmpty(selectObjects) ? ',\'' + obj + '\'' : '\'' + obj + '\'';
                }
                
                List<String> profile = currentOrgConfig.Selected_Profile__c.split(';');
                //system.debug(profile);
                List<Tools_calloutJSONPermissionObjects> permissionObjects = new List<Tools_calloutJSONPermissionObjects>();
                for (String p : profile) {
                    nleCalloutResult result = nleCalloutService.getObjectPermission(this.currentOrgConfig, p,selectObjects);
                    if (!result.hasError) {
                        //System.debug('result.data: ' + result.data);
                        permissionObjects.add((Tools_calloutJSONPermissionObjects) result.data);
                    }
                }
                // list permission Object return form api
                if(permissionObjects.size()>0){
                    // map object with permission will be show on excel file
                    Map_Object.ObjectPermission op;
                    // loop all object has been selected before
                    for(String obj : currentOrgConfig.Selected_Objects__c.split(';')){
                        op = new Map_Object.ObjectPermission();
                        op.objectName = obj;
                        op.isCustom = obj.indexOf('__c') > 1;
                        List<String> permissions = new List<String>();                    
                        for(Tools_calloutJSONPermissionObjects json : permissionObjects){
                            String permis = '';                       
                            if(!isExistItem(json.records,obj)){
                                permissions.add(permis);
                                continue;
                            }                                                                   
                            for(Tools_calloutJSONPermissionObjects.Records record : json.records){
                                if(obj == record.SobjectType){
                                    if(record.Id.indexOf('1102800')>-1){
                                        continue;
                                    }
                                    permis += record.PermissionsCreate ? 'C' : '';
                                    permis += record.PermissionsRead ? 'R' : '';
                                    permis += record.PermissionsEdit ? 'U' : '';
                                    permis += record.PermissionsDelete ? 'D' : '';
                                    permis += record.PermissionsViewAllRecords ? ' ViewAll' : '';
                                    permis += record.PermissionsModifyAllRecords ? ',ModifyAll' : '';
                                    permissions.add(permis);                                
                                    break;
                                }
                            }
                        }
                        op.permissions = permissions;
                        system.debug(permissions);
                        // fill data to map objectpermission
                        if(op.isCustom){
                         customObjectPermissons.add(op);
                        }
                        else{
                         standardObjectPermissons.add(op);
                        }
                    }                
                }
            }      
        }catch(Exception ex){
            system.debug('lỗi getProfileObjectPermission:' + ex.getMessage());
        }
    }


    /* 31/08/17 Tuan */
    // Get Object permission for permission sets setting
    public void getObjectSettings(){
        try{
            objectSettings = new List<Map_Object.ObjectPermission>();
            if (currentOrgConfig!= null 
                && string.isNotEmpty(currentOrgConfig.Selected_Permission_Sets__c)
                && string.isNotEmpty(currentOrgConfig.Selected_Objects__c)) {
                String selectObjects = '';
                for(String obj : currentOrgConfig.Selected_Objects__c.split(';')){
                    selectObjects += string.isNotEmpty(selectObjects) ? ',\'' + obj + '\'' : '\'' + obj + '\'';
                }
                
                List<String> permissionSet = currentOrgConfig.Selected_Permission_Sets__c.split(';');
                //system.debug(profile);
                List<Tools_calloutJSONPermissionObjects> permissionObjects = new List<Tools_calloutJSONPermissionObjects>();
                for (String p : permissionSet) {
                    nleCalloutResult result = nleCalloutService.getObjectPermissionByParentId(this.currentOrgConfig, p,selectObjects);
                    if (!result.hasError) {
                        //System.debug('result.data: ' + result.data);
                        permissionObjects.add((Tools_calloutJSONPermissionObjects) result.data);
                    }
                }
                // list permission Object return form api
                if(permissionObjects.size()>0){
                    // map object with permission will be show on excel file
                    Map_Object.ObjectPermission op;
                    // loop all object has been selected before
                    for(String obj : currentOrgConfig.Selected_Objects__c.split(';')){
                        op = new Map_Object.ObjectPermission();
                        op.objectName = obj;
                        op.isCustom = obj.indexOf('__c') > 1;
                        List<String> permissions = new List<String>();                    
                        for(Tools_calloutJSONPermissionObjects json : permissionObjects){
                            String permis = '';                       
                            if(!isExistItem(json.records,obj)){
                                permissions.add(permis);
                                continue;
                            }                                                                   
                            for(Tools_calloutJSONPermissionObjects.Records record : json.records){
                                if(obj == record.SobjectType){
                                    if(record.Id.indexOf('1102800')>-1){
                                        continue;
                                    }
                                    permis += record.PermissionsCreate ? 'C' : '';
                                    permis += record.PermissionsRead ? 'R' : '';
                                    permis += record.PermissionsEdit ? 'U' : '';
                                    permis += record.PermissionsDelete ? 'D' : '';
                                    permis += record.PermissionsViewAllRecords ? ' ViewAll' : '';
                                    permis += record.PermissionsModifyAllRecords ? ',ModifyAll' : '';
                                    permissions.add(permis);                                
                                    break;
                                }
                            }
                        }
                        op.permissions = permissions;
                        system.debug(permissions);
                        // fill data to map objectpermission
                        objectSettings.add(op);
                    }                
                }
            }      
        }catch(Exception ex){
            system.debug('lỗi getObjectSettings:' + ex.getMessage());
        }
    }
    /* 31/08/17 Tuan */
    //private method
    private Boolean isExistItem(List<Tools_calloutJSONPermissionObjects.Records> records,String objectName){
        for(Tools_calloutJSONPermissionObjects.Records record : records){
            if(record.SobjectType == objectName && record.Id.indexOf('1102800')==-1)
                return true;
        }
        return false;
    }
}