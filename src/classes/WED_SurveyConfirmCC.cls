global with sharing class WED_SurveyConfirmCC {
    public static String  surveyToken {get;set;}
    public static String  seqAnswer {get;set;}
    public static String  host {get;set;}
    public static Boolean authorized {get;set;}
    public static String  header {get;set;}
    public static Boolean isLock {get;set;}
    public static Boolean isValidToken {get;set;}

	public WED_SurveyConfirmCC(){
        // Get token from URL
        surveyToken = ApexPages.currentPage().getParameters().get('workSheetToken');

        // Check the URL accessed
        String baseURL = Site.getBaseUrl();
        if(Test.isRunningTest()){
            baseURL = 'test/contact/WED_SurveyWeddingPage';
        }

       if(baseUrl.contains(Label.WED_Site_Customer)){
            authorized = false;
        } else if(baseUrl.contains(Label.WED_Site_Staff)){
            authorized = true;
        } else {
            authorized = false;
        }

        isLock = false;

        // Get Lead with the parameter token
        List<Lead> leadWithToken = [SELECT Id, Name, Watabe_SentakuriyuuWatabe_SonotaSyousai__c, Goryousin_Soudan__c, Eturan_Zassi__c,RaitenSankou_most__c, RaitenSankou__c,
                                                Eturan_Netto__c, Eturan_Sonota__c, Kekkon_Kentoujyoukyou__c, Gosoudan_Jyoukyou__c,kikkake_sonota__c,kikkake_word__c,Guesusonota_shinrou__c,Guesusonota_shinpu__c,
                                                Raiten_Riyuu__c, Rizokon_Kentouriyuu__c, Kekkonsiki_Youbou__c, Kaijyou_Kodawari__c,JimotoWedding__c,Kyosiki_Kentoueria_CS_daiiti__c,
                                                Sinrou_Tokoureki__c, Sinrou_Tokoukaisuu__c,Sinrou_Tokousonota__c, Sinpu_Tokoureki__c, Sinpu_Tokoukaisuu__c,kiboujikiCS_oomaka__c, kiboujikiCS_miketsu__c,
                                                Sinpu_Tokousonota__c, KibouSutairu__c, kiboujikiCS__c, kiboujikiCS_shousai__c, OhigaraKibou__c, Kiboujiki_Riyuu__c,
                                                Gesuto_Sinrou__c, Guesukazoku_shinrou__c, Guesushinzoku_shinrou__c, Guesuyuujin_shinrou__c,Kaijoukibou_CS__c,
                                                Guesukaisha_shinrou__c, Gesuto_Sinpu__c, Guesukazoku_shinpu__c, Guesushinzoku_shinpu__c,kikkake__c,
                                                Guesuyuujin_shinpu__c, Guesukaisha_shinpu__c, Kekkonnsiki_Yosan__c, Kekkonsiki_Kentou_Sonota__c,
                                                Kokunaisikijyou__c, Rizokon_SonotaSyousai__c, Kekkonsiki_Youbou_Sonota__c, Kyosiki_Kentoueria_CS_Syousai__c,
                                                Kyosikikentoueria_Sonota__c, Kaijyou_Sonota__c, Kiboujiki_Sonota__c, KibouChaperu__c, Tasya_Kentou__c, 
                                                WED_IsLock__c
                                           FROM Lead
                                          WHERE workSheetToken__c=: surveyToken
                                          LIMIT 1];

        if(leadWithToken.isEmpty() || String.isEmpty(surveyToken)) {
            isValidToken = false;
        } else {
            isValidToken = true;
            isLock = leadWithToken.get(0).WED_IsLock__c;

            // Setting answer
            seqAnswer = settingJsonSurveyAnswer(leadWithToken.get(0));

            // Check to showing header
            /*if(!authorized) {
                header = Label.WED_Label_Survey;
            } else {
                String format = Label.WED_Label_SurveyHeader;
                header = WED_CommonUtil.formatHeader(format, leadWithToken[0].Name);
            }*/
            header = Label.WED_Label_Survey;
            // Get apex host page to loading image.
            host = Site.getBaseUrl();

            // Always modify if you access as a staff
            if(authorized){
                isLock = false;
            }
        }
    }

    // Redirect error page if token is invalid
    public PageReference doRoutine(){
        String url = '{0}/WED_ErrorTokenPage';
        String directory = Site.getBaseUrl();

        List<String> arguments = new List<String>();
        arguments.add(directory);
        
        String mainUrl = String.format(url, arguments);
        
        PageReference pageRef = new PageReference(mainUrl);
        pageRef.setRedirect(true);

        // If the token is invalid 
        if(!isValidToken){
            return pageRef;

        // If survey is lock    
        } else if(!authorized && isLock) {
            return redirectLock();
        }

        return null;
    }

    /*
        Created by: Tuan
        Created date: 17-11-2017
        Description: Redirect to lock Page
    */
    public static PageReference redirectLock(){
        PageReference redirectPage = new PageReference(Label.WED_Site_Customer + '/WED_SurveyLockPage');
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    /* 
    Created Date: 14/11/17
    Create By: Minh Tuan
    Description: Get List default Image
    */
    @RemoteAction
    global static Map<String,String> getListImage(String pageHost){
        try{
            Map<String,String> result = new Map<String,String>();
            // Folder name
            String folderName = Label.WED_Label_FolderName;
            List<Document> currentPictures = [SELECT Id,URL,Name FROM Document WHERE Folder.Name =: folderName Limit 2000];
            for(Document document: currentPictures){
                
                // Org Id
                Id strOrgId = UserInfo.getOrganizationId();

                List<String> arguments = new List<String>();
                arguments.clear();
                arguments.add(pageHost);
                arguments.add(document.Id);
                arguments.add(strOrgId);

                String strDocUrl = String.format(WED_Constants.URL_IMAGESERVER, arguments);
                result.put(document.Name, strDocUrl);
            }
            return result;
        }catch(Exception ex){
            return null;
        }
    }

    // Redirecting to the confirm page.
    @RemoteAction
    global static PageReference redirectLastSurvey(String token) {
        String url = '';
        String baseURL = Site.getBaseUrl();

        // Test class
        if(Test.isRunningTest()){
            baseURL = 'test/contact/WED_SurveyWeddingPage';
        }

        if(baseURL.contains(Label.WED_Site_Customer)){
            url = baseURL;
        }else{
            url = baseURL + '/WED_SurveyWeddingPage';
        }

        PageReference redirectPage = new PageReference(url);
        redirectPage.getParameters().put('workSheetToken',token);
        redirectPage.getParameters().put('confirm_back','confirm');

        return redirectPage;
    }

    // Redirecting to the final page.
    @RemoteAction
    global static PageReference redirectFinish(String token){
        String baseURL = Site.getBaseUrl();
        String mainUrl =  baseURL + '/WED_SurveyCompletePage';

        // Test class
        if(Test.isRunningTest()){
            baseURL = 'test/contact';
        }

        if(baseURL.contains(Label.WED_Site_Staff)){
            WED_JsonResult result = WED_SurveyConfirmCC.lockSurvey(token);
        }

        PageReference redirectPage = new PageReference(mainUrl);
        redirectPage.getParameters().put('workSheetToken',token);
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    // Processing lock survey 
    public static WED_JsonResult lockSurvey(String token){
        try {

            List<Lead> surveyLead =  [SELECT Id, workSheetToken__c
                                        FROM  Lead
                                       WHERE workSheetToken__c =: token
                                      LIMIT 1];

            // If survey exist
            if(!surveyLead.isEmpty()){
                Lead leadTarget = surveyLead.get(0);
                leadTarget.WED_IsLock__c = true;

                update leadTarget;
                return new WED_JsonResult(true,null,Label.WED_Label_Lock);
            } else {
                return new WED_JsonResult(false,null,Label.WED_Error_SurveyNotFound);
            }
        } catch (Exception ex) {
            return new WED_JsonResult(false,null, ex.getMessage());
        }
    }

    /* 
    Created Date: 04/12/17
    Create By: Minh Tuan
    Description: Get all Picklist fields
    */
    private static SurveyObject getPickListOptions(String objectName){
        SurveyObject surveyObject = new SurveyObject();

        // add key to picklist value
        // Setting for item mutiple-select
        surveyObject.ans1 = WED_CommonUtil.getPicklistField(objectName,'Raiten_Riyuu__c', WED_CommonUtil.KeyType.ITEM);
        surveyObject.ans2 = WED_CommonUtil.getPicklistField(objectName,'Rizokon_Kentouriyuu__c', WED_CommonUtil.KeyType.ITEM);
        surveyObject.ans3 = WED_CommonUtil.getPicklistField(objectName,'Kekkonsiki_Youbou__c', WED_CommonUtil.KeyType.ITEM);
        surveyObject.ans4 = WED_CommonUtil.getPicklistField(objectName,'Kyosiki_Kentoueria_CS_Syousai__c', WED_CommonUtil.KeyType.ITEM);
        surveyObject.ans5 = WED_CommonUtil.getPicklistField(objectName,'Kaijyou_Kodawari__c', WED_CommonUtil.KeyType.ITEM);

        surveyObject.ans7 = WED_CommonUtil.getPicklistField(objectName,'Sinrou_Tokoureki__c', WED_CommonUtil.KeyType.PARENT);
        surveyObject.ans7Sub1 = WED_CommonUtil.getPicklistField(objectName,'Sinrou_Tokoukaisuu__c', WED_CommonUtil.KeyType.CHILD);
        surveyObject.ans7Sub2 = WED_CommonUtil.getPicklistField(objectName,'Sinrou_Tokousonota__c', WED_CommonUtil.KeyType.CHILD);
        surveyObject.ans8 = WED_CommonUtil.getPicklistField(objectName,'Sinpu_Tokoureki__c', WED_CommonUtil.KeyType.PARENT);
        surveyObject.ans8Sub1 = WED_CommonUtil.getPicklistField(objectName,'Sinpu_Tokoukaisuu__c', WED_CommonUtil.KeyType.CHILD);
        surveyObject.ans8Sub2 = WED_CommonUtil.getPicklistField(objectName,'Sinpu_Tokousonota__c', WED_CommonUtil.KeyType.CHILD);

        surveyObject.ans10 = WED_CommonUtil.getPicklistField(objectName,'kiboujikiCS__c', WED_CommonUtil.KeyType.VALUE);

        surveyObject.ans12 = WED_CommonUtil.getPicklistField(objectName,'Kiboujiki_Riyuu__c', WED_CommonUtil.KeyType.VALUE);
        surveyObject.ans13 = WED_CommonUtil.getPicklistField(objectName,'Gesuto_Sinrou__c', WED_CommonUtil.KeyType.PARENT);
        surveyObject.ans14 = WED_CommonUtil.getPicklistField(objectName,'Gesuto_Sinpu__c', WED_CommonUtil.KeyType.PARENT);
        surveyObject.ans15 = WED_CommonUtil.getPicklistField(objectName,'Kekkonnsiki_Yosan__c', WED_CommonUtil.KeyType.VALUE);
        //surveyObject.ans16 = WED_CommonUtil.getPicklistField(objectName,'Kekkon_Kentoujyoukyou__c', WED_CommonUtil.KeyType.VALUE);
        surveyObject.ans17 = WED_CommonUtil.getPicklistField(objectName,'Gosoudan_Jyoukyou__c', WED_CommonUtil.KeyType.VALUE);
        surveyObject.ans18 = WED_CommonUtil.getPicklistField(objectName,'Tasya_Kentou__c', WED_CommonUtil.KeyType.ITEM);
        surveyObject.ans19 = WED_CommonUtil.getPicklistField(objectName,'Goryousin_Soudan__c', WED_CommonUtil.KeyType.VALUE);
        surveyObject.ans19 = WED_CommonUtil.getPicklistField(objectName,'Goryousin_Soudan__c', WED_CommonUtil.KeyType.VALUE);
        //surveyObject.ans20 = WED_CommonUtil.getPicklistFieldForHybridType(objectName,'Eturan_Zassi__c', WED_CommonUtil.KeyType.HYBRID);
        surveyObject.ans20 = WED_CommonUtil.getPicklistField(objectName,'kikkake__c', WED_CommonUtil.KeyType.ITEM);
        surveyObject.ans21 = WED_CommonUtil.getPicklistField(objectName,'RaitenSankou__c', WED_CommonUtil.KeyType.ITEM);
        /*surveyObject.ans21 = WED_CommonUtil.getPicklistField(objectName,'Eturan_Netto__c', WED_CommonUtil.KeyType.ITEM);
        surveyObject.ans22 = WED_CommonUtil.getPicklistField(objectName,'Eturan_Sonota__c', WED_CommonUtil.KeyType.ITEM);*/
        
        return surveyObject;
    }

    // get data for showing to screen
    @TestVisible
    private static String settingJsonSurveyAnswer(Lead lead){
        SurveyObject surveyObject = new SurveyObject();
        SurveyObject pickListObject = getPickListOptions('Lead');

        // Setting for item mutiple-select
        surveyObject.ans1 = WED_CommonUtil.settingPicklistToMap(lead.Raiten_Riyuu__c);
        surveyObject.ans2 = WED_CommonUtil.settingPicklistToMap(lead.Rizokon_Kentouriyuu__c);
        surveyObject.ans3 = WED_CommonUtil.settingPicklistToMap(lead.Kekkonsiki_Youbou__c);
        surveyObject.ans4N = lead.JimotoWedding__c;
        surveyObject.ans4Best = lead.Kyosiki_Kentoueria_CS_daiiti__c;
        surveyObject.ans4 = WED_CommonUtil.settingPicklistToMap(lead.Kyosiki_Kentoueria_CS_Syousai__c);
        surveyObject.ans5 = WED_CommonUtil.settingPicklistToMap(lead.Kaijyou_Kodawari__c);
        surveyObject.ans6 = lead.Kaijoukibou_CS__c;
        surveyObject.ans7 = WED_CommonUtil.settingPicklistToMap(lead.Sinrou_Tokoureki__c);
        surveyObject.ans7Sub1 = WED_CommonUtil.settingPicklistToMap(lead.Sinrou_Tokoukaisuu__c);
        surveyObject.ans7Sub2 = WED_CommonUtil.settingPicklistToMap(lead.Sinrou_Tokousonota__c);
        surveyObject.ans8 = WED_CommonUtil.settingPicklistToMap(lead.Sinpu_Tokoureki__c);
        surveyObject.ans8Sub1 = WED_CommonUtil.settingPicklistToMap(lead.Sinpu_Tokoukaisuu__c);
        surveyObject.ans8Sub2 = WED_CommonUtil.settingPicklistToMap(lead.Sinpu_Tokousonota__c);
        surveyObject.ans9 = lead.KibouSutairu__c;
        surveyObject.ans10 = WED_CommonUtil.settingPicklistToMap(lead.kiboujikiCS__c);
        surveyObject.ans10Date = lead.kiboujikiCS_shousai__c != null ? settingDate(lead.kiboujikiCS_shousai__c, lead.kiboujikiCS__c) : '';
        surveyObject.ans10ChangeYM = String.isEmpty(lead.kiboujikiCS_oomaka__c) ? '' : settingDateAwait(lead.kiboujikiCS_oomaka__c);
        surveyObject.ans10PendYM = String.isEmpty(lead.kiboujikiCS_miketsu__c) ? '' : settingDateAwait(lead.kiboujikiCS_miketsu__c);
        surveyObject.ans11 = lead.OhigaraKibou__c;
        surveyObject.ans12 = WED_CommonUtil.settingPicklistToMap(lead.Kiboujiki_Riyuu__c);
        surveyObject.ans13 = WED_CommonUtil.settingPicklistToMap(lead.Gesuto_Sinrou__c);
        surveyObject.ans14 = WED_CommonUtil.settingPicklistToMap(lead.Gesuto_Sinpu__c);
        surveyObject.ans15 = WED_CommonUtil.settingPicklistToMap(lead.Kekkonnsiki_Yosan__c);
        //surveyObject.ans16 = WED_CommonUtil.settingPicklistToMap(lead.Kekkon_Kentoujyoukyou__c);
        surveyObject.ans17 = WED_CommonUtil.settingPicklistToMap(lead.Gosoudan_Jyoukyou__c);
        surveyObject.ans18 = WED_CommonUtil.settingPicklistToMap(lead.Tasya_Kentou__c);
        surveyObject.ans19 = WED_CommonUtil.settingPicklistToMap(lead.Goryousin_Soudan__c);
        //surveyObject.ans20 = WED_CommonUtil.settingPicklistToMap(lead.Eturan_Zassi__c);
        surveyObject.ans20 = WED_CommonUtil.settingPicklistToMap(lead.kikkake__c);
        surveyObject.ans21 = WED_CommonUtil.settingPicklistToMap(lead.RaitenSankou__c);
        surveyObject.ans21Best = lead.RaitenSankou_most__c;
        /*surveyObject.ans21 = WED_CommonUtil.settingPicklistToMap(lead.Eturan_Netto__c);
        surveyObject.ans22 = WED_CommonUtil.settingPicklistToMap(lead.Eturan_Sonota__c);*/

        // Data text of Survey
        surveyObject.ans1Text = lead.Watabe_SentakuriyuuWatabe_SonotaSyousai__c;
        surveyObject.ans2Text = lead.Rizokon_SonotaSyousai__c;
        surveyObject.ans3Text = lead.Kekkonsiki_Youbou_Sonota__c;
        surveyObject.ans4Text = lead.Kyosikikentoueria_Sonota__c;
        surveyObject.ans5Text = lead.Kaijyou_Sonota__c;
        surveyObject.ans6Text = lead.KibouChaperu__c;
        surveyObject.ans12Text = lead.Kiboujiki_Sonota__c;
        //surveyObject.ans16Text = lead.Kekkonsiki_Kentou_Sonota__c;
        surveyObject.ans18Text = lead.Kokunaisikijyou__c;
        surveyObject.ans20Text1 = lead.kikkake_word__c;
        surveyObject.ans20Text2 = lead.kikkake_sonota__c;

        //Data Input of Question 13
        surveyObject.ans13Numb1 = lead.Guesukazoku_shinrou__c;
        //surveyObject.ans13Numb2 = lead.Guesushinzoku_shinrou__c;
        surveyObject.ans13Numb3 = lead.Guesuyuujin_shinrou__c;
        //surveyObject.ans13Numb4 = lead.Guesukaisha_shinrou__c;
        surveyObject.ans13Numb5 = lead.Guesusonota_shinrou__c;

        //Data Input of Question 14
        surveyObject.ans14Numb1 = lead.Guesukazoku_shinpu__c;
        //surveyObject.ans14Numb2 = lead.Guesushinzoku_shinpu__c;
        surveyObject.ans14Numb3 = lead.Guesuyuujin_shinpu__c;
        //surveyObject.ans14Numb4 = lead.Guesukaisha_shinpu__c;
        surveyObject.ans14Numb5 = lead.Guesusonota_shinpu__c;
        
        // Add key to map
        surveyObject.ans1 = WED_CommonUtil.formatPicklistMap(pickListObject.ans1, surveyObject.ans1);
        surveyObject.ans2 = WED_CommonUtil.formatPicklistMap(pickListObject.ans2, surveyObject.ans2);
        surveyObject.ans3 = WED_CommonUtil.formatPicklistMap(pickListObject.ans3, surveyObject.ans3);
        surveyObject.ans4 = WED_CommonUtil.formatPicklistMap(pickListObject.ans4, surveyObject.ans4);
        surveyObject.ans5 = WED_CommonUtil.formatPicklistMap(pickListObject.ans5, surveyObject.ans5);

        surveyObject.ans7 = WED_CommonUtil.formatPicklistMap(pickListObject.ans7, surveyObject.ans7);
        surveyObject.ans7Sub1 = WED_CommonUtil.formatPicklistMap(pickListObject.ans7Sub1, surveyObject.ans7Sub1);
        surveyObject.ans7Sub2 = WED_CommonUtil.formatPicklistMap(pickListObject.ans7Sub2, surveyObject.ans7Sub2);
        surveyObject.ans8 = WED_CommonUtil.formatPicklistMap(pickListObject.ans8, surveyObject.ans8);
        surveyObject.ans8Sub1 = WED_CommonUtil.formatPicklistMap(pickListObject.ans8Sub1, surveyObject.ans8Sub1);
        surveyObject.ans8Sub2 = WED_CommonUtil.formatPicklistMap(pickListObject.ans8Sub2, surveyObject.ans8Sub2);

        surveyObject.ans10 = WED_CommonUtil.formatPicklistMap(pickListObject.ans10, surveyObject.ans10);

        surveyObject.ans12 = WED_CommonUtil.formatPicklistMap(pickListObject.ans12, surveyObject.ans12);
        surveyObject.ans13 = WED_CommonUtil.formatPicklistMap(pickListObject.ans13, surveyObject.ans13);
        surveyObject.ans14 = WED_CommonUtil.formatPicklistMap(pickListObject.ans14, surveyObject.ans14);
        surveyObject.ans15 = WED_CommonUtil.formatPicklistMap(pickListObject.ans15, surveyObject.ans15);
        //surveyObject.ans16 = WED_CommonUtil.formatPicklistMap(pickListObject.ans16, surveyObject.ans16);
        surveyObject.ans17 = WED_CommonUtil.formatPicklistMap(pickListObject.ans17, surveyObject.ans17);
        surveyObject.ans18 = WED_CommonUtil.formatPicklistMap(pickListObject.ans18, surveyObject.ans18);
        surveyObject.ans19 = WED_CommonUtil.formatPicklistMap(pickListObject.ans19, surveyObject.ans19);
        surveyObject.ans20 = WED_CommonUtil.formatPicklistMap(pickListObject.ans20, surveyObject.ans20);
        surveyObject.ans21 = WED_CommonUtil.formatPicklistMap(pickListObject.ans21, surveyObject.ans21);
        /*surveyObject.ans21 = WED_CommonUtil.formatPicklistMap(pickListObject.ans21, surveyObject.ans21);
        surveyObject.ans22 = WED_CommonUtil.formatPicklistMap(pickListObject.ans22, surveyObject.ans22);*/

        return JSON.serialize(surveyObject);
    }

    // Setting Date to show in screen
    @TestVisible
    private static String settingDate(Date dtModify, String data) {
        //String valChoosed = data.get('value');
        if (String.isEmpty(data)){
            return '';
        }
        String strDate = dtModify.year() + '年' + dtModify.month() + '月' + dtModify.day() + '日';
        if(data.contains('日程を決めている')){
            return strDate;
        } else if(data.contains('大まかな時期を決めている')){
            return strDate + 'ごろ';
        } else if(data.contains('特に時期は決めていない')){
            return strDate + 'ごろまでには';
        }

        return strDate;
    }
    
    // Setting Date to show in screen
    private static String settingDateAwait(String dtMY) {

        String dtPresent = '';
        if(dtMY.contains('/')){
            dtPresent = dtMY.split('/')[0] + '年' + dtMY.split('/')[1] + '月';
        } else {
            dtPresent = dtMY.split('/')[0] + '年';            
        }

        return dtPresent;
    }

    // SurveyObject defination
    public class SurveyObject{
        public Map<String, String> ans1;
        public Map<String, String> ans2;
        public Map<String, String> ans3;
        public Map<String, String> ans4;
        public String ans4Best;
        public String ans4N;
        public Map<String, String> ans5;
        public String ans6;
        public Map<String, String> ans7;
        public Map<String, String> ans8;
        public String ans9;
        public Map<String, String> ans10;
        public String ans11;
        public Map<String, String> ans12;
        public Map<String, String> ans13;
        public Map<String, String> ans14;
        public Map<String, String> ans15;
        //public Map<String, String> ans16;
        public Map<String, String> ans17;
        public Map<String, String> ans18;
        public Map<String, String> ans19;
        public Map<String, String> ans20;
        public Map<String, String> ans21;
        public String ans21Best;
        //public Map<String, String> ans22;
        public String ans1Text;
        public String ans2Text;
        public String ans3Text;
        public String ans4Text;
        public String ans5Text;
        public String ans6Text;
        public String ans12Text;
        //public String ans16Text;
        public String ans18Text;

        public String ans20Text1;
        public String ans20Text2;
        public Decimal ans13Numb1;
        public Decimal ans13Numb2;
        public Decimal ans13Numb3;
        public Decimal ans13Numb4;
        public Decimal ans13Numb5;
        public Decimal ans14Numb1;
        public Decimal ans14Numb2;
        public Decimal ans14Numb3;
        public Decimal ans14Numb4;
        public Decimal ans14Numb5;
        public Map<String, String> ans7Sub1;
        public Map<String, String> ans7Sub2;
        public Map<String, String> ans8Sub1;
        public Map<String, String> ans8Sub2;
        public String ans10Date;
        public String ans10ChangeYM;
        public String ans10PendYM;
    }
}