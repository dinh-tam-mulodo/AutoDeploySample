public with sharing class REC_SearchObject_Ctrl{
    
    public String result {set; get;}
    public String count {set; get;}
    public String setting {set; get;}
    public String selectLimitCount {set; get;}
    public String requestJson{set; get;}
    public String requestSelectJson{set; get;}
    public String requestSortJson{set; get;}
    public String requestfieldSort{set; get;}
    public String title{set; get;}
    public boolean isVisibleSelectList{set; get;}
    public boolean isVisible{set; get;}
    public String requestPage{set; get;}
    public String settingName{set; get;}
    public String selectShoninType {set; get;}
    public String pageList{set; get;}
    public String pageinput{set; get;}
    public String prevPageList{set; get;}
    public String nextPageList{set; get;}
    public boolean isNextPage{set; get;}
    public boolean isPrevPage{set; get;}

    private String config = 'config';
    private String paramPage = 'page';
    private set<String> hiddenFields = null;
    private final Integer maxbyteSize = 563428;
    private Map<String,TargetFieldInfo> tmap;
    private REC_SearchObject_Ctrl.TargetObjectInfo targetObjectInfo = null;
    private String soqlField = '';
    private Integer page_size = 0;
    private Integer maxPageSize = 0;
    private Integer nextpg=0;
    private Integer prepg=0;
    public Integer getmaxPageSize(){
        return maxPageSize;
    }
    public Integer getnextpg(){

        return nextpg;
    }
    public Integer getprepg(){

        return prepg;
    }
    
    public List<SelectOption> getOptions2() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('25','25'));
        options.add(new SelectOption('50','50'));
        options.add(new SelectOption('100','100'));
        options.add(new SelectOption('200','200'));
        return options;
    }
    
    public REC_SearchObject_Ctrl() {
        try{
            this.isVisible = true;
            this.isVisibleSelectList = false;
            this.requestPage = '1';
            //this.settingName = ApexPages.currentPage().getParameters().containsKey(this.config)?String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get(this.config)):null;
            this.settingName ='Account';
            if(String.isBlank(this.settingName)){
                this.isVisible = false;
                this.title = '商品会議レポートリスト';
            }
            init();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public PageReference prev(){
        PageReference p = new PageReference('/apex/VoxerMDM__MRR_ProductReport');
        p.setRedirect(true);
        return p;
    }
    
    /*public PageReference createCSV(){
        this.csv();
        Document doc = new Document();
        
        doc.Body = Blob.valueof(this.result);

        doc.Name = '商品物流会議 レポート_' + Datetime.now().format('yyyyMMddHHmmss') + '.csv';
        doc.AuthorId = UserInfo.getUserId();
        
        List<Folder> foloderList = [select Id from Folder where DeveloperName = 'OutputDataProduct'];
        doc.FolderId = foloderList.get(0).Id;
        insert doc;
        Id userId = UserInfo.getUserId();
        String urlhead = Settings__c.getInstance().force_url__c + '/apex/';
        CMN_UserMailUtil.sendMailToUser(userId, 'データ出力終了通知', 'データ出力が終了しました。\n以下からダウンロードを行ってください。\n\n'+
            urlhead +'VoxerMDM__CSVDownloader?id='+doc.Id+'&charset=shift-jis');
        
        return null;
    }*/
    private String getRecordTypleTWKBench(String wkBenchRecType){
        List<Id> lsId=new List<Id>();
        String ret='';
        String quot='(';
        for(RecordType rec:[Select Id,toLabel(Name) From RecordType  Where SobjectType = 'VoxerMDM__MRR_ProductMaster__c' ]){
            if(rec.Name.contains(wkBenchRecType)){
                quot +=' RecordTypeId=\''+ rec.Id + '\' OR';
            }
        }
        quot=quot.removeEnd('OR');
        if(quot.length()>1) return (quot+')');
        return '';
    }
    public PageReference search(){
        System.debug('★ search:');
        if(tmap == null || tmap.isEmpty()){
            tmap = new Map<String,TargetFieldInfo>();
            if(targetObjectInfo == null){
                getSetting(this.settingName);
                targetObjectInfo = (REC_SearchObject_Ctrl.TargetObjectInfo)System.Json.deserialize(this.setting, Type.forName('VoxerMDM', 'REC_SearchObject_Ctrl.TargetObjectInfo'));
            }
            for(TargetFieldInfo info : targetObjectInfo.targetFieldInfoList){
                tmap.put(info.fieldName,info);
            }
        }
        System.debug('this.requestJson'+this.requestJson);
        REC_SearchObject_Ctrl.InputValues inputValues = (REC_SearchObject_Ctrl.InputValues)System.Json.deserialize(String.escapeSingleQuotes(this.requestJson), Type.forName('VoxerMDM', 'REC_SearchObject_Ctrl.InputValues'));
        REC_SearchObject_Ctrl.SortList inputSortList = (REC_SearchObject_Ctrl.SortList)System.Json.deserialize(this.requestSortJson, Type.forName('VoxerMDM', 'REC_SearchObject_Ctrl.SortList'));
        
        this.count = '';
        this.checkHiddenField();
        this.setHeader('search');
        String soql = createBaseSOQL();
        soql += createWHEREClause(inputValues) + createOrderClause(inputSortList) + ' limit ' + selectLimitCount + createOffset();        
        System.debug('aaaasoql = ' + soql);
        //System.debug('★soql = ' + requestfieldSort);
        List<SObject> sObjectList = Database.query(soql);
        Map<String,String> mpAppIds=new Map<String,String>();
        Integer i = 1;
        this.result +='<div class="body"><table><tbody>';
        for(SObject rec : sObjectList){            
            Integer tdCount = page_size + i;
            this.result += '<tr><td style="width:40px;text-align: center;vertical-align: middle;" >' + tdCount+ '</td><td style="width:50px;text-align: center;vertical-align: middle;" ><a href="#">Edit</a></td>';
            
            if(!String.isBlank(requestfieldSort)){
                String fileds = requestfieldSort.replaceAll('filedsort_','');
                List<String> flist = fileds.split(',');
                for(String field : flist){
                    TargetFieldInfo info = tmap.get(field);
                        if(info.fieldName.equalsIgnoreCase('ID') || info.fieldName.equalsIgnoreCase('VoxerMDM__WF_Comment__c')){
                            continue;
                        }
                        if(this.hiddenFields != null && this.hiddenFields.size() > 0 && this.hiddenFields.contains(info.fieldName)){
                            continue;
                        }
                        if(info.fieldName.equalsIgnoreCase('NAME')){
                            this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;"><a href="/' + rec.get('ID') + '" target="_blank" >' + rec.get(info.fieldName) + '</a></td>';
                        }else if(info.fieldName.indexOf('.') != -1){                            
                            List<String> keys = info.fieldName.split('\\.');
                            if(keys != null && keys.size() > 1){
                                sobject sobj = null;
                                Integer listCnt = keys.size();
                                object value = null;
                                String fname = '';//最下層のfieldname
                                for (Integer j = 0; j < listCnt ; j++) {
                                    try{
                                        if((listCnt - 1 ) == j && sobj != null){
                                            value = sobj.get(keys.get(j));
                                            fname = keys.get(j);
                                        }else{
                                            if(sobj != null){
                                                sobj = sobj.getSobject(keys.get(j));
                                            }else{
                                                sobj = rec.getSobject(keys.get(j));
                                            }
                                        }
                                    }catch(Exception e){}
                                }
                                if(sobj == null){
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;"></td>';
                                    continue;
                                }
                                                                                 
                               if(info.fieldName == 'RecordType.Name' && String.valueOf(value).indexOf('（')!=-1 || info.fieldName == 'RecordType.Name' && String.valueOf(value).indexOf('(')!=-1){           
                                   String kaigyoSymbol=(String.valueOf(value).indexOf('（')!=-1)?'（':'(';
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;">'  + String.valueOf(value).substring(0,String.valueOf(value).indexOf(kaigyoSymbol)) +'<br />'+String.valueOf(value).substring(String.valueOf(value).indexOf(kaigyoSymbol))+
                                    '</td>';                                    
                                    continue;
                                }    
                                else if(info.type.equalsIgnoreCase('DATE')){
                                    Date d = (Date)value;
                                    if(d != null){
                                        Datetime tmpDate = Datetime.newInstance(d.year(),d.month(), d.day());
                                        this.result += '<<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;">'  + tmpDate.addHours(9).format('yyyy/MM/dd') + '</td>';
                                    }else{
                                        this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;"></td>';
                                    }
                                }else if(info.type.equalsIgnoreCase('REFERENCE')){
                                    String val = '';
                                    if(String.valueOf(value) != null)val = String.valueOf(value);
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;"><a href="/' + sobj.get('ID') + '" target="_blank">' + val + '</a></td>';
                                }else if(info.type.equalsIgnoreCase('Boolean')){
                                    String val = '';
                                    if(value != null ){
                                        Map<String,String> m = replaceFlgVal(fname);
                                        val = String.valueOf(value);
                                        if(val.equals('true')){
                                            if(m != null){
                                                val = m.get('true');
                                            }else{
                                                val = 'あり';
                                            }
                                        }else{
                                            if(m != null){
                                                val = m.get('false');
                                            }else{
                                                val = 'なし';
                                            }
                                        }
                                    }
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;">' + val + '</td>';                              
                                }else{
                                    String val = '';
                                    if(String.valueOf(value) != null)val = String.valueOf(value);
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;">' + val + '</td>';
                                }
                            }
                        }else{                            
                            if(info.type.equalsIgnoreCase('DATE')){
                                Date d = (Date)rec.get(info.fieldName);
                                Datetime tmpDate = Datetime.newInstance(d.year(),d.month(), d.day());
                                this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;">' + tmpDate.addHours(9).format('yyyy/MM/dd') + '</td>';
                            }else if(info.type.equalsIgnoreCase('Boolean')){
                                String val = '';
                                if(rec.get(info.fieldName) != null ){
                                    val = String.valueOf(rec.get(info.fieldName));
                                    Map<String,String> m = replaceFlgVal(info.fieldName);
                                    if(val.equals('true')){
                                        if(m != null){
                                            val = m.get('true');
                                        }else{
                                            val = 'あり';
                                        }
                                    }else{
                                        if(m != null){
                                            val = m.get('false');
                                        }else{
                                            val = 'なし';
                                        }
                                    }
                                }
                                this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;">' + val + '</td>';
                            }else if(info.type.equalsIgnoreCase('URL')){
                                if(rec.get(info.fieldName) == null){
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;"></td>';
                                }else{
                                    List<String> linkText = String.valueOf(rec.get(info.fieldName)).split('=');
                                    String hrefurl  = '';
                                    String hreftext = '';
                                    system.debug('★URL確認：linkText：' + String.valueOf(rec.get(info.fieldName)));
                                    system.debug('★URL確認：linkText.size()：' + linkText.size());
                                    system.debug('linkText'+linkText);
                                    if(linkText != null && linkText.size() >= 1){                                       
                                    }else{
                                        system.debug('それ以外 の場合');
                                        hrefurl  = String.valueOf(rec.get(info.fieldName));
                                        //hreftext = String.valueOf(rec.get(info.fieldName));
                                        hreftext = '確認リンク';
                                    }
//                                    this.result += '<td><a href="' + rec.get(info.fieldName) + '" target="_blank">' + hreftext + '</a></td>';
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;"><a href="' + hrefurl + '" target="_blank">' + hreftext + '</a></td>';
                                }
                            }else{
                                if(rec.get(info.fieldName) == null){
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;"></td>';
                                }else{
                                    this.result += '<td style="width:'+info.width+'px;text-align: center;vertical-align: middle;">' + rec.get(info.fieldName) + '</td>';
                                }
                            }
                        }
                }
            }
            this.result += '</tr>';
            i++;
        }
        this.result += '</tbody></table></div></div></div>';        
        createPaging();
        if(Blob.valueOf(this.result).size() > maxbyteSize){
            this.result = '検索結果が大きすぎるので検索条件を追加してください。';
        }
        return null;
    }
    
    private Map<String,Map<String,String>> flgMap = null;
    private Map<String,String> replaceFlgVal(String fieldName){
        if(flgMap == null){
            flgMap = new Map<String,Map<String,String>>();
            Map<String,String> valMap = new Map<String,String>();
            // 製造日含む
            valMap.put('true','含む');
            valMap.put('false','含まない');
            flgMap.put('VoxerMDM__include_production_date_flg__c',valMap);
            // ピッキング
            Map<String,String> valMap2 = new Map<String,String>();
            valMap2.put('true','する');
            valMap2.put('false','しない');
            flgMap.put('VoxerMDM__picking_flg__c',valMap2);
        }
        
        if(flgMap.containsKey(fieldName)){
            return flgMap.get(fieldName);
        }
        return null;
    }
    
    private void init(){
        getSetting(this.settingName);
        
        targetObjectInfo = (REC_SearchObject_Ctrl.TargetObjectInfo)System.Json.deserialize(this.setting, Type.forName('VoxerMDM', 'REC_SearchObject_Ctrl.TargetObjectInfo'));
        if(tmap == null || tmap.isEmpty()){
            tmap = new Map<String,TargetFieldInfo>();
            for(TargetFieldInfo info : targetObjectInfo.targetFieldInfoList){
                tmap.put(info.fieldName,info);
            }
        }
        createSOQLField();
        createPickListData();
//        createPaging();
        this.setting = JSON.serialize(targetObjectInfo);
        this.isNextPage = false;
        this.isPrevPage = false;
    }
    
    private String createOffset(){
        String offset = '';
        if(!String.isBlank(this.requestPage)){
            Integer limitc = 0;
            Integer pagen = 0;
            try{
                pagen = Integer.valueOf(this.requestPage);
            }catch(TypeException e){
                pagen = 1;
                pageList = '1';
            }
            if(!String.isBlank(targetObjectInfo.searchlimit) && String.isBlank(selectLimitCount)){
                limitc = Integer.valueOf(targetObjectInfo.searchlimit);
            }else if(!String.isBlank(selectLimitCount)){
                limitc = Integer.valueOf(selectLimitCount);
            }
            if(maxPageSize > 0 && maxPageSize < pagen){
                page_size = (limitc * maxPageSize) - limitc;
                pageList = '' + maxPageSize;
            }else{
                page_size = (limitc * pagen) - limitc;
            }
            if(page_size < 1){
                page_size = 0;
            }
            offset += ' offset ' + page_size + ' ';
        }
        return offset;
    }
    
    private void createPaging(){

        pageList = '1';
        
        // 全体の件数
        REC_SearchObject_Ctrl.InputValues inputValues = null;
        if(!String.isBlank(this.requestJson)){
            inputValues = (REC_SearchObject_Ctrl.InputValues)System.Json.deserialize(this.requestJson, Type.forName('VoxerMDM', 'REC_SearchObject_Ctrl.InputValues'));
        }
        String countSoql = 'select count(ID) total from '+this.settingName + createWHEREClause(inputValues);
        
        List<AggregateResult> productList2 = Database.query(countSoql);
        Integer allApplyProduct = Integer.valueOf(productList2.get(0).get('total'));

        Integer limitCount = 0;
        if(!String.isBlank(targetObjectInfo.searchlimit) && String.isBlank(selectLimitCount)){
            limitCount = Integer.valueOf(targetObjectInfo.searchlimit);
        }else if(!String.isBlank(selectLimitCount)){
            limitCount = Integer.valueOf(selectLimitCount);
        }
        Decimal totalPageSize = 0;
        if(allApplyProduct > 0 && limitCount > 0){
            totalPageSize = (Decimal)allApplyProduct / limitCount;
            totalPageSize = Math.ceil(totalPageSize);
        }

        Integer currentPage = 0;
        Integer i = 0;
        if((requestPage != null || requestPage != '') && Integer.valueOf(requestPage) > totalPageSize) requestPage = String.valueOf(totalPageSize);
        if(totalPageSize > 1){
            while(i < totalPageSize){
                i++;
                String num = '' + i;
                if(requestPage == num){
                    pageList = num;
                    currentPage = limitCount * i;
                }
            }
        }
        maxPageSize = i;
        if(currentPage == 0){
            currentPage = limitCount;
        }
        if(String.valueOf(maxPageSize) == pageList || maxPageSize == 0){
            this.count = ( currentPage - (limitCount - 1)) + '-' + allApplyProduct + ' / ' + allApplyProduct;
            this.pageinput = ' ページ<input type="text" name="pageinput" size="2" maxlength="4" value="' + pageList + '" onChange="setPage(this.value);return false;">/' + pageList;
        }else{
            this.count = ( currentPage - (limitCount - 1)) + '-' + currentPage + ' / ' + allApplyProduct;
            this.pageinput = ' ページ<input type="text" name="pageinput" size="2" maxlength="4" value="' + pageList + '" onChange="setPage(this.value);return false;">/' + maxPageSize;
        }
        setPrevNextPage();
    }
    
    private void setPrevNextPage(){
        Integer currentp = 0;
        if(!String.isBlank(pageList)){
            currentp = Integer.valueOf(pageList);
        }
        if(maxPageSize != null && maxPageSize == 1){
            this.isPrevPage = false;
            this.isNextPage = false;
        }else{
            if(currentp > 0 && currentp < maxPageSize){
                this.isNextPage = true;
                currentp++;

                //nextPageList = '<a href="javascript:setPage(\'' + currentp + '\');">次へ</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:setPage(\'' + maxPageSize + '\');">最後へ</a>';
                this.nextpg=currentp;
            }else{
                this.isNextPage = false;
            }
            if(pageList != null)currentp = Integer.valueOf(pageList);
            if(currentp > 0 && currentp > 1){
                this.isPrevPage = true;
                currentp--;
               // prevPageList = '<a href="javascript:setPage(\'1\');">最初へ</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:setPage(\'' + currentp + '\');">前へ</a>';
                this.prepg=currentp;
            }else{
                this.isPrevPage = false;
            }
        }
        
        
    }
    
    private void createPickListData(){
        createPickListData(this.settingName);       
    }
    
    private void createPickListData(String objectName){
        Schema.SObjectType sObjType = (Schema.SObjectType) Schema.getGlobalDescribe().get(objectName);
        if(sObjType != null){
            Map<String, Schema.SObjectField> fieldmap = sObjType.getDescribe().fields.getMap();
            for(TargetFieldInfo info : targetObjectInfo.targetFieldInfoList){
                if(info.type != null && (info.type.equalsIgnoreCase('PICKLIST') || info.type.equalsIgnoreCase('Multipicklist'))){
                   
                    Schema.SObjectField f = (Schema.SObjectField) fieldmap.get(info.fieldName);
                    
                    if(f != null) {
                        Schema.DescribeFieldResult r = f.getDescribe();                       
                        if (r.getType() == Schema.DisplayType.Picklist || r.getType() == Schema.DisplayType.Multipicklist) {
                            info.pickList = new Map<String,String>();
                            for(Schema.PicklistEntry entry : r.getPicklistValues()){
                                if(entry.isActive()){
                                    info.pickList.put(info.category + entry.getValue(),entry.getLabel());                                  
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    private void checkHiddenField(){
        System.debug('★requestSelectJson ' + requestSelectJson);
        if(!String.isBlank(requestSelectJson)){
            List<String> fieldList = requestSelectJson.split(',');
            if(fieldList != null && fieldList.size() > 0){
                this.hiddenFields = new set<String>();
                for(String key :fieldList){
                    this.hiddenFields.add(key);
                }
            }
        }else{
            this.hiddenFields = null;
        }
    }

    private void setHeader(String type){
        if(type != 'csv'){
            this.result = '<div class="constrainer"><div class="scrolltable"><table id="productList" class="header" ><thead><th style="width:40px" >No</th><th style="width:50px" >Action</th>';
        }else{
            this.result = '"No"';
        }
        Integer i = 0;
        System.debug('targetObjectInfo.targetFieldInfoList'+targetObjectInfo.targetFieldInfoList);
        if(!String.isBlank(requestfieldSort)){
            String fileds = requestfieldSort.replaceAll('filedsort_','');
            List<String> flist = fileds.split(',');
            for(String field : flist){
                if(this.hiddenFields != null && this.hiddenFields.size() > 0 && this.hiddenFields.contains(field)){
                    continue;
                }
                for(TargetFieldInfo info : targetObjectInfo.targetFieldInfoList){
                    if(info.fieldName != field || info.fieldName.equalsIgnoreCase('ID')){
                        continue;
                    }
                    
                    if(type == 'csv'){
                        this.result += ',';
                        this.result += '"' + info.label + '"';
                        i++;
                    }else{
                        if(info.fieldName=='VoxerMDM__WF_Comment__c') continue;
                        String headerLabel = info.label;
                        /*if(!String.isBlank(info.width)){
                            Integer len = Integer.valueOf(info.width);
                            if(info.label.length() < len){
                                headerLabel = apendBlankStr(info.label,len);
                            }else if(info.label.length() > len){
                                headerLabel = turndown(info.label,len);
                            }
                        }*/
                        this.result += '<th style="vertical-align: middle;width:'+info.width+ 'px" >' + info.label + '</th>';
                        
                    }
                    break;
                }
            }
        }
        if(type == 'csv'){
            this.result += '\n';
        }else{
            this.result += '</thead></table>';
        }
    }
    
    private String apendBlankStr(String str, Integer len){
        Integer c = len - str.length();
        String str2 = '';
        if(c > 1){
            Integer blankSize = c / 2;
            Integer counter = 0;
            String blankStr = '';
            while(counter < blankSize){
                blankStr += '&nbsp;';
                counter++;
            }
            str2 = blankStr + str + blankStr;
        }else{
            str2 = '&nbsp;' + str + '&nbsp;';
        }
        return str2;
    }
    
    private String turndown(String str, Integer len) {
        String result = str;
        String tmp = str;
        List<String> lines = new List<String>();
        if(str == null) return null;
        while (tmp.length() > len) {
            lines.add(tmp.substring(0,len));
            tmp = tmp.substring(len);
        }
        if (lines.size() > 0) {
            result = '';
            lines.add(tmp);
            for (String line : lines) {
                result = result + line + '<br />';
            }
            result = result.substring(0, result.length() - 1);
        }

        return result;
    }
    
    private void createSOQLField(){
        soqlField = '';     
        Integer i = 0;
        
        if(!String.isBlank(requestfieldSort)){
            String fileds = requestfieldSort.replaceAll('filedsort_','');
            List<String> flist = fileds.split(',');
            for(String field : flist){               
                if(this.hiddenFields != null && this.hiddenFields.size() > 0 && this.hiddenFields.contains(field)){
                    continue;
                }
                
                TargetFieldInfo info = tmap.get(field);
                 if(info.fieldName.equalsIgnoreCase('VoxerMDM__WF_Comment__c')){
                            continue;
                }
                if(info != null)soqlField += ',';
                if(info != null && info.fieldName == field){
                    if(info.type.equalsIgnoreCase('PICKLIST') || info.type.equalsIgnoreCase('Multipicklist') || info.fieldName =='RecordType.Name'){
                        soqlField += + 'toLabel(' + info.fieldName + ')';
                    }else{
                        soqlField += info.fieldName;
                    }
                }
                i++;
            }
        }
    }   
    private void csv(){
        System.debug('★ csv:');
        if(tmap == null || tmap.isEmpty()){
            tmap = new Map<String,TargetFieldInfo>();
            if(targetObjectInfo == null){
                getSetting(this.settingName);
                targetObjectInfo = (REC_SearchObject_Ctrl.TargetObjectInfo)System.Json.deserialize(this.setting, Type.forName('VoxerMDM', 'REC_SearchObject_Ctrl.TargetObjectInfo'));
            }
            for(TargetFieldInfo info : targetObjectInfo.targetFieldInfoList){
                tmap.put(info.fieldName,info);
            }
        }
        REC_SearchObject_Ctrl.InputValues inputValues = (REC_SearchObject_Ctrl.InputValues)System.Json.deserialize(this.requestJson, Type.forName('VoxerMDM', 'REC_SearchObject_Ctrl.InputValues'));
        REC_SearchObject_Ctrl.SortList inputSortList = (REC_SearchObject_Ctrl.SortList)System.Json.deserialize(this.requestSortJson, Type.forName('VoxerMDM', 'REC_SearchObject_Ctrl.SortList'));
        this.checkHiddenField();
        setHeader('csv');
        String soql = createBaseSOQL();
        soql += createWHEREClause(inputValues) + createOrderClause(inputSortList) + ' limit 1000';
        List<sobject> productList = Database.query(soql);
        List<String> lsAppIds=new List<String>();
        
        for(sobject rec : productList){
            if(rec.get('ApplicationId__c')==null) continue;
            lsAppIds.add(String.valueOf(rec.get('ApplicationId__c')));
        }
       
        Integer i = 1;
        for(sobject rec : productList){
            this.result += '"' + i + '"';
            
            if(!String.isBlank(requestfieldSort)){
                String fileds = requestfieldSort.replaceAll('filedsort_','');
                List<String> flist = fileds.split(',');
                for(String field : flist){
                    TargetFieldInfo info = tmap.get(field);
                    if(this.hiddenFields != null && this.hiddenFields.size() > 0 && this.hiddenFields.contains(info.fieldName)){
                        continue;
                    }
                    if(info.fieldName.equalsIgnoreCase('ID')){
                        continue;
                    }
                    this.result += ',';
                    if(info.fieldName.equalsIgnoreCase('NAME')){
                        this.result += '"' + rec.get(info.fieldName) + '"';
                    }else if(info.fieldName.indexOf('.') != -1){
                        List<String> keys = info.fieldName.split('\\.');
                        if(keys != null && keys.size() > 1){
                            sobject sobj = null;
                            Integer listCnt = keys.size();
                            object value = null;
                            String fname = '';//最下層のfieldname
                            for (Integer j = 0; j < listCnt ; j++) {
                                try{
                                    if((listCnt - 1 ) == j && sobj != null){
                                        value = sobj.get(keys.get(j));
                                        fname = keys.get(j);
                                    }else{
                                        if(sobj != null){
                                            sobj = sobj.getSobject(keys.get(j));
                                        }else{
                                            sobj = rec.getSobject(keys.get(j));
                                        }
                                    }
                                }catch(Exception e){}
                            }
                            if(sobj == null){
                                this.result += '""';
                                continue;
                            }
                            if(info.type.equalsIgnoreCase('DATE')){
                                Date d = (Date)value;
                                Datetime tmpDate = Datetime.newInstance(d.year(),d.month(), d.day());
                                this.result += '"' + tmpDate.addHours(9).format('yyyy/MM/dd') + '"';
                            }else if(info.type.equalsIgnoreCase('REFERENCE')){
                                String val = '';
                                if(String.valueOf(value) != null)val = String.valueOf(value);
                                this.result += '"' + val + '"';
                            }else if(info.type.equalsIgnoreCase('Boolean')){
                                String val = '';
                                if(value != null ){
                                    Map<String,String> m = replaceFlgVal(fname);
                                    val = String.valueOf(value);
                                    if(val.equals('true')){
                                        if(m != null){
                                            val = m.get('true');
                                        }else{
                                            val = 'あり';
                                        }
                                    }else{
                                        if(m != null){
                                            val = m.get('false');
                                        }else{
                                            val = 'なし';
                                        }
                                    }
                                    this.result += '"' + val + '"';
                                }else{
                                    this.result += '""';
                                }                               
                            }else{
                                String val = '';
                                if(String.valueOf(value) != null)val = String.valueOf(value);
                                this.result += '"' + val + '"';
                            }
                        }
                    }else{
                        if(info.type.equalsIgnoreCase('DATE')){
                            Date d = (Date)rec.get(info.fieldName);
                            Datetime tmpDate = Datetime.newInstance(d.year(),d.month(), d.day());
                            this.result += '"' + tmpDate.addHours(9).format('yyyy/MM/dd') + '"';
                        }else if(info.type.equalsIgnoreCase('Boolean')){
                            String val = '';
                            if(rec.get(info.fieldName) != null ){
                                val = String.valueOf(rec.get(info.fieldName));
                                Map<String,String> m = replaceFlgVal(info.fieldName);
                                if(val.equals('true')){
                                    if(m != null){
                                        val = m.get('true');
                                    }else{
                                        val = 'あり';
                                    }
                                }else{
                                    if(m != null){
                                        val = m.get('false');
                                    }else{
                                        val = 'なし';
                                    }
                                }
                                this.result += '"' + val + '"';
                            }else{
                                this.result += '""';
                            }                               
                        }
                    }
                }
            }
            this.result += '\n';
            i++;
        }
    }
    
    private String createWHEREClause(REC_SearchObject_Ctrl.InputValues inputValues){     
        String whereClause = '';
        System.debug('inputValues'+inputValues);              
        if(inputValues != null){              
            for(InputValue input : inputValues.InputValueList){    
                 
                if(!String.isBlank(input.value) && (input.type.equalsIgnoreCase('String') || input.type.equalsIgnoreCase('REFERENCE') || input.type.equalsIgnoreCase('TEXTAREA'))){
                    if(input.fieldName=='RecordType.Name' && getRecordTypleTWKBench(input.value)!=''){
                        whereClause += ' And ' + getRecordTypleTWKBench(input.value);
                    } 
                    else{
                        whereClause += ' And ' + input.fieldName + ' like \'%' + input.value + '%\'';    
                    }
                    
                }else if(!String.isBlank(input.value) && input.type.equalsIgnoreCase('boolean')){
                    whereClause += ' And ' + input.fieldName + ' = ' + boolean.valueOf(input.value);
                }else if(!String.isBlank(input.value) && input.type.equalsIgnoreCase('Multipicklist')){    
                     if(input.value.indexOf(';')==0) input.value=input.value.substring(1);
                     if(input.fieldName=='RecordType.Name'){
                        whereClause += ' And RecordType.DeveloperName ' + ' in(\'' + input.value.replaceAll(';','\',\'') +'\')';
                    }                    
                    else{                    
                        whereClause += ' And ' + input.fieldName + ' includes(: ' + input.value +')';
                    }    
                }else if(!String.isBlank(input.value) && input.type.equalsIgnoreCase('DATE')){
                    date d = date.parse(input.value);
                    whereClause += ' And ' + input.fieldName + ' = ' + String.valueOf(d);
                }else if(!String.isBlank(input.value) && !input.type.equalsIgnoreCase('DATE') && !input.type.equalsIgnoreCase('boolean')){                                   
                    whereClause += ' And ' + input.fieldName + ' = \'' + input.value + '\'';
                }
            }            
        }
        System.debug('whereClause'+whereClause+whereClause.length());
        if(whereClause.length()>0) whereClause=' where '+whereClause;
        return whereClause.replace('where  And','where');
    }
    
    private String createBaseSOQL(){
        this.createSOQLField();
        String soql = 'select id ';
        soql += String.escapeSingleQuotes(this.soqlField) +' from '+ this.settingName;
        return soql;
    }
    
    private String createOrderClause(REC_SearchObject_Ctrl.SortList sortList){
        String orderClause = '';
        set<String> fieldName = new set<String>();
        for(InputSort input : sortList.InputSortList){
            if(!String.isBlank(input.fieldName) && !fieldName.contains(input.fieldName)){
                if(String.isBlank(orderClause)){
                    orderClause += ' order by ' + input.fieldName + ' ' + input.sortType + ' NULLS LAST ';
                }else{
                    orderClause += ' ,' + input.fieldName + ' ' + input.sortType + ' NULLS LAST ';
                }
                fieldName.add(input.fieldName);
            }
        }
        return orderClause;
    }
    
    private void getSetting(String settingFields){
        List<REC_ObjectSearchSetting__c> settings = [select Setting__c,Title__c,Name from REC_ObjectSearchSetting__c where Name =:settingFields];
        if(settings != null && settings.size() > 0){
            for(REC_ObjectSearchSetting__c s :settings){
                if(settingFields == s.Name){
                    this.setting = s.Setting__c.trim().replaceAll('\r\n','');
                    this.title = s.Title__c;
                }
            }
        }
    }
    
    public class InputValues {
        public List<InputValue> InputValueList;
    }
    public class InputValue {
        public String fieldName;
        public String value;
        public String type;
    }
    public class SortList {
        public List<InputSort> InputSortList;
    }
    public class InputSort {
        public String priority;
        public String fieldName;
        public String sortType;
    }   
    public class TargetObjectInfo {
        public List<SortCondition> sortList;
        public List<SortSearchCondition> conditionSortList;
        public String searchlimit;
        public List<TargetFieldInfo> targetFieldInfoList;
    }
    public class SortCondition{
        public String priority;//順番
        public String target;
        public String type;
    }
    public class SortSearchCondition{
        public String priority;//順番
        public String fieldname;        
    }
    public class TargetFieldInfo {
        public String fieldName;
        public String label;
        public String type;//データ型
        public String link;//選択リストの制御項目
        public String level;//選択リストの連動関係の階層
        public String category;//選択リストの連動関係の種類
        public Map<String,String> pickList;
        public String searchCriteria;//検索条件とソート条件に表示するかの判定用
        public String width;//ヘッダーの幅 文字数で指定
    }
    
}