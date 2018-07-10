/**
 * CLP_SearchDemandCC.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: SearchDemandPage controller
 */
global with sharing class CLP_SearchDemandCC {
    public DemandDetail__c demandObj {get;set;}
    public String PREFIX {get;set;}
    // unify flag can't edit in search page                            
    public String[] UNIFY_FLAG {get;set;}
    public String UNIT {get;set;}
    public String REPEAT_COUNT {get;set;}
    public String PAYMENT_METHOD {get;set;}
    public String SEIKYUUSAKIBUSHO {get;set;}
    public String STARTDATE {get;set;}
    public String DEMAND_TYPE {get;set;}
    public String REPEAT_PERIOD_NUMBER {get;set;}
    public String DEMAND_DATA_DEFECT {get;set;}
        

    public Integer PAGESIZE {get{ return CLP_SearchConstant.PAGESIZE;} set;}

    public CLP_SearchDemandCC(){
        demandObj = new DemandDetail__c();
        PREFIX = CLP_CommonUtil.ENV_PREFIX;
        UNIFY_FLAG = CLP_MikataConstant.UNIFY_FLAG;
        UNIT = String.escapeSingleQuotes(CLP_CommonUtil.ENV_PREFIX + 'Unit__c');
        REPEAT_COUNT = String.escapeSingleQuotes(CLP_CommonUtil.ENV_PREFIX + 'Repeat_Count__c');

        // only modify 1 record per times
        PAYMENT_METHOD = CLP_CommonUtil.ENV_PREFIX + 'PaymentMethod__c';
        SEIKYUUSAKIBUSHO = String.escapeSingleQuotes(CLP_CommonUtil.ENV_PREFIX + 'Seikyuusakibusho__c');

        // need to connect to mikata 
        STARTDATE = String.escapeSingleQuotes(CLP_CommonUtil.ENV_PREFIX + 'StartDate__c');
        DEMAND_TYPE = String.escapeSingleQuotes(CLP_CommonUtil.ENV_PREFIX + 'DemandType__c');
        REPEAT_PERIOD_NUMBER = String.escapeSingleQuotes(CLP_CommonUtil.ENV_PREFIX + 'Repeat_Period_Number__c');
        
        DEMAND_DATA_DEFECT = CLP_MikataConstant.DEMAND_DATA_DEFECT;
        PAGESIZE = CLP_SearchConstant.PAGESIZE;
    }

    // go to new Demand Page
     //@RemoteAction
    public PageReference goToNewDemandPage(){
        PageReference ref = null;
        try{
            String currentUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            String demandPrefix = CLP_CommonUtil.getObjectPrefix('DemandDetail__c');
            String url = String.format('{0}/{1}/e', new String[]{currentUrl,demandPrefix});
            ref = new PageReference(url);
        }catch(Exception ex){
            //url = '';
            //system.debug('Error:' + ex.getMessage());
            ref = null;
        }
        return ref;
    }
    /*@RemoteAction
    global static String goToMikataDemandPage(){
        String url = '';
        try{
            String currentUrl = CLP_CommonUtil.getSalesforceBaseUrlForVF();
            url = String.format('{0}/apex/MikataFrame?page=demand', new String[]{currentUrl});
        }catch(Exception ex){
            url = '';
            system.debug('Error:' + ex.getMessage());
        }
        return url;
    }*/
    // get payment method
    @RemoteAction
    global static List<RecordType> getPaymentMethod(){     
        String paymentMethod =  CLP_CommonUtil.ENV_PREFIX + 'PaymentMethod__c';
        return [Select Id,Name From RecordType where SobjectType =: paymentMethod and isActive = true];
    }    
    // get Billing Source Individual
    @RemoteAction
    global static List<BillingSourceIndividual__c> getBillingSourceIndividual(){      
        return [Select Id,Name From BillingSourceIndividual__c limit 50000];
    }   
    // get picklist value 
    @RemoteAction 
    global static List<WrapObject> getPicklistValues(String fieldName){
        fieldName = fieldName.contains(CLP_CommonUtil.ENV_PREFIX)  ? fieldName : CLP_CommonUtil.ENV_PREFIX + fieldName;
        List<WrapObject> options = new List<WrapObject>();
        Schema.DescribeSObjectResult objSchema = DemandDetail__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
           WrapObject w = new WrapObject(); 
           w.id = f.getValue();           
           w.label = f.getLabel();
           options.add(w);
        }     
        return options;
    }
    // check record was connect mikata before or not
    @RemoteAction 
    global static Boolean isConnectMikata(String ids){
        Boolean isConnect = false;
        try{
            Set<String> sid = new Set<String>();
            sid.addAll(ids.split(','));
            List<DemandDetail__c> details = [Select Id,DemandDetailCode__c 
                    from DemandDetail__c where Id in: sid limit 50000];
            if(!details.isEmpty()){
                for(DemandDetail__c d: details){
                    if(String.isNotBlank(d.DemandDetailCode__c)){
                        isConnect = true;
                        break;
                    }
                }
            }
        }catch(Exception ex){
            isConnect = false;
        }
        return isConnect;
    }
    
    // get department
    @RemoteAction 
    global static List<Seikyusakibusho__c > getDepartments(String accountName){
        system.debug('accountId: '+accountName);
        List<Seikyusakibusho__c> seiList = new List<Seikyusakibusho__c>();
        if (!String.isBlank(accountName))
            seiList = [Select Id,Name From Seikyusakibusho__c where Seikyusakimei__r.Name =:accountName limit 50000];
        else 
            seiList = [Select Id,Name From Seikyusakibusho__c limit 50000];
        return seiList;
    }
    // get users
    @RemoteAction 
    global static List<BillingSourceOwner__c> getUsers(String billingSourceIndividualId){
        List<BillingSourceOwner__c> sourceList = new List<BillingSourceOwner__c>();
        if (!String.isBlank(billingSourceIndividualId))
            sourceList = [Select Id,Name From BillingSourceOwner__c where BillingSourceIndividualId__c =: billingSourceIndividualId  limit 50000];
        else
            sourceList = [Select Id,Name From BillingSourceOwner__c  limit 50000];
        return sourceList;
    }
    // get list demand header
    @RemoteAction
    global static List<WrapObject> getWrapObjects(){
        List<ViewSettings__c> views = [Select Id,Display_Field__c from ViewSettings__c 
                                where User__c =: UserInfo.getUserId()];        
        Map<String,Schema.SObjectField> maps = Schema.SObjectType.DemandDetail__c.fields.getMap();
        Map<String,String> labels = CLP_CommonUtil.getObjectFields('DemandDetail__c');
        Map<String,String> types = CLP_CommonUtil.getFieldTypes('DemandDetail__c');
        String defaultView = String.format('Id,{0},{1}ErrorMessage__c',new String[]{CLP_CommonUtil.DEFAULT_VIEW,CLP_CommonUtil.ENV_PREFIX});
        String fields = views.isEmpty() ? defaultView : views[0].Display_Field__c;
       
        List<WrapObject> wrapObjects = new List<WrapObject>();
        for(String f: fields.split(',')){
            WrapObject w = new WrapObject();
            w.apiName = f;
            w.dataType = types.get(f);
            w.label = labels.get(f);
            w.isEditable = maps.get(f) == null ? false : maps.get(f).getDescribe().isUpdateable();
            w.isCustom = maps.get(f)  == null ? false : maps.get(f).getDescribe().isCustom();
            w.lookupName = w.dataType != 'REFERENCE' ? '' 
                         : w.isCustom && w.dataType == 'REFERENCE'
                         ? String.format('{0}__r.Name', new String[]{f.substring(0,f.length()-3)}) 
                         : String.format('{0}.Name', new String[]{f});
            wrapObjects.add(w);
        }       
        system.debug(wrapObjects);
        return wrapObjects;
    }

    // get diplay loopkup fields
    private static string getDisplayLookups(String fields){
        String lookupFields = '';
        Map<String,Schema.SObjectField> maps = Schema.SObjectType.DemandDetail__c.fields.getMap();
        Map<String,String> types = CLP_CommonUtil.getFieldTypes('DemandDetail__c');
        for(String f: fields.split(',')){
            String fName = '';
            if(types.get(f)=='REFERENCE'){
                fName = maps.get(f).getDescribe().isCustom()
                      ? String.format('{0}__r.Name', new String[]{f.substring(0,f.length()-3)}) 
                      : String.format('{0}.Name', new String[]{f});
                lookupFields += ','+ fName;
            }
        }
        return fields + lookupFields;
    }

    @RemoteAction 
    global static CLP_DemandWrapper search(string jsonString){
        CLP_DemandWrapper wrap = new CLP_DemandWrapper();
        try{
            List<ViewSettings__c> dfSetting = [SELECT Id from ViewSettings__c where User__c =: UserInfo.getUserId()];
            if(dfSetting.isEmpty())
            {
                CLP_ViewSettingCC.save(null,null);
            }
            
            String countQuery = createSearchQuery(jsonString,true);
            String query = createSearchQuery(jsonString,false); 
            
            List<DemandDetail__c> details;
            if(String.isNotBlank(query)){                       
                wrap.total = Database.countQuery(countQuery);
                if(wrap.total<=2500)
                    details = Database.query(query); 
                wrap.demandList = details;
            }
            wrap.success = true;
            return wrap;
        }catch(Exception ex){
            wrap.success = false;
            wrap.errorMessage = ex.getMessage();
            return wrap;
        }
    }
    // create search query
    private static String createSearchQuery(String jsonCondition,Boolean isCount){
        try{            
            CLP_SearchDemandCondition searchCondition = (CLP_SearchDemandCondition) JSON.deserializeStrict(jsonCondition, CLP_SearchDemandCondition.class);
            system.debug('searchCondition'+ searchCondition);
            String strWhere = '';
            for(CLP_SearchDemandCondition.FilterOption opt : searchCondition.opts){
                // search by account
                if(opt.filter_key==CLP_SearchConstant.SEARCH_ACCOUNT){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String f_account = string.format('( {0}Account__c=\'\'{1}\'\' )',new String[]{CLP_CommonUtil.ENV_PREFIX,String.escapeSingleQuotes(opt.filter_value)});
                        strWhere += String.isBlank(strWhere) ? f_account : ' AND ' + f_account;
                    }
                } // search by billing source
                else if(opt.filter_key==CLP_SearchConstant.BILLING_SOURCE){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String f_billingsource = string.format('( {0}BillingSourceIndividual__c=\'\'{1}\'\' )',new String[]{CLP_CommonUtil.ENV_PREFIX,String.escapeSingleQuotes(opt.filter_value)});
                        strWhere += String.isBlank(strWhere) ? f_billingsource : ' AND ' + f_billingsource;
                    }
                }  // search by bill issue date ==> from <start> to <end>  bill issue date
                else if(opt.filter_key==CLP_SearchConstant.ISSUE_DATE){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String[] arr = opt.filter_value.split(',');
                        system.debug(arr);
                        String fDate = arr.size() > 0 ? arr[0] : '';
                        String f_issueDate = !String.IsBlank(fDate) ? string.format('({0}BillIssueDate__c >= {1})'
                                            ,new String[]{CLP_CommonUtil.ENV_PREFIX,String.escapeSingleQuotes(fDate)}) : '';
                        String tDate = arr.size() > 1 ? arr[1] : '';
                        String t_issueDate = !String.IsBlank(tDate) ? string.format('({0}BillIssueDate__c <= {1})'
                                            ,new String[]{CLP_CommonUtil.ENV_PREFIX,String.escapeSingleQuotes(tDate)}) : ''; 
                        strWhere += String.isBlank(f_issueDate) || String.isBlank(strWhere) ? f_issueDate : ' AND ' + f_issueDate;
                        strWhere += String.isBlank(t_issueDate) || String.isBlank(strWhere) ? t_issueDate : ' AND ' + t_issueDate;
                    }
                } // search by period date ==> from <start> to <end>  period date
                else if(opt.filter_key==CLP_SearchConstant.PERIOD_DATE){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String[] arr = opt.filter_value.split(',');
                        String fDate = arr.size() > 0 ? arr[0] : '';
                        String f_periodDate = !String.IsBlank(fDate) ? string.format('({0}PeriodStartDate__c >= {1})'
                                            ,new String[]{CLP_CommonUtil.ENV_PREFIX,String.escapeSingleQuotes(fDate)}) : '';
                        
                        String tDate = arr.size() > 1 ? arr[1] : '';
                        String t_periodDate = !String.IsBlank(tDate) ? string.format('({0}PeriodStartDate__c <= {1})'
                                            ,new String[]{CLP_CommonUtil.ENV_PREFIX,String.escapeSingleQuotes(tDate)}) : ''; 
                        
                        strWhere += String.isBlank(f_periodDate) || String.isBlank(strWhere) ? f_periodDate : ' AND ' + f_periodDate;
                        strWhere += String.isBlank(t_periodDate) || String.isBlank(strWhere) ? t_periodDate : ' AND ' + t_periodDate;
                    }
                } // search by multi depart ment
                else if(opt.filter_key==CLP_SearchConstant.DEPARTMENT){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String departments = '';
                        for(String d : opt.filter_value.split(',')){
                            departments += String.isBlank(departments) ? '\''+String.escapeSingleQuotes(d)+'\'': ',\''+String.escapeSingleQuotes(d)+'\'';
                        }
                        String f_department = string.format('( {0}Seikyuusakibusho__c in ({1}) )',new String[]{CLP_CommonUtil.ENV_PREFIX,departments});
                        strWhere += String.isBlank(strWhere) ? f_department : ' AND ' + f_department;
                    }                   
                } // search by multi request user
                else if(opt.filter_key==CLP_SearchConstant.REQUEST_USER){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String request_users = '';
                        for(String us : opt.filter_value.split(',')){
                            request_users += String.isBlank(request_users) ? '\''+String.escapeSingleQuotes(us)+'\'': ',\''+String.escapeSingleQuotes(us)+'\'';
                        }
                        String f_users = string.format('( {0}BillingSourceOwner__c in ({1}) )',new String[]{CLP_CommonUtil.ENV_PREFIX,request_users});
                        strWhere += String.isBlank(strWhere) ? f_users : ' AND ' + f_users;
                    }   
                } // search by multi payment method
                else if(opt.filter_key==CLP_SearchConstant.PAYMENT_METHOD){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String payments = '';
                        for(String pm : opt.filter_value.split(',')){
                            payments += String.isBlank(payments) ? '\''+String.escapeSingleQuotes(pm)+'\'': ',\''+String.escapeSingleQuotes(pm)+'\'';
                        }
                        String f_payments = string.format('( {0}PaymentMethod__r.RecordTypeId in ({1}) )',new String[]{CLP_CommonUtil.ENV_PREFIX,payments});
                        strWhere += String.isBlank(strWhere) ? f_payments : ' AND ' + f_payments;
                    }
                } // search by demand type
                else if(opt.filter_key==CLP_SearchConstant.DEMAND_TYPE){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String types = '';
                        for(String t : opt.filter_value.split(',')){
                            types += String.isBlank(types) ? '\''+String.escapeSingleQuotes(t)+'\'': ',\''+String.escapeSingleQuotes(t)+'\'';
                        }
                        String f_types = string.format('( {0}DemandType__c in ({1}) )',new String[]{CLP_CommonUtil.ENV_PREFIX,types});
                        strWhere += String.isBlank(strWhere) ? f_types : ' AND ' + f_types;
                    }
                } // search by product code
                else if(opt.filter_key==CLP_SearchConstant.PRODUCT_CODE){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String f_code = string.format('( {0}GoodsCode__c LIKE \'\'%{1}%\'\' )',new String[]{CLP_CommonUtil.ENV_PREFIX,String.escapeSingleQuotes(opt.filter_value)});
                        strWhere += String.isBlank(strWhere) ? f_code : ' AND ' + f_code;
                    }
                } // search by product name
                else if(opt.filter_key==CLP_SearchConstant.PRODUCT_NAME){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String f_name = string.format('( {0}ProductName__c LIKE \'\'%{1}%\'\' )',new String[]{CLP_CommonUtil.ENV_PREFIX,String.escapeSingleQuotes(opt.filter_value)});
                        strWhere += String.isBlank(strWhere) ? f_name : ' AND ' + f_name;
                    }
                } // // search by multi manipulateStatus
                else if(opt.filter_key==CLP_SearchConstant.STATUS){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String conditions = '';
                        for(String c : opt.filter_value.split(',')){
                            conditions += String.isBlank(conditions) ? '\''+String.escapeSingleQuotes(c)+'\'': ',\''+String.escapeSingleQuotes(c)+'\'';
                        }
                        String f_conditions = string.format('( {0}ManipulateStatus__c in ({1}) )',new String[]{CLP_CommonUtil.ENV_PREFIX,conditions});
                        strWhere += String.isBlank(strWhere) ? f_conditions : ' AND ' + f_conditions;
                    }
                }// search by stop flag
                else if(opt.filter_key==CLP_SearchConstant.STOP_FLAG){
                    if(String.isNotBlank(opt.filter_value))
                    {
                        String flags = '';
                        for(String c : opt.filter_value.split(',')){
                            flags += String.isBlank(flags) ? '\''+String.escapeSingleQuotes(c)+'\'': ',\''+String.escapeSingleQuotes(c)+'\'';
                        }
                        String f_flags = string.format('( {0}StopFlg__c in ({1}) )',new String[]{CLP_CommonUtil.ENV_PREFIX,flags});
                        strWhere += String.isBlank(strWhere) ? f_flags : ' AND ' + f_flags;
                    }
                }               
            }
            system.debug('where:' + strWhere);
            searchCondition.offset = searchCondition.pageSize * (searchCondition.page-1);
            // if haven't status ==> add status in display field 
            searchCondition.fields = !searchCondition.fields.contains(CLP_CommonUtil.ENV_PREFIX + 'ManipulateStatus__c') 
                                   ? searchCondition.fields + ',' +CLP_CommonUtil.ENV_PREFIX + 'ManipulateStatus__c'
                                   : searchCondition.fields;
            String[] params = new String[]{
                        String.isBlank(searchCondition.fields) ?  String.escapeSingleQuotes('Id') : String.escapeSingleQuotes(getDisplayLookups(searchCondition.fields)),
                        CLP_CommonUtil.ENV_PREFIX,
                        strWhere,
                        searchCondition.sortColumn,
                        searchCondition.sortOption,
                        isCount ? '2500' : String.valueOf(searchCondition.pageSize),
                        isCount ? '0' : String.valueOf(searchCondition.offset)
                    };

            String query = String.IsBlank(strWhere) ? String.format('Select {0} From {1}DemandDetail__c order by {3} {4} Limit {5} offset {6}', params) :  String.format('Select {0} From {1}DemandDetail__c where {2} order by {3} {4} Limit {5} offset {6}', params);
            String countQuery = String.IsBlank(strWhere) ? String.format('Select Count() From {1}DemandDetail__c', params) : String.format('Select Count() From {1}DemandDetail__c where {2}', params);
            system.debug(query);
            return isCount ? countQuery : query;
        }catch(Exception ex){
            throw ex;
            return '';
        }
    }  

    @RemoteAction 
    global static CLP_JSONResult saveChange(String jsonObject){
        List<DemandDetail__c> details = (List<DemandDetail__c>) JSON.deserializeStrict(jsonObject, List<DemandDetail__c>.class);
        Boolean isSuccess = true;
        String msg = '';
        Database.SaveResult[] saveResults =  Database.update(details,false);
        for (Integer i=0; i<saveResults.size(); i++){
            if (!saveResults[i].isSuccess()) { // validation rule for field required
                isSuccess = false;
                for(Database.Error e : saveResults[i].getErrors()){
                    msg+= e.getMessage() + '\n';
                }
            }
        } 
        return new CLP_JSONResult(isSuccess,details,msg);
    }
    // bulk upsert demand
    @RemoteAction
    global static CLP_JSONResult bulkUpsertDemand(String jsonObject){
         List<DemandDetail__c> details = (List<DemandDetail__c>) JSON.deserializeStrict(jsonObject, List<DemandDetail__c>.class);
         Set<Id> ids = new Set<Id>();
        for(DemandDetail__c d: details){
            ids.add(d.Id);
        }
        Integer countError = 0;
        Boolean success = true;
        List<DemandDetail__c> recordToUpsert = [Select Id,IsStop__c,IsIntegrated__c,StopFlg__c,ErrorMessage__c,ManipulateStatus__c from DemandDetail__c where Id in: ids];
        // create new list to contains data without success before
        List<DemandDetail__c> newList = new List<DemandDetail__c>();
        try{
            // raise error don't config mikata before
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            // validation in code
            for(DemandDetail__c d: recordToUpsert){
                if(d.IsIntegrated__c == true 
                       && d.ManipulateStatus__c==CLP_MikataConstant.DEMAND_LINK_SUCCESS
                       && d.IsStop__c == false){
                    //success = false;
                    continue;
                }else{  
                    d.ErrorMessage__c = '';                  
                    d.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
                    newList.add(d);
                }                
            }
            List<DemandDetail__c> failedList = new List<DemandDetail__c>();      
            // update demand List        
            Map<String, Schema.SObjectField> fieldMaps=Schema.SObjectType.DemandDetail__c.fields.getMap();
            String[] listField = new String[]{'ErrorMessage__c','ManipulateStatus__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
                Savepoint sp;
                if(!Test.isRunningTest()){
                    sp = Database.setSavepoint();
                }
                // update demand
                Database.SaveResult[] rsList = Database.update(newList,false);    
                for(Integer i=0;i<rsList.size();i++){
                    if(!rsList[i].isSuccess())
                    {
                        String errMessage = '';
                        for(Database.Error e : rsList[i].getErrors()){
                            errMessage+= e.getMessage() + '\n';
                        }
                        newList[i].ErrorMessage__c = errMessage;
                        newList[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        failedList.add(newList[i]);

                    }
                }
                if(!failedList.isEmpty())     
                {    
                    try{
                        update failedList;
                    }catch(DmlException ex){
                        if(!Test.isRunningTest()){
                            Database.rollback(sp);
                        }
                        throw new CLP_MikataApiException(ex.getDmlMessage(0));
                    }
                }        
            }

            // click upsert
            Id jobId = CLP_DemandBulkUpsertBatch.startBatch(true,false);
            if(jobId==null){
                //return new CLP_JSONResult (false,null,'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');  
                return new CLP_JSONResult (true,0,'');
            }
            countError +=  failedList.size();
            return new CLP_JSONResult (true,failedList,countError==0 ?'': String.ValueOf(countError));    
        }catch(Exception ex){  
            if(ex.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
                return new CLP_JSONResult(false,null,'エラー302:関連する参照が停止中です。');          
            //'エラー：権限がありません。'
            return new CLP_JSONResult(false,null,ex.getMessage());
        }
    }
    // bulk stop demand
    @RemoteAction
    global static CLP_JSONResult bulkStopDemand(String jsonObject){
         try{
            // raise error don't config mikata before
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            List<DemandDetail__c> jsonDemands = (List<DemandDetail__c>) JSON.deserializeStrict(jsonObject, List<DemandDetail__c>.class);
            Set<Id> demandIds = new Set<Id>();

            for(DemandDetail__c d: jsonDemands){
                demandIds.add(d.Id);
            }
            List<DemandDetail__c> details = [Select Id,IsStop__c from DemandDetail__c where Id in: demandIds];
            for(DemandDetail__c d: details){
                 d.ErrorMessage__c = ''; 
                d.StopFlg__c = CLP_MikataConstant.FLG_STOP;
                d.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;            
            }
            List<DemandDetail__c> failedList = new List<DemandDetail__c>();
            // update demand List        
            String[] listField = new String[]{'StopFlg__c','ManipulateStatus__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
                Savepoint sp;
                if(!Test.isRunningTest()){
                    sp = Database.setSavepoint();
                }
                // update demand
                Database.SaveResult[] rsList = Database.update(details,false);
                for(Integer i=0;i<rsList.size();i++){
                    if(!rsList[i].isSuccess())
                    {
                        String errMessage = '';
                        for(Database.Error e : rsList[i].getErrors()){
                            errMessage+= e.getMessage() + '\n';
                        }
                        details[i].ErrorMessage__c = errMessage;
                        
                        // reset stop flag
                        //system.debug(details[i].IsStop__c);
                        if(details[i].IsStop__c!=true)
                            details[i].StopFlg__c = null;
                        details[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        failedList.add(details[i]);
                    }
                }
                system.debug('failedList:' + failedList);
                if(!failedList.isEmpty())     
                {    
                    try{
                        update failedList;
                    }catch(DmlException ex){
                        if(!Test.isRunningTest()){
                            Database.rollback(sp);
                        }
                        throw new CLP_MikataApiException(ex.getDmlMessage(0));
                    }
                }
            }

            Id jobId = CLP_DemandBulkStopBatch.startBatch(true);
            if(jobId==null){
                //return new CLP_JSONResult (false,null,'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');  
                return new CLP_JSONResult (true,0,'');    
            }
            return new CLP_JSONResult (true,failedList.size(),failedList.size()==0 ?'':String.ValueOf(failedList.size()));    
        }catch(Exception ex){
            if(ex.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
                return new CLP_JSONResult(false,null,'エラー302:関連する参照が停止中です。');
            //'エラー：権限がありません。'
            return new CLP_JSONResult(false,null,ex.getMessage());
        }
    }
    // bulk unstop demand
    @RemoteAction
    global static CLP_JSONResult bulkUnStopDemand(String jsonObject){
         try{
            // raise error don't config mikata before
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            List<DemandDetail__c> details = (List<DemandDetail__c>) JSON.deserializeStrict(jsonObject, List<DemandDetail__c>.class);
            Set<Id> ids = new Set<Id>();
            for(DemandDetail__c d: details){
                ids.add(d.Id);
            }
            Integer countError = 0;
            List<DemandDetail__c> recordToUnStop = [Select Id,IsStop__c,StopFlg__c,
                                  ErrorMessage__c,ManipulateStatus__c from DemandDetail__c where Id in: ids];
            for(DemandDetail__c d: recordToUnStop){
                if(d.StopFlg__c == null || d.IsStop__c == false)
                {
                    countError++;
                    d.ErrorMessage__c = '対象レコードは停止されていません。';
                    d.ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                }else{
                    d.StopFlg__c = null;
                    d.ErrorMessage__c = ''; 
                    d.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
                }
            }
            List<DemandDetail__c> failedList = new List<DemandDetail__c>();
            // update demand List        
            String[] listField = new String[]{'StopFlg__c','IsStop__c','ManipulateStatus__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)) {                
                Savepoint sp;
                if(!Test.isRunningTest()){
                    sp = Database.setSavepoint();
                } 
                // update demand
                Database.SaveResult[] rsList = Database.update(recordToUnStop,false);
                for(Integer i=0;i<rsList.size();i++){
                    if(!rsList[i].isSuccess())
                    {
                        String errMessage = '';
                        for(Database.Error e : rsList[i].getErrors()){
                            errMessage+= e.getMessage() + '\n';
                        }
                        // when raise error: ==> update stop flag into old value
                        recordToUnStop[i].StopFlg__c = CLP_MikataConstant.FLG_STOP;
                        recordToUnStop[i].ErrorMessage__c = errMessage;
                        recordToUnStop[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        failedList.add(recordToUnStop[i]);
                    }
                }
                system.debug('failedList:' + failedList);
                if(!failedList.isEmpty()) 
                {    
                    try{
                        update failedList;
                    }catch(DmlException ex){
                        if(!Test.isRunningTest()){
                            Database.rollback(sp);
                        }
                        throw new CLP_MikataApiException(ex.getDmlMessage(0));
                    }
                }
            }
            // click unstop
            Id jobId = CLP_DemandBulkUpsertBatch.startBatch(true,true);
            if(jobId==null){
                //return new CLP_JSONResult (false,null,'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');  
                return new CLP_JSONResult (true,0,'');   
            }
            countError+= failedList.size();
            return new CLP_JSONResult (true,failedList.size(),countError==0 ?'':String.ValueOf(countError));   
        }catch(Exception ex){
            if(ex.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
                return new CLP_JSONResult(false,null,'エラー302:関連する参照が停止中です。');
            //'エラー：権限がありません。'
            return new CLP_JSONResult(false,null,ex.getMessage());
        }
    }
    // bulk search demand
    @RemoteAction
    global static CLP_JSONResult bulkSearchDemand(){
         CLP_DemandBulkSearch.startBatch(true);
         /*try{
            // raise error don't config mikata before
            CLP_MikataApi mikataApi = new CLP_MikataApi();
            List<DemandDetail__c> details = [Select Id,ErrorMessage__c,AwaitingGetNewInfo__c,ManipulateStatus__c 
                                            from DemandDetail__c where IsIntegrated__c = true
                                            and StopFlg__c = null and BillIssueDate__c !=null and AwaitingGetNewInfo__c = false];
            for(DemandDetail__c d: details){
                d.ErrorMessage__c = ''; 
                d.AwaitingGetNewInfo__c = true;
                d.ManipulateStatus__c = CLP_MikataConstant.DEMAND_LINK_AWAITING;
            }
            List<DemandDetail__c> failedList = new List<DemandDetail__c>();
            // update demand List        
            String[] listField = new String[]{'ErrorMessage__c','AwaitingGetNewInfo__c','ManipulateStatus__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
                Savepoint sp;
                if(!Test.isRunningTest()){
                    sp = Database.setSavepoint();
                }
                // update demand
                Database.SaveResult[] rsList = Database.update(details,false);
                for(Integer i=0;i<rsList.size();i++){
                    if(!rsList[i].isSuccess())
                    {
                        String errMessage = '';
                        for(Database.Error e : rsList[i].getErrors()){
                            errMessage+= e.getMessage() + '\n';
                        }
                        details[i].ErrorMessage__c = errMessage;
                        // reset AwaitingGetNewInfo__c flag
                        details[i].AwaitingGetNewInfo__c = false;
                        details[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                        failedList.add(details[i]);
                    }
                }
                system.debug('failedList:' + failedList);
                if(!failedList.isEmpty())     
                {    
                    try{
                        update failedList;
                    }catch(DmlException ex){                        
                        if(!Test.isRunningTest()){
                            Database.rollback(sp);
                        }
                        throw new CLP_MikataApiException(ex.getDmlMessage(0));
                    }
                }
            }

            Id jobId = CLP_DemandBulkSearchBatch.startBatch(true);
            if(jobId==null){
                //return new CLP_JSONResult (false,null,'エラー：他のプロセスが実施されていますので、本プロセスは待機状態になります。');
                return new CLP_JSONResult (true,0,'');      
            }
            return new CLP_JSONResult (true,failedList.size(),failedList.size()==0 ?'':String.ValueOf(failedList.size()));    
        }catch(Exception ex){
            if(ex.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
                return new CLP_JSONResult(false,null,'エラー302:関連する参照が停止中です。');
            //'エラー：権限がありません。'
            return new CLP_JSONResult(false,null,ex.getMessage());
        }*/
        return new CLP_JSONResult (true,0,'');
    }
    @RemoteAction 
    global static CLP_JSONResult bulkDeleteDemand(String jsonObject){
        try{
            List<DemandDetail__c> details = (List<DemandDetail__c>) JSON.deserializeStrict(jsonObject, List<DemandDetail__c>.class);
            Set<Id> ids = new Set<Id>();
            for(DemandDetail__c d: details){
                ids.add(d.Id);
            }
            Integer countError = 0;
            List<DemandDetail__c> recordToDelete = [Select Id,ErrorMessage__c,IsStop__c,IsIntegrated__c from DemandDetail__c where Id in: ids];
            system.debug('recordToDelete:' + recordToDelete);
            List<DemandDetail__c> failedList = new List<DemandDetail__c>();
            // update demand List
            String[] listField = new String[]{'ErrorMessage__c'};
            if(CLP_CommonUtil.checkFLS(CLP_MikataConstant.SOBJECT_DEMAND_DETAIL,listField, CLP_CommonUtil.FLSType.UPDATE_OBJECT)){                
                Savepoint sp;
                if(!Test.isRunningTest()){
                    sp = Database.setSavepoint();
                }
                // update demand
                if (DemandDetail__c.sObjectType.getDescribe().isDeletable()) {
                    Database.DeleteResult[] rsList = Database.delete(recordToDelete,false);
                    for(Integer i=0;i<rsList.size();i++){
                        if(!rsList[i].isSuccess())
                        {
                            String errMessage = '';
                            for(Database.Error e : rsList[i].getErrors()){
                                errMessage+= e.getMessage() + '\n';
                            }
                            recordToDelete[i].ErrorMessage__c = errMessage;
                            recordToDelete[i].ManipulateStatus__c = CLP_MikataConstant.DEMAND_DATA_DEFECT;
                            failedList.add(recordToDelete[i]);
                        }
                    }
                    system.debug('failedList:' + failedList);
                    if(!failedList.isEmpty())     
                    {    
                        try{
                            update failedList;
                        }catch(DmlException ex){
                            if(!Test.isRunningTest()){
                                Database.rollback(sp);
                            }
                            throw new CLP_MikataApiException(ex.getDmlMessage(0));
                        }
                    }
                }
            }
            countError+= failedList.size();
            return new CLP_JSONResult (true,failedList.size(),countError==0 ?'':String.ValueOf(countError));   
        }catch(Exception ex){
            if(ex.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION'))
                return new CLP_JSONResult(false,null,'エラー302:関連する参照が停止中です。');
            //'エラー：権限がありません。'
            return new CLP_JSONResult(false,null,ex.getMessage());
        }
    }

    /* go to new relatedlist record
     parentObject: Account
     relatedObject: PaymentMethod
     relatedField: Account__c
     recordId: AccountId*/
    @RemoteAction 
    webService static String getRelatedListURL(String parentObject, String relatedObject,String relatedField, String recordId){
        try{
        String query = String.format('Select Id,Name From {0} where Id=\'\'{1}\'\' limit 1', new String[]{String.escapeSingleQuotes(parentObject),String.escapeSingleQuotes(recordId)});
        
        SObject objs = Database.query(query);

        String url = CLP_CommonUtil.getRelatedListURL(relatedObject,relatedField,String.valueOf(objs.get('Name')),recordId);
        system.debug(url);
        return url;
        } catch(Exception ex){
            return '';
        }
    }

    // define wrap object to show data in gridview
    global class WrapObject{
        public String id {get;set;}        
        public String apiName {get;set;}
        // lookup field name
        public String lookupName {get;set;}
        public String dataType {get;set;}
        public String label{get;set;}
        public Boolean isEditable{get;set;}
        public Boolean isCustom{get;set;}
    }

}