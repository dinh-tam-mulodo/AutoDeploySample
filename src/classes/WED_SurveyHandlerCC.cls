global with sharing class WED_SurveyHandlerCC {
    public static Boolean isLock {get;set;}
    public static String  surveyToken {get;set;}
    public static String  seqAnswer {get;set;}
    public static String  confirm {get;set;}
    public static String  host {get;set;}
    public static Boolean authorized {get;set;}
    public static Boolean isValidToken {get;set;}
    public static String  header {get;set;}
    public static SurveyObject pickListObject {get;set;}

    
    public WED_SurveyHandlerCC(){
        // Get parameter from URL
        surveyToken = ApexPages.currentPage().getParameters().get('workSheetToken');
        confirm = ApexPages.currentPage().getParameters().get('confirm_back');
        
        pickListObject = getPickListOptions('Lead');
        
        // Check URL with user or staff(contact)
        String baseUrl =  Site.getBaseUrl();
        if(Test.isRunningTest()){
            baseUrl = 'https://c.testing.visual.force.com' + WED_SurveyHandlerCCTest.strRole;
        }
        if(baseUrl.contains(Label.WED_Site_Customer)) {
            authorized = false;
        } else if(baseUrl.contains(Label.WED_Site_Staff)) {
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
        

        // Check the token is suplied
        if(leadWithToken.isEmpty() || String.isEmpty(surveyToken)) {
            isValidToken = false;
        } else {
            isValidToken = true;
            isLock = leadWithToken[0].WED_IsLock__c;

            // Setting data JSON for show data to screen
            seqAnswer = settingJsonSurveyAnswer(leadWithToken.get(0));
            System.debug('seqAnswer: ' + seqAnswer);
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
        List<String> arguments = new List<String>();
        String directory = Site.getBaseUrl();

        arguments.add(directory);
        String mainUrl = String.format(url, arguments);
        
        PageReference pageRef = new PageReference(mainUrl);
        pageRef.setRedirect(true);

        // If the token is invalid or value of parameter "authorized" <> true
        if(!isValidToken){
            return pageRef;
        } else if(!authorized && isLock) {
            return redirectLock();
        }

        return null;
    }

    // Redirecting to the confirm page.
    @RemoteAction
    global static PageReference redirectConfirm(String strJson, String token, String isStaff) {
        // Saving data
        List<String> arguments = new List<String>();
        
        String url = '{0}/WED_SurveyConfirmPage';
        String directory = Site.getBaseUrl();
        arguments.add(directory);

        String mainUrl = String.format(url, arguments);
        WED_JsonResult result = WED_SurveyHandlerCC.saveData(strJson, token, isStaff);

        PageReference redirectPage = new PageReference(mainUrl);
        redirectPage.getParameters().put('workSheetToken',token);
        
        return redirectPage;
    }

    /*
        Created by: Tuan
        Created date: 15-11-2017
        Description: Redirect to lock Page
    */

    public static PageReference redirectLock(){
        PageReference redirectPage = new PageReference(Label.WED_Site_Customer + '/WED_SurveyLockPage');
        redirectPage.setRedirect(true);
        return redirectPage;
    }

    // Get list image in document
    @RemoteAction
    global static Map<String,String> getListImage(String host){
        try{
            Map<String,String> result = new Map<String,String>();
            String strFolderName = Label.WED_Label_FolderName;
            
            List<Document> currentPictures = [SELECT Id,URL,Name FROM Document 
                                              WHERE Folder.Name =: strFolderName
                                              LIMIT 100];
            
            List<String> arguments = new List<String>();
            // Loop for each documentation
            for(Document document: currentPictures){
                Id strOrgId = UserInfo.getOrganizationId();
                arguments.clear();
                arguments.add(host);
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
    
    //Saving data to Database
    @RemoteAction
    global static  WED_JsonResult saveData(String strJson, String token, String strAuth){
        SurveyObject survey = (SurveyObject)JSON.deserialize(strJson, SurveyObject.class);

        // Setting answer1:
        String strAns1Pick = WED_CommonUtil.settingMapTopickList(survey.ans1);
        String strAns1Text = survey.ans1Text;

        // Setting answer2:
        String strAns2Pick = WED_CommonUtil.settingMapTopickList(survey.ans2);
        String strAns2Text = survey.ans2Text;

        // Setting answer3:
        String strAns3Pick = WED_CommonUtil.settingMapTopickList(survey.ans3);
        String strAns3Text = survey.ans3Text;

        // Setting answer4:
        String strAns4Pick = WED_CommonUtil.settingMapTopickList(survey.ans4);
        String strAns4Text = survey.ans4Text;

        // Setting answer4N
        String strAns4N = survey.ans4N;
        String strAns4Best = survey.ans4Best;
        
        // Setting answer5:
        String strAns5Pick = WED_CommonUtil.settingMapTopickList(survey.ans5);
        String strAns5Text = survey.ans5Text;

        // Setting answer6:
        String strAns6 = survey.ans6;
        String strAns6Text = survey.ans6Text;

        // Setting answer7:
        String strAns7Pick = WED_CommonUtil.settingMapTopickList(survey.ans7);
        String strAns7Sub1Pick = WED_CommonUtil.settingMapTopickList(survey.ans7Sub1);
        String strAns7Sub2Pick = WED_CommonUtil.settingMapTopickList(survey.ans7Sub2);

        // Setting answer8:
        String strAns8Pick = WED_CommonUtil.settingMapTopickList(survey.ans8);
        String strAns8Sub1Pick = WED_CommonUtil.settingMapTopickList(survey.ans8Sub1);
        String strAns8Sub2Pick = WED_CommonUtil.settingMapTopickList(survey.ans8Sub2);

        // Setting answer9:
        String strAns9 = survey.ans9;

        // Setting answer10:
        String strAns10Pick = WED_CommonUtil.settingMapTopickList(survey.ans10);
        Date ans10Date;
        if(!String.isEmpty(survey.ans10Date)) {
            ans10Date = Date.parse(survey.ans10Date);
        }
		
        String strAns10ChangeYM = survey.ans10ChangeYM;
        String strAns10PendYM = survey.ans10PendYM;

        // Setting answer11:
        String strAns11 = survey.ans11;

        // Setting answer12:
        String strAns12Pick = WED_CommonUtil.settingMapTopickList(survey.ans12);
        String strAns12Text = survey.ans12Text;

        // Setting answer13:
        String strAns13Pick = WED_CommonUtil.settingMapTopickList(survey.ans13);
        Decimal ans13Numb1 = survey.ans13Numb1;
        Decimal ans13Numb2 = survey.ans13Numb2;
        Decimal ans13Numb3 = survey.ans13Numb3;
        Decimal ans13Numb4 = survey.ans13Numb4;
        Decimal ans13Numb5 = survey.ans13Numb5;

        // Setting answer14:
        String strAns14Pick = WED_CommonUtil.settingMapTopickList(survey.ans14);
        Decimal ans14Numb1 = survey.ans14Numb1;
        Decimal ans14Numb2 = survey.ans14Numb2;
        Decimal ans14Numb3 = survey.ans14Numb3;
        Decimal ans14Numb4 = survey.ans14Numb4;
        Decimal ans14Numb5 = survey.ans14Numb5;

        // Setting answer15:
        String strAns15Pick = WED_CommonUtil.settingMapTopickList(survey.ans15);

        // Setting answer16:
        /*String strAns16Pick = WED_CommonUtil.settingMapTopickList(survey.ans16);
        String strAns16Text = survey.ans16Text;*/

        // Setting answer17:
        String strAns17Pick = WED_CommonUtil.settingMapTopickList(survey.ans17);

        // Setting answer18:
        String strAns18Pick = WED_CommonUtil.settingMapTopickList(survey.ans18);
        String strAns18Text = survey.ans18Text;

        // Setting answer19:
        String strAns19Pick = WED_CommonUtil.settingMapTopickList(survey.ans19);

        // Setting answer20:
        String strAns20Pick = WED_CommonUtil.settingMapTopickList(survey.ans20);
        String strAns20Text1 = survey.ans20Text1;
        String strAns20Text2 = survey.ans20Text2;

        // Setting answer21:
        String strAns21Pick = WED_CommonUtil.settingMapTopickList(survey.ans21);
        String strAns21Best = survey.ans21Best;

        /*// Setting answer22:
        String strAns22Pick = WED_CommonUtil.settingMapTopickList(survey.ans22);*/
        
        // check FLS
        //String[] modifyFields = new String[]{'WED_Answers__c','WED_IsLock__c'};
        /*String[] modifyFields = new String[]{'Watabe_SentakuriyuuWatabe_SonotaSyousai__c', 'Goryousin_Soudan__c', 'Eturan_Zassi__c',
                                             'Eturan_Netto__c', 'Eturan_Sonota__c', 'Kekkon_Kentoujyoukyou__c', 'Gosoudan_Jyoukyou__c',
                                             'Raiten_Riyuu__c', 'Rizokon_Kentouriyuu__c', 'Kekkonsiki_Youbou__c', 'Kaijyou_Kodawari__c',
                                             'Sinrou_Tokoureki__c', 'Sinrou_Tokoukaisuu__c', 'Sinrou_Tokousonota__c', 'Sinpu_Tokoureki__c', 'Sinpu_Tokoukaisuu__c',
                                             'Sinpu_Tokousonota__c','KibouSutairu__c', 'kiboujikiCS__c', 'kiboujikiCS_shousai__c', 'OhigaraKibou__c', 'Kiboujiki_Riyuu__c',
                                             'Gesuto_Sinrou__c', 'Guesukazoku_shinrou__c', 'Guesushinzoku_shinrou__c', 'Guesuyuujin_shinrou__c',
                                             'Guesukaisha_shinrou__c', 'Gesuto_Sinpu__c', 'Guesukazoku_shinpu__c', 'Guesushinzoku_shinpu__c',
                                             'Guesuyuujin_shinpu__c', 'Guesukaisha_shinpu__c', 'Kekkonnsiki_Yosan__c', 'Kekkonsiki_Kentou_Sonota__c',
                                             'Kokunaisikijyou__c', 'Rizokon_SonotaSyousai__c', 'Kekkonsiki_Youbou_Sonota__c', 'Kyosiki_Kentoueria_CS_Syousai__c',
                                             'Kyosikikentoueria_Sonota__c', 'Kaijyou_Sonota__c', 'Kiboujiki_Sonota__c', 'KibouChaperu__c', 'Tasya_Kentou__c', 'WED_IsLock__c'};
        String objectName = 'Lead';
        
        // Check for inserting or updating the record
        if(!WED_CommonUtil.checkFLS(modifyFields, WED_CommonUtil.FLSType.UPDATE_OBJECT, objectName) 
            || !WED_CommonUtil.checkFLS(modifyFields, WED_CommonUtil.FLSType.CREATE_OBJECT, objectName)){
            return new WED_JsonResult(false,null,Label.WED_Error_AccessDeny);
        }*/

        try {
                List<Lead> leadSurvey = [SELECT Id, Watabe_SentakuriyuuWatabe_SonotaSyousai__c, Goryousin_Soudan__c, Eturan_Zassi__c,RaitenSankou__c, RaitenSankou_most__c,
                                                Eturan_Netto__c, Eturan_Sonota__c, Kekkon_Kentoujyoukyou__c, Gosoudan_Jyoukyou__c,kikkake_word__c,Guesusonota_shinrou__c,Guesusonota_shinpu__c,
                                                Raiten_Riyuu__c, Rizokon_Kentouriyuu__c, Kekkonsiki_Youbou__c, Kaijyou_Kodawari__c,kikkake_sonota__c,
                                                Sinrou_Tokoureki__c, Sinrou_Tokoukaisuu__c, Sinrou_Tokousonota__c, Sinpu_Tokoureki__c,Kyosiki_Kentoueria_CS_daiiti__c,
                                                Sinpu_Tokoukaisuu__c, Sinpu_Tokousonota__c,JimotoWedding__c,Kaijoukibou_CS__c,kikkake__c,kiboujikiCS_oomaka__c,kiboujikiCS_miketsu__c,
                                                KibouSutairu__c, kiboujikiCS__c, kiboujikiCS_shousai__c, OhigaraKibou__c, Kiboujiki_Riyuu__c,
                                                Gesuto_Sinrou__c, Guesukazoku_shinrou__c, Guesushinzoku_shinrou__c, Guesuyuujin_shinrou__c,
                                                Guesukaisha_shinrou__c, Gesuto_Sinpu__c, Guesukazoku_shinpu__c, Guesushinzoku_shinpu__c,
                                                Guesuyuujin_shinpu__c, Guesukaisha_shinpu__c, Kekkonnsiki_Yosan__c, Kekkonsiki_Kentou_Sonota__c,
                                                Kokunaisikijyou__c, Rizokon_SonotaSyousai__c, Kekkonsiki_Youbou_Sonota__c, Kyosiki_Kentoueria_CS_Syousai__c,
                                                Kyosikikentoueria_Sonota__c, Kaijyou_Sonota__c, Kiboujiki_Sonota__c, KibouChaperu__c, Tasya_Kentou__c,
                                                WED_IsLock__c 
                                           FROM Lead
                                          WHERE workSheetToken__c=:token
                                          LIMIT 1];

              // Check exist lead
              if(leadSurvey.isEmpty()){
                 return new WED_JsonResult(false, null, Label.WED_Error_SurveyNotFound);
              } else {
                Lead leadAnswer = leadSurvey.get(0);
                if(leadAnswer.WED_IsLock__c && strAuth =='false') {
                     return new WED_JsonResult(false, null, Label.WED_Label_Lock);
                 }
                
                // setting data for saving
                leadAnswer.Raiten_Riyuu__c  =  strAns1Pick;
                leadAnswer.Watabe_SentakuriyuuWatabe_SonotaSyousai__c  =  strAns1Text;
                leadAnswer.Rizokon_Kentouriyuu__c  =  strAns2Pick;
                leadAnswer.Rizokon_SonotaSyousai__c  =  strAns2Text;
                leadAnswer.Kekkonsiki_Youbou__c  =  strAns3Pick;
                leadAnswer.Kekkonsiki_Youbou_Sonota__c  =  strAns3Text;
                leadAnswer.Kyosiki_Kentoueria_CS_Syousai__c  =  strAns4Pick;
                leadAnswer.Kyosikikentoueria_Sonota__c  =  strAns4Text;
                leadAnswer.Kyosiki_Kentoueria_CS_daiiti__c  = strAns4Best;
                leadAnswer.JimotoWedding__c = strAns4N;
                leadAnswer.Kaijyou_Kodawari__c  =  strAns5Pick;
                leadAnswer.Kaijyou_Sonota__c  =  strAns5Text;
                //leadAnswer.KibouChaperu__c  =  strAns6;
                leadAnswer.Kaijoukibou_CS__c  =  strAns6;
                leadAnswer.KibouChaperu__c  =  strAns6Text;
                leadAnswer.Sinrou_Tokoureki__c  =  strAns7Pick;
                leadAnswer.Sinrou_Tokoukaisuu__c  = strAns7Sub1Pick;
                leadAnswer.Sinrou_Tokousonota__c  = strAns7Sub2Pick;
                leadAnswer.Sinpu_Tokoureki__c  =  strAns8Pick;
                leadAnswer.Sinpu_Tokoukaisuu__c  = strAns8Sub1Pick;
                leadAnswer.Sinpu_Tokousonota__c  = strAns8Sub2Pick;
                leadAnswer.KibouSutairu__c  =  strAns9;
                leadAnswer.kiboujikiCS__c  =  strAns10Pick;
                leadAnswer.kiboujikiCS_shousai__c = ans10Date;
                leadAnswer.kiboujikiCS_oomaka__c = strAns10ChangeYM;
                leadAnswer.kiboujikiCS_miketsu__c = strAns10PendYM;
                leadAnswer.OhigaraKibou__c  =  strAns11;
                leadAnswer.Kiboujiki_Riyuu__c  =  strAns12Pick;
                leadAnswer.Kiboujiki_Sonota__c  =  strAns12Text;
                leadAnswer.Gesuto_Sinrou__c  =  strAns13Pick;
                leadAnswer.Guesukazoku_shinrou__c = ans13Numb1;
                //leadAnswer.Guesushinzoku_shinrou__c = ans13Numb2;
                leadAnswer.Guesuyuujin_shinrou__c = ans13Numb3;
                //leadAnswer.Guesukaisha_shinrou__c = ans13Numb4;
                leadAnswer.Guesusonota_shinrou__c = ans13Numb5;
                leadAnswer.Gesuto_Sinpu__c  =  strAns14Pick;
                leadAnswer.Guesukazoku_shinpu__c = ans14Numb1;
                //leadAnswer.Guesushinzoku_shinpu__c = ans14Numb2;
                leadAnswer.Guesuyuujin_shinpu__c = ans14Numb3;
                //leadAnswer.Guesukaisha_shinpu__c = ans14Numb4;
                leadAnswer.Guesusonota_shinpu__c = ans14Numb5;
                leadAnswer.Kekkonnsiki_Yosan__c  =  strAns15Pick;
                /*leadAnswer.Kekkon_Kentoujyoukyou__c  =  strAns16Pick;
                leadAnswer.Kekkonsiki_Kentou_Sonota__c  =  strAns16Text;*/
                leadAnswer.Gosoudan_Jyoukyou__c  =  strAns17Pick;
                leadAnswer.Tasya_Kentou__c  =  strAns18Pick;
                leadAnswer.Kokunaisikijyou__c  =  strAns18Text;
                leadAnswer.Goryousin_Soudan__c  =  strAns19Pick;
                //leadAnswer.Eturan_Zassi__c  =  strAns20Pick;
                leadAnswer.kikkake__c  =  strAns20Pick;
                leadAnswer.kikkake_word__c  =  strAns20Text1;
                leadAnswer.kikkake_sonota__c  =  strAns20Text2;
				
                leadAnswer.RaitenSankou__c  =  strAns21Pick;
                leadAnswer.RaitenSankou_most__c  =  strAns21Best;
                /*leadAnswer.Eturan_Netto__c  =  strAns21Pick;
                leadAnswer.Eturan_Sonota__c  =  strAns22Pick;*/

                upsert leadAnswer;
              }

        } catch (DmlException ex) {
            return new WED_JsonResult(false, null, ex.getDmlMessage(0));
        }

        return new WED_JsonResult(true, null, Label.WED_Infor_Saved);
    }
    
    /* 
    Created Date: 01/12/17
    Create By: Minh Tuan
    Description: Get all Picklist fields
    */
    private SurveyObject getPickListOptions(String objectName){
        SurveyObject surveyObject = new SurveyObject();

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

    private String settingJsonSurveyAnswer(Lead lead){
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
        surveyObject.ans10Date = lead.kiboujikiCS_shousai__c != null ? lead.kiboujikiCS_shousai__c.format() : '';
        surveyObject.ans10ChangeYM = lead.kiboujikiCS_oomaka__c;
        surveyObject.ans10PendYM = lead.kiboujikiCS_miketsu__c;
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