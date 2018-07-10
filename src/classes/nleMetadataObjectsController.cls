global class nleMetadataObjectsController {
    public string BLANKVALUE {get;set;}
    private Map<String, Nle_Org_Config__c> orgConfigs;
    private List<SelectOption> orgConfigSelectOptions;
    private Nle_Org_Config__c currentOrgConfig;
    private List<nleCalloutJSONObject> jObjectDetails {get;set;}
    
    public List<JObject> jObjects {get;set;}
    public Set<String> currentSelectedObjects {get;set;}
    public List<Account> accountList{get;set;}
    public List<Contact> contactList{get;set;}
    //public String achorElement {get;set;}
    
    public boolean isConnected {get;set;}
    public boolean isSaveConfig {get;set;}
    public Integer noOfOrgConfigs {get;set;}
    public Id currentOrgConfigId {get;set;}
    
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }  
    public String searchObject{get;set;}

    public nleMetadataObjectsController() {
        System.debug('nleMetadataObjectsController');
        //Cookie anchor = ApexPages.currentPage().getCookies().get('anchor');        
        //system.debug(ApexPages.currentPage().getCookies());

        //System.debug('achorElement: ' + getAchorElement());
        //System.debug('apexPages.currentPage: ' + ApexPages.currentPage());
        //System.debug('apexPages.currentPage.getHeaders: ' + ApexPages.currentPage().getHeaders());
        
        PageReference currentPage = ApexPages.currentPage();
        String currentUrl = currentPage.getUrl();
        String state = currentPage.getParameters().get('state');
        //System.debug('state: ' + state);
        //System.debug('currentUrl: ' + currentUrl);
        //System.debug('getAnchor: ' + currentPage.getAnchor());
        //system.debug(Api.Partner_Server_URL_370);
        
        if (currentUrl.indexOf('nleMetadataObjects') == -1) {
            if (String.isNotEmpty(state)) {
                initialExport(state);
            }
        } else {
            String mode = currentPage.getParameters().get('mode');
            System.debug('mode: ' + mode);
            if (String.isNotEmpty(mode) && mode == 'token') {
                    Map<String, String> anchors = getAnchors();
                    if(anchors.size()>0){
                        currentOrgConfigId = anchors.get('state');                            
                        currentOrgConfig = [Select Id, Name, Client_Id__c,Refresh_Token__c, Client_Secret__c, Username__c, Password__c, Redirect_URL__c,
                                        Access_Token__c, Token_Expire_On__c, Environment_URL__c, Selected_Objects__c, RecordType.Name
                                        From Nle_Org_Config__c where Id =: currentOrgConfigId];

                        currentOrgConfig.Environment_URL__c = anchors.get('instance_url');
                        currentOrgConfig.Access_Token__c = anchors.get('access_token');
                        currentOrgConfig.Refresh_Token__c = anchors.get('refresh_token');
                        Integer sectionTimeout = currentOrgConfig.Session_Timeout__c == null ? 120 : Integer.valueOf(currentOrgConfig.Session_Timeout__c);
                        currentOrgConfig.Token_Expire_On__c = system.now().addMinutes(sectionTimeout).addSeconds(-1);
                        this.isConnected = true;
                    }else{
                        initialPageObjects();
                    }
                    //getObjects();
                } 
                else {
                    initialPageObjects();
                }
        }	
    }   

    public pageReference changeOrgConfig() {
        if (orgConfigs != null) {
            currentOrgConfig = orgConfigs.get(currentOrgConfigId);
            if (currentOrgConfig != null) {
                if (String.isNotEmpty(currentOrgConfig.Selected_Objects__c)) {
                    List<String> temp = currentOrgConfig.Selected_Objects__c.split('; ');
                    currentSelectedObjects.clear();
                    currentSelectedObjects.addAll(temp);
                }                
                if (String.isNotEmpty(currentOrgConfig.Access_Token__c)) {
                    this.isConnected = true;
                    getObjects();
                } else {
                    this.isConnected = false;
                }                
            }
        }
        return null;
    }
    
    public PageReference refreshObjects() {
        getObjects();
        return null;
    }
    
    public PageReference exportDD() {
        if(currentSelectedObjects.size() != currentOrgConfig.Selected_Objects__c.split(',').size()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please save your selected objects!'));
            return null;   
        }
        //this.saveSelectedObjects();
        if (this.currentOrgConfig != null && String.isNotEmpty(this.currentOrgConfig.Selected_Objects__c)) {
            String base_URL = '/apex/nleExportDetailDesign?state=' + this.currentOrgConfig.Id;
            System.debug('base_URL: ' + base_URL);
            return new Pagereference(base_URL);
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Org issue.'));
        return null;
    }
    
    public PageReference newConfig() {
        String objectId = '01IN0000000AHKp';
        //String objectId = r.getFields('id');
        return new Pagereference('/setup/ui/recordtypeselect.jsp?ent='+objectId+'&retURL=%2Fa0D%2Fo&save_new_url=%2Fa0D%2Fe%3FretURL%3D%252Fa0D%252Fo');
    }

    public pageReference connectToOrg() {
        if(currentOrgConfigId==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select org config!'));
            return null;
        }
        if (currentOrgConfig.RecordType.Name == nleMetadataObjectConstant.UA_FLOW && String.isNotEmpty(currentOrgConfig.Client_Id__c)) {
            String base_URL = nleMetadataObjectConstant.SFDC_AUTH;
            base_URL += '/authorize?response_type=token';
            base_URL += '&client_id=' + currentOrgConfig.Client_Id__c;
            base_URL += '&redirect_uri=http://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/nleMetadataObjects';
            base_URL += '&state=' + currentOrgConfig.Id;
            return new pageReference(base_URL);
            }
        else if (currentOrgConfig.RecordType.Name == nleMetadataObjectConstant.UP_FLOW 
                   && String.isNotEmpty(currentOrgConfig.Client_Id__c)
                   && String.isNotEmpty(currentOrgConfig.Client_Secret__c)
                   && String.isNotEmpty(currentOrgConfig.Username__c)
                   && String.isNotEmpty(currentOrgConfig.Password__c)) {
                       nleCalloutResult result = nleCalloutService.up_getToken(currentOrgConfig);
                       if (!result.hasError) {
                           this.isConnected = true;                           
                           getObjects();
                       } else {
                           this.isConnected = false;
                           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.status + '. ' + result.error_message));
                       }
                       return null;
                   }        
        this.isConnected = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check org config!'));
        return null;
    }
    
    public pageReference revokeToOrg() {
        if (currentOrgConfig != null) {
            currentOrgConfig.Access_Token__c = null;
            UPDATE currentOrgConfig;
            
            this.isConnected = false;
        }
        
        return null;
    }
    
    public pageReference saveSelectedObjects() {
        this.currentSelectedObjects.clear();
        for (JObject jObject : jObjects) {
            if (jObject.selected == true) {
                this.currentSelectedObjects.add(jObject.objectNameAPI);
            }
        }
        if (this.currentOrgConfig != null) {
            List<String> tem = new List<String>();
            tem.addAll(this.currentSelectedObjects);
            this.currentOrgConfig.Selected_Objects__c = String.join(tem,'; ');
            UPDATE this.currentOrgConfig;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The config is saved'));
        }
        return null;    
    }
    
    /**************************** Getters methods ****************************/ 
    public List<SelectOption> getOrgConfigSelectOptions() {
        return this.orgConfigSelectOptions;
    }
    
    public List<nleCalloutJSONObject> getJObjectDetails() {
        this.jObjectDetails = new List<nleCalloutJSONObject>();
        if (currentOrgConfig!= null && string.isNotEmpty(currentOrgConfig.Selected_Objects__c)) {
            List<String> objectNames = currentOrgConfig.Selected_Objects__c.split('; ');
            for (String objectName : objectNames) {
                nleCalloutResult result = nleCalloutService.getObject(this.currentOrgConfig, objectName);
                if (!result.hasError) {
                    System.debug('result.data: ' + result.data);
                    jObjectDetails.add((nleCalloutJSONObject) result.data);
                }
            }
        }
        
        return this.jObjectDetails;
    }
    
    /**************************** Private methods ****************************/ 
    private void initialExport(String orgConfigIdStr) {
        System.debug('initialExport');
        Id orgConfigId = Id.valueOf(orgConfigIdStr);
        if (orgConfigId.getSobjectType() == Nle_Org_Config__c.SobjectType) {
            this.currentOrgConfig = [SELECT Id, Name, Client_Id__c,Refresh_Token__c , Client_Secret__c, Username__c, Password__c, Redirect_URL__c,
                                     Access_Token__c, Token_Expire_On__c, Environment_URL__c, Selected_Objects__c, RecordType.Name
                                     FROM Nle_Org_Config__c WHERE Id = :orgConfigId LIMIT 1];
        }
    }
    
    private void initialPageObjects() {
        isConnected = false;
        isSaveConfig = false;
        currentSelectedObjects = new Set<String>();
        
        orgConfigs = new Map<String, Nle_Org_Config__c>([SELECT Id, Name, Client_Id__c,Refresh_Token__c, Client_Secret__c, Username__c, Password__c, Redirect_URL__c,
                                                         Access_Token__c, Token_Expire_On__c, Environment_URL__c, Selected_Objects__c, RecordType.Name
                                                         FROM Nle_Org_Config__c ORDER BY CreatedDate]);
        
        noOfOrgConfigs = orgConfigs.size();
        
        this.orgConfigSelectOptions = new List<SelectOption>();
        this.orgConfigSelectOptions.add(new SelectOption('', 'None'));
        for (Nle_Org_Config__c orgConfig : orgConfigs.values()) {
            this.orgConfigSelectOptions.add(new SelectOption(orgConfig.id, orgConfig.Name));
        }
    }
    
    private Boolean getObjects() {
        system.debug('getObjects isConnected: ' + isConnected);
        system.debug('getObjects currentOrgConfig: ' + currentOrgConfig);
        
        if (this.currentOrgConfig == null || !this.isConnected) {
            return false;
        }
        
        nleCalloutResult result = nleCalloutService.getObjects(this.currentOrgConfig);
        this.jObjects = new List<JObject>();
        if (!result.hasError) {
            nleCalloutJSONObjects data = (nleCalloutJSONObjects) result.data;
            if (data != null) {
                for (nleCalloutJSONObjects.JSONObjects obj : data.sobjects) {
                    this.jObjects.add(new JObject(obj, this.currentSelectedObjects));
                }
            }
            
            UPDATE currentOrgConfig;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.status + '. ' + result.error_message));
            return false;
        }
        
        return true;
    }
    private List<jObject> getjObjects(){
        system.debug(jObjects.size());
        return jObjects;
    }

    private Map<String, String> getAnchors() {
        Map<String, String> result = new Map<String, String>();
        Cookie anchor = ApexPages.currentPage().getCookies().get('anchor');
        //system.debug(anchor);
        if (anchor != null && String.isNotEmpty(anchor.getValue())) {
            List<String> items = anchor.getValue().split('&');
            for (String item : items) {
                String key = item.substringBefore('=');
                String value = item.substringAfter('=');
                result.put(key, value);
            }
        }
        system.debug(result);
        return result;
    }
}