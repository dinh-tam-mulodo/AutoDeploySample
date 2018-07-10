global with sharing class MAP_CompanyUploadCsv {
    public static String prefix {get;set;}

    public MAP_CompanyUploadCsv(){
        prefix = MAP_CommonUtil.ENV_PREFIX_JS;
    }

    // Load Data from file csv
    @RemoteAction
    global static MAP_JsonResult saveData(String jsonString) {
        Set<String> compIds = new Set<String>();
        List<CsvObject> lstCsv = (List<CsvObject>)JSON.deserialize(jsonString, List<CsvObject>.class);
        Map<String, CsvObject> mapCSV = new Map<String, CsvObject>();
        MAP_JsonResult jsonResult;
        //String msgReturn = '';
        for(CsvObject record : lstCsv){
            compIds.add(record.M_ID);
            mapCSV.put(record.M_ID, record);
        }

        //WHAT IF comIds.size() > 500
        if(compIds.size() > 0){
            MAP_ConnectionSetting__c setting = MAP_ConnectionSetting__c.getInstance();
            if(setting != null){
                if(setting.IsUseCompanyInfo__c){
                    String compIdsParam = listIdToAPIParam(compIds);
                    String apiEnpoint = String.format(MAP_AppContants.API_URL_FORMAT, new List<String>{setting.Endpoint__c, setting.AuthenticationID__c,compIdsParam});
                    String apiResult = MAP_CommonUtil.calloutRESTApi(apiEnpoint);
                    jsonResult = createObjectFromCSVAndAPIResult(mapCSV, apiResult);

                }else{
                    jsonResult = createObjectFromCSV(lstCsv);
                }
            }
            
        }
        return jsonResult;
    }

    @RemoteAction
    global static String getTargetCompany(Integer offset, Integer size, Integer total, Map<String, String> rawConditions){
        System.debug(rawConditions);
        DataWrapper result = new DataWrapper();
        try{
            MAP_FieldOption__c setting = [SELECT FieldsOfType__c FROM MAP_FieldOption__c WHERE Type__c = :MAP_AppContants.DISPLAY_FIELD LIMIT 1];
            Map<String, Object> showFields = (Map<String, Object>)JSON.deserializeUntyped(setting.FieldsOfType__c);
            String query = buildQuery(showFields.keySet(), offset, size, rawConditions);
            List<SObject> objects = Database.query(query);
            List<Map<String,String>> formatedObject = new List<Map<String,String>>();
            List<String> showFieldKey = new List<String>(showFields.keySet());
            List<String> showFieldKeyReverse = new List<String>();
            for(Integer i = showFieldKey.size() - 1; i >= 0; i--){
                showFieldKeyReverse.add(showFieldKey[i]);
            }
            for(SObject obj : objects){
                Map<String,String> objAsMap = new Map<String,String>();
                for(String key : showFieldKeyReverse){
                    String fieldValue = String.valueOf(obj.get(key));
                    if(fieldValue == null){
                        fieldValue = '';
                    } 
                    objAsMap.put(key, fieldValue);
                }
                Boolean isConverted = Boolean.valueOf(obj.get(MAP_AppContants.APP_PREFIX + 'IsConverted__c'));
                Boolean isConvertFailed = Boolean.valueOf(obj.get(MAP_AppContants.APP_PREFIX + 'IsConvertFail__c'));
                String recordStatus = 'new';
                if(isConverted){
                    recordStatus = 'converted';
                }else if(isConvertFailed){
                    recordStatus = 'failed';
                }
                objAsMap.put('Id', String.valueOf(obj.get('Id')));
                objAsMap.put('RecordStatus', recordStatus);
                formatedObject.add(objAsMap);
            }

            result.total = total;
            String whereStatement = buildWhereStatement(rawConditions);
            //if(total < 0){
                result.total = MAP_CommonUtil.countRecord(MAP_AppContants.OBJ_TARGET_COMPANY, whereStatement);
            //}
            result.records = formatedObject;
            result.showFields = showFields;
            return JSON.serialize(result);

        }catch(Exception ex){
            System.debug(ex);
            return null;
        }
    }

    @RemoteAction
    global static String getScoreHistory(String id){
        Map<String, Decimal> scoreHistory = new Map<String, Decimal>();
        try{
            MAP_TargetCompany__c targetCompay = [SELECT CompanyCode__c FROM MAP_TargetCompany__c WHERE Id = :id];
            List<MAP_TargetCompany__c> companies = [SELECT RegistedDate__c, Score__c FROM MAP_TargetCompany__c WHERE CompanyCode__c = :targetCompay.CompanyCode__c];
            for(MAP_TargetCompany__c company : companies){
                if(!String.isBlank(company.RegistedDate__c)){
                    scoreHistory.put(company.RegistedDate__c, company.Score__c);
                }
            }
            return JSON.serialize(scoreHistory);
        }catch(Exception ex){
            return '';
        }
    }

    /* 
    Created Date: 05/09/17
    Create By: Minh Tuan
    Description: Load Company Information by ID 
     */
    @RemoteAction global static MAP_TargetCompany__c getTargetCompanyById(string id){
        try{
            MAP_TargetCompany__c company = [SELECT Id, Name, HPURL__c, HPURLnor__c, Mail__c, RegistedDate__c, PageUrl__c,
                                            PageURLnor__c, OrgId__c, Shogo__c, Shogonor__c, Gyoshu__c, Add__c,
                                            Addnor__c, Emp__c, Pub__c, Tel__c, Zip__c, Fax__c, Segment__c, Score__c,
                                            CompanyCode__c, IsUsedAPIData__c, IsConverted__c
                                            FROM MAP_TargetCompany__c WHERE Id =: id];
            System.debug('getTargetCompanyById:' + company);
            return company;
        }catch(Exception ex){
            return null;
        }
    }

     /* 
    Created Date: 05/09/17
    Create By: Minh Tuan
    Description: Save Target Company Information 
    */
    @RemoteAction global static MAP_JsonResult saveTargetCompany(Map<string,String> data){
        try{
            System.debug('data: ' + data);
            MAP_TargetCompany__c comp = new MAP_TargetCompany__c();
            comp.Id = data.get('Id');
            comp.Name = data.get('Name');
            comp.HPURL__c = data.get('HPURL__c');
            comp.HPURLnor__c = data.get('HPURLnor__c');
            comp.Mail__c = data.get('Mail__c');
            comp.RegistedDate__c = data.get('RegistedDate__c');
            comp.PageUrl__c = data.get('PageUrl__c');
            comp.PageURLnor__c = data.get('PageURLnor__c');
            comp.OrgId__c = data.get('OrgId__c');
            comp.Shogo__c = data.get('Shogo__c');
            comp.Shogonor__c = data.get('Shogonor__c');
            comp.Gyoshu__c = data.get('Gyoshu__c');
            comp.Add__c = data.get('Add__c');
            comp.Addnor__c = data.get('Addnor__c');
            comp.Emp__c = data.get('Emp__c');
            comp.Pub__c = data.get('Pub__c');
            comp.Tel__c = data.get('Tel__c');
            comp.Zip__c = data.get('Zip__c');
            comp.Fax__c = data.get('Fax__c');
            comp.Segment__c = data.get('Segment__c');
            comp.Score__c = Decimal.valueOf(data.get('Score__c'));
            comp.CompanyCode__c = String.valueOf(data.get('CompanyCode__c'));

            System.debug(comp); 
            upsert comp;
            return new MAP_JsonResult(true, null, 'ターゲット企業の変更に成功しました。');
        }catch(Exception ex){
            string exMsg = 'ターゲット企業の変更に失敗しました。';
            return new MAP_JsonResult(false, null, exMsg);
        }
    }

    /* 
    Created Date: 07/09/17
    Create By: Minh Tuan
    Description: Delete target company
    */
    @RemoteAction global static MAP_JsonResult deleteTargetCompany(string id){
        try{
            MAP_TargetCompany__c comp = [SELECT Id, Name FROM MAP_TargetCompany__c WHERE Id =: id];
            if (comp == null){
                system.debug('deleteTargetCompany comp == null');
                string errorMsg = 'ターゲット企業が存在していません。';
                return new MAP_JsonResult(false, null, errorMsg);
            }

            string msg = '「' + comp.Name + '」ターゲット企業の削除に成功しました。';
            delete comp;
            system.debug(msg);
            return new MAP_JsonResult(true, null, msg);
        }catch (Exception ex){
            string exMsg = 'ターゲット企業の削除に失敗しました。';
            return new MAP_JsonResult(false, null, exMsg);
        }
    }

    /*
    Created Date: 13/09/17
    Create By: Minh Tuan
    Description: Get List Filter Condition Setting
    */
    @RemoteAction global static string getFilterConditionSettings(){
        try {
            List<MAP_FilterConditionSetting__c> filterList = [SELECT External_Id__c,Child_Id__c, Filter_Name__c,Filter_Type__c,Filter_Value__c
                                                              FROM MAP_FilterConditionSetting__c];
            for(MAP_FilterConditionSetting__c filter : filterList){
                filter.Child_Id__c = replaceNullWithEmpty(filter.Child_Id__c);
                filter.External_Id__c = replaceNullWithEmpty(filter.External_Id__c); 
            }
            //system.debug(filterList);
            return JSON.serialize(filterList);
        }catch(Exception ex){
            return '';
        }
    }

    @TestVisible private static String replaceNullWithEmpty(String s){
        return s == null ? '' : s;
    }

    private static String buildQuery(Set<String> fieldApiName, Integer offset, Integer size, Map<String, String> rawConditions){
        /* Date 19/09/17 Rewrite function buildWhereStatement
        List<String> conditionAsList = new List<String>();

        for(String fieldName : rawConditions.keySet()){
            if(!String.isBlank(rawConditions.get(fieldName))){
                String subQuery = MAP_CommonUtil.ENV_PREFIX + fieldName + ' IN (' + rawConditions.get(fieldName) + ')';
                conditionAsList.add(subQuery);
            }
        }
        String whereStatement = ' WHERE ' + String.join(conditionAsList, ' AND ' );
        System.debug(whereStatement);
        */

        // build where stament
        String whereConditions = buildWhereStatement(rawConditions);
        System.debug('whereConditions'+ whereConditions);
        
        List<String> showFieldsApiName = new List<String>();
        for(String key : fieldApiName){
            showFieldsApiName.add(key);
        }
        //String whereConditions = conditionAsList.size() > 0 ? whereStatement : '';

        String filedsAsString = String.join(showFieldsApiName, ',');
        if(!filedsAsString.contains('IsConverted__c')){
            filedsAsString += ',' + MAP_AppContants.APP_PREFIX + 'IsConverted__c';
        }
        if(!filedsAsString.contains('IsConvertFail__c')){
            filedsAsString += ',' + MAP_AppContants.APP_PREFIX + 'IsConvertFail__c';
        }
        System.debug('SELECT Id,' + String.escapeSingleQuotes(filedsAsString) + ' FROM ' + MAP_AppContants.OBJ_TARGET_COMPANY + whereConditions +  ' LIMIT ' + size + ' OFFSET ' + offset);
        return 'SELECT Id,' + String.escapeSingleQuotes(filedsAsString) + ' FROM ' + MAP_AppContants.OBJ_TARGET_COMPANY + whereConditions +  ' LIMIT ' + size + ' OFFSET ' + offset;
    }

    /* 
    Created Date: 19/09/17
    Create By: Minh Tuan
    Description: Build where statement based on raw condition 
    */
    private static string buildWhereStatement(Map<String, String> rawConditions){
        List<String> conditionAsList = new List<String>();

        // iterate condition
        for(String fieldName : rawConditions.keySet()){
            if(!String.isBlank(rawConditions.get(fieldName))){
                // combine field name with prefix
                String subQuery = MAP_CommonUtil.ENV_PREFIX + fieldName + ' IN (' + rawConditions.get(fieldName) + ')';
                conditionAsList.add(subQuery);
            }
        }

        String whereStatement = ' WHERE ' + String.join(conditionAsList, ' AND ' );
        // remove where statement if no condition was specific
        String whereConditions = conditionAsList.size() > 0 ? whereStatement : '';
        System.debug(whereConditions);

        return whereConditions;
    }

    private static String listIdToAPIParam(Set<String> ids){
        List<String> queryConditions = new List<String>();
        for (String id : ids) {
            queryConditions.add('(compno:' + id + ')');
        }
        return String.join( queryConditions, 'OR' );
    }

    private static MAP_JsonResult createObjectFromCSVAndAPIResult(Map<String, CsvObject> mapCSV, String apiJson){
        List<MAP_TargetCompany__c> listCustomObject = new List<MAP_TargetCompany__c>();
        MAP_APIResult jsonResult = (MAP_APIResult)JSON.deserialize(apiJson, MAP_APIResult.class);
        List<String> companyIds = new List<String>();
        List<String> lstItemFail = new List<String>();
        try{
            if(jsonResult.response != null){
                if(jsonResult.response.docs != null){
                    MAP_TargetCompany__c customObject;
                    for(MAP_APIResult.Doc doc : jsonResult.response.docs){
                        customObject = new MAP_TargetCompany__c();
                        customObject.Fax__c = doc.fax == null? '' : String.join( doc.fax, ',' );
                        customObject.HPURL__c = doc.hpurl;
                        customObject.HPURLnor__c = doc.hpurlnor;
                        customObject.PageUrl__c = doc.pageurl;
                        customObject.PageURLnor__c = doc.pageurlnor;
                        customObject.OrgId__c = doc.orgid;
                        customObject.Mail__c = doc.mail;
                        customObject.Shogonor__c = doc.shogonor == null? '' : String.join(doc.shogonor, ',' );
                        customObject.Gyoshu__c = doc.gyoshu;
                        customObject.Add__c = doc.add == null? '' : String.join(doc.add, ',' );
                        customObject.Addnor__c = doc.addnor == null? '' : String.join(doc.addnor, ',' );
                        customObject.Emp__c = doc.emp;
                        customObject.Pub__c = doc.pub;
                        customObject.Tel__c = doc.tel == null? '' : String.join(doc.tel, ',' );
                        customObject.Zip__c = doc.zip == null? '' : String.join(doc.zip, ',' );
                        customObject.Shihon__c = doc.shihon;
                        customObject.Revenue__c = doc.revenue;
                        customObject.Pref__c = doc.pref == null? '' : String.join(doc.pref, ',' );

                        customObject.IsUsedAPIData__c = true;
                        companyIds.add(doc.compno);
                        CsvObject csv = mapCSV.get(doc.compno);
                        if(csv != null){
                            customObject.Score__c = Decimal.ValueOf(csv.ABM_SCORE);
                            customObject.Segment__c = csv.SEGMENT;
                            customObject.CompanyCode__c = csv.M_ID;
                            customObject.Shogo__c = csv.CNAME;
                            customObject.RegistedDate__c = csv.REPORT_DATE;
                            customObject.ExternalKey__c = customObject.Segment__c + csv.REPORT_DATE + customObject.CompanyCode__c;//Missong date
                            mapCSV.remove(doc.compno);
                        }
                        listCustomObject.add(customObject);
                    }
                } 
            } 
            String msg = '';
            Integer numberRecordPass = 0;
            if(listCustomObject.size() > 0){
                Database.UpsertResult[] results = Database.upsert(listCustomObject,MAP_TargetCompany__c.Fields.ExternalKey__c,false);
                MAP_SendRequestTobeMBatch batch = new MAP_SendRequestTobeMBatch(companyIds);          
                Database.executeBatch(batch);
                //requestTobemApi(companyIds, tobemEndpoint);

                // Get item upsert success and fail.
                for(Integer i = 0; i < results.size(); i++) {
                    if(results.get(i).isSuccess()) {
                       numberRecordPass ++;
                    } else {
                        lstItemFail.add(listCustomObject.get(i).ExternalKey__c);
                    }
                }
                
            }

            MAP_JsonResult jsonResultCsv;
            Integer intNumberTotalCsv = 0;
            Integer intNumberFailCsv = 0;
            Integer intNumberPassCsv = 0;

            if(mapCSV.keySet().size() > 0){
                List<CsvObject> notFoundInApi = new List<CsvObject>();
                for(String key : mapCSV.keySet()){
                    notFoundInApi.add(mapCSV.get(key));
                }
                jsonResultCsv = createObjectFromCSV(notFoundInApi);
                intNumberTotalCsv = notFoundInApi.size();
                intNumberFailCsv = jsonResultCsv.listFail.size();
                intNumberPassCsv = intNumberTotalCsv - intNumberFailCsv;
            }

            msg = '処理済の総数: ' + (listCustomObject.size() + intNumberTotalCsv)
                         + ' （成功: ' + (numberRecordPass + intNumberPassCsv)
                         +  '、失敗: ' + (lstItemFail.size() + intNumberFailCsv)  + ' ）';

            return new MAP_JsonResult(true, null, msg, lstItemFail);
        }catch(Exception ex){
            return null;
        }
    }

    private static MAP_JsonResult createObjectFromCSV(List<CsvObject> lstCsv){
        List<MAP_TargetCompany__c> listCustomObject = new List<MAP_TargetCompany__c>();
        MAP_TargetCompany__c customObject;
        try{ 
            for(CsvObject csv : lstCsv){
                customObject = new MAP_TargetCompany__c();
                customObject.Score__c = Decimal.ValueOf(csv.ABM_SCORE);
                customObject.Segment__c = csv.SEGMENT;
                customObject.CompanyCode__c = csv.M_ID;
                customObject.Shogo__c = csv.CNAME;
                customObject.RegistedDate__c = csv.REPORT_DATE;
                customObject.ExternalKey__c = csv.SEGMENT + csv.REPORT_DATE + csv.M_ID;
                listCustomObject.add(customObject);
            }
            String msg = '';
            Integer numberRecordPass = 0;
            List<String> lstItemFail = new List<String>();
            if(listCustomObject.size() > 0){
                Database.UpsertResult[] results = Database.upsert(listCustomObject,MAP_TargetCompany__c.Fields.ExternalKey__c,false);  
              
                // Get item upsert success and fail.
                for(Integer i = 0; i < results.size(); i++) {
                    if(results.get(i).isSuccess()) {
                       numberRecordPass ++;
                    } else {
                       lstItemFail.add(listCustomObject.get(i).ExternalKey__c);
                    }
                }

                msg = '処理済の総数: ' + results.size()
                         + ' （成功: ' + numberRecordPass
                         +  '、失敗: ' + (results.size() - numberRecordPass) + ' ）';
            }

            return new MAP_JsonResult(true, null, msg, lstItemFail);
        }catch(Exception ex){
            return null;
        }            
    }


    // Convert information company target to Account and Lead.
    @RemoteAction
    global static MAP_JsonResult convertCompanyTarget(List<String> lstCompanyTargetId) {
        Boolean isSingle = false;
        Boolean status   = false;
        try {
                List<MAP_ItemMapping__c>      lstMapping    = [SELECT Account_ITA__c, Lead_ITA__c
                                                                 FROM MAP_ItemMapping__c
                                                                LIMIT 1];

                List<MAP_TargetCompany__c> lstTargetCompany = [SELECT Id, Name, IsUsedAPIData__c, ExternalKey__c, Fax__c, HPURL__c, 
                                                                      HPURLnor__c, Score__c, Segment__c, PageUrl__c, PageURLnor__c,
                                                                      Mail__c, OrgId__c, Shogo__c, Shogonor__c, Gyoshu__c, Add__c, 
                                                                      Addnor__c, Emp__c, Pub__c, Tel__c, IsConverted__c, IsConvertFail__c,
                                                                      RegistedDate__c, CompanyCode__c, Zip__c,
                                                                      Account_Converted__c, Lead_Converted__c
                                                                 FROM MAP_TargetCompany__c
                                                                WHERE Id In :lstCompanyTargetId];

                List<MAP_TargetCompany__c> lstCompanyConveted = [SELECT Id, CompanyCode__c, IsConverted__c, IsConvertFail__c,
                                                                        Account_Converted__c, Lead_Converted__c
                                                                 FROM MAP_TargetCompany__c
                                                                WHERE IsConverted__c = true];

                String msg = '';

                // Check setting mapping.
                if(lstMapping.size() == 0) {
                    msg = '「登録項目マッピング」画面でマッピング項目一覧をチェックして下さい。';
                    return new MAP_JsonResult(status, null, msg);
                }

                // Check item selected exist or not
                if(lstTargetCompany.size() == 0) {
                    msg = '企業一覧が存在していません。';
                    return new MAP_JsonResult(status, null, msg);
                }

                // Check list return is single or plural.
                if(lstCompanyTargetId.size() == 1 ) {
                    isSingle  = true;
                }

                Map<String, Object> mapAccountITA = (Map<String, Object>)JSON.deserializeUntyped(lstMapping.get(0).Account_ITA__c);
                Map<String, Object> mapLeadITA    = (Map<String, Object>)JSON.deserializeUntyped(lstMapping.get(0).Lead_ITA__c);
                List<Lead>       lstLead = new List<Lead>();
                List<Account> lstAccount = new List<Account>();
                Lead    lead;
                Account account;
                List<MAP_TargetCompany__c> lstCompanyConvert = new List<MAP_TargetCompany__c>();
                List<MAP_TargetCompany__c> lstTargetCompanyConverted = new List<MAP_TargetCompany__c>();
                Integer intNumberOfConverted = 0;
                List<String> lstAccLeadConv = new List<String>();
                
                // Get list Target Company Converted
                for(MAP_TargetCompany__c targetCompany : lstTargetCompany) {
                    lstAccLeadConv = getAccLeadRef(targetCompany.CompanyCode__c, lstCompanyConveted);

                    if(lstAccLeadConv.size() == 0) {
                        lstCompanyConvert.add(targetCompany);
                        account = new Account();
                        lead = new Lead();

                        for(String key : mapAccountITA.keySet()) {
                             account.put(key, targetCompany.get((String)mapAccountITA.get(key)));
                        }

                         lstAccount.add(account);

                        for(String key : mapLeadITA.keySet()) {
                            if(key.equalsIgnoreCase(MAP_AppContants.FIELD_LASTNAME_MAPPING)){
                                lead.put(key, MAP_AppContants.FIELD_DISABLE_MAPPING);
                            } else {
                                lead.put(key, targetCompany.get((String)mapLeadITA.get(key)));
                            }
                        }

                         lstLead.add(lead);
                    } else {
                        targetCompany.Account_Converted__c = lstAccLeadConv.get(0);
                        targetCompany.Lead_Converted__c    = lstAccLeadConv.get(1);
                        targetCompany.IsConverted__c       = true;
                        lstTargetCompanyConverted.add(targetCompany);
                        intNumberOfConverted ++;
                    }
                }

                // Update database for the different value in the same company code
                update lstTargetCompanyConverted ;

                // DML statement List Account.
                Database.SaveResult[] srListAccount = Database.insert(lstAccount, false);
                Database.SaveResult[] srListLead = Database.insert(lstLead, false);

                List<Account> lstAccFail = new List<Account>();
                List<Lead> lstLeadFail   = new List<Lead>();
                Integer   intNumbSuccess = 0;
                Integer   intNumbFail = 0;

                // Loop to check record inserted or not.
                for(Integer i = 0; i < srListAccount.size(); i++) {
                    if(srListAccount.get(i).isSuccess() && srListLead.get(i).isSuccess()) {

                       // Update field up object Target company isConvert -> true
                       lstCompanyConvert.get(i).IsConverted__c = true;
                       lstCompanyConvert.get(i).Account_Converted__c = srListAccount.get(i).getId();
                       lstCompanyConvert.get(i).Lead_Converted__c = srListLead.get(i).getId();

                       intNumbSuccess ++;

                    } else if (!srListAccount.get(i).isSuccess()) {

                       // Add all record of Company has fail in converting to revert data.
                       lstLeadFail.add(lstLead.get(i));
                       
                       // Update property for showing status record
                       lstCompanyConvert.get(i).IsConvertFail__c = true;

                       intNumbFail ++;

                    } else if (!srListLead.get(i).isSuccess()) {

                       // Add all record of Company has fail in converting to revert data.
                       lstAccFail.add(lstAccount.get(i));
                       
                       // Update property for showing status record
                       lstCompanyConvert.get(i).IsConvertFail__c = true;

                       intNumbFail ++;
                    }
                }

                // Update record has been changed.
                if (lstCompanyConvert.size() > 0) {
                    Database.UpsertResult[] results = Database.upsert(lstCompanyConvert,false);
                }

                // Delete record has been fail in converted.
                if (lstAccFail.size() > 0) {
                    delete lstAccFail;
                }

                if (lstLeadFail.size() > 0) {
                    delete lstLeadFail;
                }
                
                // Setting message and status message
                if(isSingle && intNumbSuccess > 0) {
                    msg = '企業の変換に成功しました。';
                    status = true;

                } else if(isSingle && intNumbFail > 0 ) {
                    msg = '企業の変換に失敗しました。';
                    status = false;

                } else if(isSingle && intNumberOfConverted > 0) {
                    msg = '本企業は既に変換されました。別の企業を選択してください。';
                    status = false;

                } else if(!isSingle) {
                    msg = '処理済の総数: ' + lstTargetCompany.size()
                                      + ' （成功: ' + intNumbSuccess
                                      + '、失敗: ' + intNumbFail 
                                      + '、変換済:' + intNumberOfConverted + ' ）';

                    // Setting status message
                    if(intNumbFail > 0) {
                        status = false;
                    } else {
                        status = true;
                    }
                }

                return new MAP_JsonResult(status, null, msg);
        } catch (Exception ex){
           System.debug(ex);
           return null;
        }
    }

    // Check the conversion of company code.
    private static List<String> getAccLeadRef(String companyCdCheck, List<MAP_TargetCompany__c> lstCompanyConverted) {
        
        List<String> lstAccLead = new List<String>();

        for (MAP_TargetCompany__c targetCompany : lstCompanyConverted) {
            if (targetCompany.CompanyCode__c.equalsIgnoreCase(companyCdCheck)) {
                lstAccLead.add(targetCompany.Account_Converted__c);
                lstAccLead.add(targetCompany.Lead_Converted__c);
                return lstAccLead;
            }
        }

        return lstAccLead;
    }

    // CSVObject defination
    public class CsvObject{
        public String SEGMENT;
        public String REPORT_DATE;
        public String NEW_HEAD_LBC;
        public String CNAME;
        public String ABM_SCORE;
        public String M_ID;
    }
    public class DataWrapper {
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<Map<String,String>> records {get;set;}
        @AuraEnabled public Map<String, Object> showFields {get;set;}
    }
    public class SearchConditions{
        public String label;
        public String value;
        public String parentId;
    }
}