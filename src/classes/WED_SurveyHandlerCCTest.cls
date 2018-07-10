@isTest
public class WED_SurveyHandlerCCTest {
	public static String strRole = '';
	
	/* Description: Method check token */
	public static boolean checkToken(String token){
		List<Lead> lstLead = [SELECT Id
					            FROM Lead
					           WHERE workSheetToken__c =: token
					           LIMIT 1];
		return !lstLead.isEmpty();
	}

	/* Description: Create Lead */
	public static Lead createLead(){
		Lead leadSurvey = new Lead();
        leadSurvey.Raiten_Riyuu__c = '多くのエリア・会場を扱っているから;旅行会社と異なり、挙式専門スタッフと相談できるから;キャンペーンや特典がが魅力的だったから;その他';
		leadSurvey.Rizokon_Kentouriyuu__c = '昔からリゾート挙式に憧れていたから;家族がリゾート挙式を希望しているから;その他';
		leadSurvey.Kekkonsiki_Youbou__c = '家族や友人に感謝の気持ちを伝えたい;その他;あてはまるものは無い';
        leadSurvey.JimotoWedding__c = '地元でのウェディング（ホテルやゲストハウス）とリゾ婚で迷っている';
		leadSurvey.Kyosiki_Kentoueria_CS_Syousai__c = 'ハワイ全般;イギリス';
        leadSurvey.Kyosiki_Kentoueria_CS_daiiti__c = 'その他';
		leadSurvey.Kaijyou_Kodawari__c = '海が見える;パーティ会場・演出;その他';
		leadSurvey.KibouChaperu__c = 'Text In Question 71';
		leadSurvey.Sinrou_Tokoureki__c = 'ある';
		leadSurvey.Sinrou_Tokoukaisuu__c = '2回';
		leadSurvey.Sinrou_Tokousonota__c = '';
		leadSurvey.Sinpu_Tokoureki__c = 'ない';
		leadSurvey.Sinpu_Tokoukaisuu__c='';
		leadSurvey.Sinpu_Tokousonota__c = '他のエリアの経験はある';
		leadSurvey.KibouSutairu__c = '結婚式＋お披露目パーティ';
		leadSurvey.kiboujikiCS__c = '大まかな時期を決めている';
        leadSurvey.kiboujikiCS_oomaka__c = '2018/03';
		//leadSurvey.kiboujikiCS_shousai__c  = Date.newInstance(2017, 12, 1);
		leadSurvey.OhigaraKibou__c = '仏滅でなければいい';
		leadSurvey.Kiboujiki_Riyuu__c = 'その他';
		leadSurvey.Gesuto_Sinrou__c = 'あり';
		leadSurvey.Gesuto_Sinpu__c = 'あり';
		leadSurvey.Kekkonnsiki_Yosan__c = '特に上限は決まっていない';
		leadSurvey.Kekkon_Kentoujyoukyou__c = 'その他';
		leadSurvey.Gosoudan_Jyoukyou__c = '3件目';
		leadSurvey.Tasya_Kentou__c = '上記以外のご検討されている会場や会社';
        leadSurvey.kikkake__c ='検索ワードを教えてください;その他';
        leadSurvey.kikkake_word__c ='Text201';
        leadSurvey.kikkake_sonota__c ='Text202';
        leadSurvey.RaitenSankou__c ='ゼクシィ海外ムック;ウェディングスタイル';
        leadSurvey.RaitenSankou_most__c ='この中にはない・特になし';
		leadSurvey.Goryousin_Soudan__c = '相談していない';
		leadSurvey.Eturan_Zassi__c = 'TVCM';
		leadSurvey.Eturan_Netto__c = 'Instagram';
		leadSurvey.Eturan_Sonota__c = '特になし';
		leadSurvey.Watabe_SentakuriyuuWatabe_SonotaSyousai__c = 'Question 1';
		leadSurvey.Rizokon_SonotaSyousai__c = 'Question 2';
		leadSurvey.Kekkonsiki_Youbou_Sonota__c = 'Question 3';
		leadSurvey.Kyosikikentoueria_Sonota__c = 'Question 5';
		leadSurvey.Kaijyou_Sonota__c = 'Question 6';
		leadSurvey.Kiboujiki_Sonota__c = 'Question 13';
		leadSurvey.Kekkonsiki_Kentou_Sonota__c = 'Question 16';
		leadSurvey.Kokunaisikijyou__c = 'Question 18';
		leadSurvey.Guesukazoku_shinrou__c = 11;
		//leadSurvey.Guesushinzoku_shinrou__c = 111;
		leadSurvey.Guesuyuujin_shinrou__c = 12;
		//leadSurvey.Guesukaisha_shinrou__c = 234;
		leadSurvey.Guesusonota_shinrou__c = 13;
		leadSurvey.Guesukazoku_shinpu__c = 14;
		//leadSurvey.Guesushinzoku_shinpu__c = 888;
		leadSurvey.Guesuyuujin_shinpu__c = 15;
		//leadSurvey.Guesukaisha_shinpu__c = 666;
        leadSurvey.Guesusonota_shinpu__c = 16;
        leadSurvey.Kaijoukibou_CS__c = '希望ある';
		leadSurvey.workSheetToken__c = 'a3f2dde56c85e54260975b46a72f286dd14fe000';
		leadSurvey.LastName = 'surveyHandlerCCTest2';
		leadSurvey.WED_IsLock__c = false;
		leadSurvey.Company = 'Xem xong xoa';

		insert leadSurvey;

		return leadSurvey;
	}

	/* Description: Create Lead */
	public static Lead createLeadTrigger(){
		Lead leadSurvey = new Lead();
		leadSurvey.Raiten_Riyuu__c = '帰国後の地元パーティーも紹介してくれるから';
		leadSurvey.Rizokon_Kentouriyuu__c = 'リーズナブルだから';
		leadSurvey.Kekkonsiki_Youbou__c = '旅行中心に楽しみたい';
		leadSurvey.Kyosiki_Kentoueria_CS_Syousai__c = 'ケアンズ';
		leadSurvey.Kaijyou_Kodawari__c = 'ビーチが近い';
		leadSurvey.KibouChaperu__c = 'Answer Question 6';
		leadSurvey.Sinrou_Tokoureki__c = 'あり';
		leadSurvey.Sinrou_Tokoukaisuu__c = '1回';
		leadSurvey.Sinrou_Tokousonota__c = '';
		leadSurvey.Sinpu_Tokoureki__c = 'なし';
		leadSurvey.Sinpu_Tokoukaisuu__c='';
		leadSurvey.Sinpu_Tokousonota__c = '海外旅行自体が初めて';
		leadSurvey.KibouSutairu__c = '結婚式＋お披露目パーティ';
		leadSurvey.kiboujikiCS__c = '大まかな時期を決めている';
		leadSurvey.kiboujikiCS_shousai__c  = Date.newInstance(2017, 12, 2);
		leadSurvey.OhigaraKibou__c = '仏滅でなければいい';
		leadSurvey.Kiboujiki_Riyuu__c = '家族の都合で';
		leadSurvey.Gesuto_Sinrou__c = 'あり';
		leadSurvey.Gesuto_Sinpu__c = 'あり';
		leadSurvey.Kekkonnsiki_Yosan__c = '50～100万円';
		leadSurvey.Kekkon_Kentoujyoukyou__c = 'エリアを検討している';
		leadSurvey.Gosoudan_Jyoukyou__c = '2件目';
		leadSurvey.Tasya_Kentou__c = 'タカミブライダル';
		leadSurvey.Goryousin_Soudan__c = '相談した';
		leadSurvey.Eturan_Zassi__c = 'BAILA(婚BAILA)';
		leadSurvey.Eturan_Netto__c = 'facebook';
		leadSurvey.Eturan_Sonota__c = 'ＨＩＳ';
		leadSurvey.Watabe_SentakuriyuuWatabe_SonotaSyousai__c = 'Text optional of Question 1';
		leadSurvey.Rizokon_SonotaSyousai__c = 'Text optional of Question 2';
		leadSurvey.Kekkonsiki_Youbou_Sonota__c = 'Text optional of Question 3';
		leadSurvey.Kyosikikentoueria_Sonota__c = 'Text optional of Question 4';
		leadSurvey.Kaijyou_Sonota__c = 'Text optional of Question 5';
		leadSurvey.Kiboujiki_Sonota__c = 'Text optional of Question 12';
		leadSurvey.Kekkonsiki_Kentou_Sonota__c = 'Text optional of Question 16';
		leadSurvey.Kokunaisikijyou__c = 'Text optional of Question 18';
		leadSurvey.Guesukazoku_shinrou__c = 1;
		leadSurvey.Guesushinzoku_shinrou__c = 111;
		leadSurvey.Guesuyuujin_shinrou__c = 123;
		leadSurvey.Guesukaisha_shinrou__c = 234;
		leadSurvey.Guesukazoku_shinpu__c = 999;
		leadSurvey.Guesushinzoku_shinpu__c = 888;
		leadSurvey.Guesuyuujin_shinpu__c = 777;
		leadSurvey.Guesukaisha_shinpu__c = 666;
		leadSurvey.workSheetToken__c = '';
		leadSurvey.LastName = 'surveyHandlerCCTest1';
        leadSurvey.Company = 'Xem xem xem';
		leadSurvey.WED_IsLock__c = false;

		insert leadSurvey;

		return leadSurvey;
	}

	public static Lead createLead2(){
		Lead leadSurvey = new Lead();        
        leadSurvey.Raiten_Riyuu__c = '多くのエリア・会場を扱っているから;旅行会社と異なり、挙式専門スタッフと相談できるから;キャンペーンや特典がが魅力的だったから;その他';
		leadSurvey.Rizokon_Kentouriyuu__c = '昔からリゾート挙式に憧れていたから;家族がリゾート挙式を希望しているから;その他';
		leadSurvey.Kekkonsiki_Youbou__c = '家族や友人に感謝の気持ちを伝えたい;その他;あてはまるものは無い';
        leadSurvey.JimotoWedding__c = '地元でのウェディング（ホテルやゲストハウス）とリゾ婚で迷っている';
		leadSurvey.Kyosiki_Kentoueria_CS_Syousai__c = 'ハワイ全般;イギリス';
        leadSurvey.Kyosiki_Kentoueria_CS_daiiti__c = 'その他';
		leadSurvey.Kaijyou_Kodawari__c = '海が見える;パーティ会場・演出;その他';
		leadSurvey.KibouChaperu__c = 'Text In Question 6';
		leadSurvey.Sinrou_Tokoureki__c = 'ある';
		leadSurvey.Sinrou_Tokoukaisuu__c = '2回';
		leadSurvey.Sinrou_Tokousonota__c = '';
		leadSurvey.Sinpu_Tokoureki__c = 'ない';
		leadSurvey.Sinpu_Tokoukaisuu__c='';
		leadSurvey.Sinpu_Tokousonota__c = '他のエリアの経験はある';
		leadSurvey.KibouSutairu__c = '結婚式＋お披露目パーティ';
		leadSurvey.kiboujikiCS__c = '大まかな時期を決めている';
        leadSurvey.kiboujikiCS_oomaka__c = '2018/03';
		//leadSurvey.kiboujikiCS_shousai__c  = Date.newInstance(2017, 12, 1);
		leadSurvey.OhigaraKibou__c = '仏滅でなければいい';
		leadSurvey.Kiboujiki_Riyuu__c = 'その他';
		leadSurvey.Gesuto_Sinrou__c = 'あり';
		leadSurvey.Gesuto_Sinpu__c = 'あり';
		leadSurvey.Kekkonnsiki_Yosan__c = '特に上限は決まっていない';
		leadSurvey.Kekkon_Kentoujyoukyou__c = 'その他';
		leadSurvey.Gosoudan_Jyoukyou__c = '3件目';
		leadSurvey.Tasya_Kentou__c = '上記以外のご検討されている会場や会社';
        leadSurvey.kikkake__c ='検索ワードを教えてください;その他';
        leadSurvey.kikkake_word__c ='Text201';
        leadSurvey.kikkake_sonota__c ='Text202';
        leadSurvey.RaitenSankou__c ='ゼクシィ海外ムック;ウェディングスタイル';
        leadSurvey.RaitenSankou_most__c ='この中にはない・特になし';
		leadSurvey.Goryousin_Soudan__c = '相談していない';
		leadSurvey.Eturan_Zassi__c = 'TVCM';
		leadSurvey.Eturan_Netto__c = 'Instagram';
		leadSurvey.Eturan_Sonota__c = '特になし';
		leadSurvey.Watabe_SentakuriyuuWatabe_SonotaSyousai__c = 'Question 1';
		leadSurvey.Rizokon_SonotaSyousai__c = 'Question 2';
		leadSurvey.Kekkonsiki_Youbou_Sonota__c = 'Question 3';
		leadSurvey.Kyosikikentoueria_Sonota__c = 'Question 5';
		leadSurvey.Kaijyou_Sonota__c = 'Question 6';
		leadSurvey.Kiboujiki_Sonota__c = 'Question 13';
		leadSurvey.Kekkonsiki_Kentou_Sonota__c = 'Question 16';
		leadSurvey.Kokunaisikijyou__c = 'Question 18';
		leadSurvey.Guesukazoku_shinrou__c = 11;
		//leadSurvey.Guesushinzoku_shinrou__c = 111;
		leadSurvey.Guesuyuujin_shinrou__c = 12;
		//leadSurvey.Guesukaisha_shinrou__c = 234;
		leadSurvey.Guesusonota_shinrou__c = 13;
		leadSurvey.Guesukazoku_shinpu__c = 14;
		//leadSurvey.Guesushinzoku_shinpu__c = 888;
		leadSurvey.Guesuyuujin_shinpu__c = 15;
		//leadSurvey.Guesukaisha_shinpu__c = 666;
        leadSurvey.Guesusonota_shinpu__c = 16;
        leadSurvey.Kaijoukibou_CS__c = '希望ある';
		leadSurvey.workSheetToken__c = 'a3f2dde56c85e54260975b46a72f286dd14fe000';
		leadSurvey.LastName = 'surveyHandlerCCTest2';
		leadSurvey.WED_IsLock__c = false;
		leadSurvey.Company = 'Xem xong xoa';

		insert leadSurvey;

		return leadSurvey;
	}

	
	/* Description: Create Json Answer */
	public static String createJsonAnswer(boolean bolTemp){
		String textChange = bolTemp ? 'Text In Question 6' : 'Text Change In Question 6';

		String answer;        
        answer = '{';
		answer += '"ans9":"結婚式＋お披露目パーティ",';
        answer += '"ans8Sub2":{"child":"他のエリアの経験はある"},';
        answer += '"ans8Sub1":{},';
        answer += '"ans8":{"parent":"ない"},';
        answer += '"ans7Sub2":{},';
        answer += '"ans7Sub1":{"child":"2回"},';
        answer += '"ans7":{"parent":"ある"},';
        answer += '"ans6Text":"' + textChange + '",';
        answer += '"ans6":"希望ある",';
        answer += '"ans5Text":"Question 6",';
        answer += '"ans5":{"item12":"その他","item6":"パーティ会場・演出","item1":"海が見える"},';
        answer += '"ans4Text":"Question 5",';
        answer += '"ans4N":"地元でのウェディング（ホテルやゲストハウス）とリゾ婚で迷っている",';
        answer += '"ans4Best":"その他",';
        answer += '"ans4":{"item1":"ハワイ全般","item16":"イギリス"},';
        answer += '"ans3Text":"Question 3",';
        answer += '"ans3":{"item16":"あてはまるものは無い","item15":"その他","item1":"家族や友人に感謝の気持ちを伝えたい"},';
        answer += '"ans2Text":"Question 2",';
        answer += '"ans21Best":"この中にはない・特になし",';
        answer += '"ans21":{"item15":"ウェディングスタイル","item1":"ゼクシィ海外ムック"},';
        answer += '"ans20Text2":"Text202",';
        answer += '"ans20Text1":"Text201",';
        answer += '"ans20":{"item10":"その他","item3":"検索ワードを教えてください"},';
        answer += '"ans2":{"item6":"家族がリゾート挙式を希望しているから","item12":"その他","item1":"昔からリゾート挙式に憧れていたから"},';
        answer += '"ans1Text":"Question 1",';
        answer += '"ans19":{"value":"相談していない"},';
        answer += '"ans18Text":"Question 18",';
        answer += '"ans18":{"item10":"上記以外のご検討されている会場や会社"},';
        answer += '"ans17":{"value":"3件目"},';
        answer += '"ans15":{"value":"特に上限は決まっていない"},';
        answer += '"ans14Numb5":16,';
        answer += '"ans14Numb4":null,';
        answer += '"ans14Numb3":15,';
        answer += '"ans14Numb2":null,';
        answer += '"ans14Numb1":14,';
        answer += '"ans14":{"parent":"あり"},';
        answer += '"ans13Numb5":13,';
        answer += '"ans13Numb4":null,';
        answer += '"ans13Numb3":12,';
        answer += '"ans13Numb2":null,';
        answer += '"ans13Numb1":11,';
        answer += '"ans13":{"parent":"あり"},';
        answer += '"ans12Text":"Question 13",';
        answer += '"ans12":{"value":"その他"},';
        answer += '"ans11":"仏滅でなければいい",';
        answer += '"ans10PendYM":null,';
        answer += '"ans10Date":"",';
        answer += '"ans10ChangeYM":"2018/03",';
        answer += '"ans10":{"value":"大まかな時期を決めている"},';
        answer += '"ans1":{"item10":"キャンペーンや特典がが魅力的だったから","item12":"その他","item4":"旅行会社と異なり、挙式専門スタッフと相談できるから","item1":"多くのエリア・会場を扱っているから"}';
        answer += '}';
		return answer;
	}

	/*Test Function: getListImage
      Test Case: Check URL is right with expected (Multiple image)*/    
    @isTest(SeeAllData=true)
    public static void getListImageTest1(){
    	String host = 'https://sc-watabe-wedding.cs58.force.com/contact';
    	String strFolderName = 'WatabeWedding';
    	Id strOrgId = UserInfo.getOrganizationId();
    	List<Document> currentPictures = [SELECT ID,URL,Name FROM Document 
                                              WHERE Folder.Name =: strFolderName
                                              LIMIT 100];

        String strImgUrlExpected = host + '/servlet/servlet.ImageServer?id=' + currentPictures.get(0).ID + '&oid=' + strOrgId;
        Map<String,String> mapImageReturn = WED_SurveyHandlerCC.getListImage(host);

        List<String> lstImageReturn = new List<String>(mapImageReturn.keySet());
        String firstImageUrl = (String)mapImageReturn.get(lstImageReturn[0]);

        System.assertEquals(strImgUrlExpected, firstImageUrl);
    	
    }

    /*Test Function: getListImage
      Test Case: Check URL is right with expected (Have no image)*/    
    @isTest
    public static void getListImageTest2(){
    	String host = 'https://sc-watabe-wedding.cs58.force.com/contact';
    	String strFolderName = 'WatabeWedding';
    	Id strOrgId = UserInfo.getOrganizationId();
    	List<Document> currentPictures = [SELECT ID,URL,NAME FROM Document 
                                              WHERE FOLDER.Name =: strFolderName
                                              LIMIT 100];

        Map<String,String> mapImageReturn = WED_SurveyHandlerCC.getListImage(host);
        List<String> lstImageReturn = new List<String>(mapImageReturn.keySet());

        System.assertEquals(currentPictures.size(), lstImageReturn.size());
    	
    }

    /*Test Function: redirectLock
      Test Case: Check URL of PageReference return is right*/    
    @isTest 
    public static void redirectLockTest(){
    	String strRole = '/survey';
    	String urlRedirecrExpexted = strRole + '/WED_SurveyLockPage';
    	PageReference pageReferenceReturn = WED_SurveyHandlerCC.redirectLock();

        System.assertEquals(urlRedirecrExpexted, pageReferenceReturn.getUrl());
    	
    }

    /*Test Function: redirectConfirm
      Test Case: Check URL of PageReference return is right*/    
    @isTest 
    public static void redirectConfirmTest(){
    	createLead();
    	String strJson = createJsonAnswer(true);
    	String token = 'a3f2dde56c85e54260975b46a72f286dd14fe0ff';
    	String isStaff='true';
    	String urlRedirecrExpexted = Site.getBaseUrl() + '/WED_SurveyConfirmPage?workSheetToken=a3f2dde56c85e54260975b46a72f286dd14fe0ff';

    	// Confirm data save
    	PageReference pageReferenceReturn = WED_SurveyHandlerCC.redirectConfirm(strJson, token, isStaff);
         System.assertEquals(urlRedirecrExpexted, pageReferenceReturn.getUrl());
    	
    }

    /*Test Function: doRoutine
      Test Case: invalidToken*/
    @isTest 
    public static void doRoutineTest1(){
    	String urlRedirecrExpexted = Site.getBaseUrl() + '/WED_ErrorTokenPage';
    	WED_SurveyHandlerCC surveyHandlerCC = new WED_SurveyHandlerCC();
    	WED_SurveyHandlerCC.isValidToken = false;
		PageReference pageReturn = surveyHandlerCC.doRoutine();

		System.assertEquals(urlRedirecrExpexted, pageReturn.getUrl());
    	
    }

    /*Test Function: doRoutine
      Test Case: Record lock*/
    @isTest
	public static void doRoutineTest2(){
		strRole = '/survey';
        //Test.setCurrentPage(pageRef);
        WED_SurveyHandlerCC surveyHandlerCC = new WED_SurveyHandlerCC();
		String urlRedirecrExpexted = '/survey/WED_SurveyLockPage';		
		WED_SurveyHandlerCC.isValidToken = true;
		WED_SurveyHandlerCC.authorized = false;
		WED_SurveyHandlerCC.isLock = true;
		PageReference pageReturn = surveyHandlerCC.doRoutine();

		System.assertEquals(urlRedirecrExpexted, pageReturn.getUrl());
	}

	/*Test Function: doRoutine
      Test Case: Run normal*/
    @isTest
	public static void doRoutineTest3(){
		strRole = '/contact';
		WED_SurveyHandlerCC surveyHandlerCC = new WED_SurveyHandlerCC();
		WED_SurveyHandlerCC.isValidToken = true;
		PageReference pageReturn = surveyHandlerCC.doRoutine();

		System.assertEquals(null, pageReturn);
	}

	/*Test Constructor
      Test Case: Access as a customer*/
    @isTest
	public static void WED_SurveyHandlerCCTest1(){
		PageReference pageRef = Page.WED_SurveyWeddingPage;
        Test.setCurrentPage(pageRef);
        WED_SurveyHandlerCC controller = new WED_SurveyHandlerCC();

        String workSheetToken = ApexPages.currentPage().getParameters().get('workSheetToken');

        System.assertEquals(null, workSheetToken);
	}

	/*Test Constructor
      Test Case: Access as a customer */
    @isTest
	public static void WED_SurveyHandlerCCTest2(){
		PageReference pageRef = new PageReference(Site.getBaseUrl() + '/survey');
		strRole = '/survey';
        Test.setCurrentPage(pageRef);

        WED_SurveyHandlerCC controller = new WED_SurveyHandlerCC();


        System.assertEquals(false, WED_SurveyHandlerCC.authorized);
	}

	/*Test Constructor
      Test Case: Access as a staff*/
    @isTest
	public static void WED_SurveyHandlerCCTest3(){
		PageReference pageRef = new PageReference(Site.getBaseUrl() + '/contact');
		strRole = '/contact';
        Test.setCurrentPage(pageRef);

        WED_SurveyHandlerCC controller = new WED_SurveyHandlerCC();


        System.assertEquals(true, WED_SurveyHandlerCC.authorized);
	}

	/*Test Constructor
      Test Case: Access as a customer with token that doesn't exist*/
    @isTest
	public static void WED_SurveyHandlerCCTest4(){
		String token = 'thisistokendoesnotexist';
		System.assertEquals(false, checkToken(token));

		PageReference pageRef = new PageReference(Site.getBaseUrl() + '/survey');
		strRole = '/survey';
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('workSheetToken',token);

        WED_SurveyHandlerCC controller = new WED_SurveyHandlerCC();


        System.assertEquals(false, WED_SurveyHandlerCC.isValidToken);
	}

	/*Test Constructor
      Test Case: Access as a customer with token exist*/
    @isTest
	public static void WED_SurveyHandlerCCTest5(){
		Lead leado = createLead2();

		// Json String expected
		String seqAnswerExpected = createJsonAnswer(true);

		PageReference pageRef = new PageReference(Site.getBaseUrl() + '/survey');
		strRole = '/survey';
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('workSheetToken',leado.workSheetToken__c);

        WED_SurveyHandlerCC controller = new WED_SurveyHandlerCC();
		System.debug('@@@@ ----> WED_SurveyHandlerCC.seqAnswer: ' + WED_SurveyHandlerCC.seqAnswer);
        System.assertEquals(true, WED_SurveyHandlerCC.isValidToken);
        System.assertEquals(seqAnswerExpected, WED_SurveyHandlerCC.seqAnswer);
        System.assertEquals(leado.WED_IsLock__c, WED_SurveyHandlerCC.isLock);
        System.assertEquals(Label.WED_Label_Survey, WED_SurveyHandlerCC.header);
	}

	/*Test Constructor
      Test Case: Access as a customer with token exist and have a locked survey*/
    @isTest
	public static void WED_SurveyHandlerCCTest6(){
		Lead leado = createLead2();
		leado.WED_IsLock__c = true;
		update leado;

		// Json String expected
		String seqAnswerExpected = createJsonAnswer(true);

		PageReference pageRef = new PageReference(Site.getBaseUrl() + '/survey');
		strRole = '/survey';
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('workSheetToken',leado.workSheetToken__c);

        WED_SurveyHandlerCC controller = new WED_SurveyHandlerCC();

        System.assertEquals(true, WED_SurveyHandlerCC.isValidToken);
        System.assertEquals(seqAnswerExpected, WED_SurveyHandlerCC.seqAnswer);
        System.assertEquals(leado.WED_IsLock__c, WED_SurveyHandlerCC.isLock);
        System.assertEquals(Label.WED_Label_Survey, WED_SurveyHandlerCC.header);
	}

	/*Test Constructor
      Test Case: Access as a staff with token exist*/
    @isTest
	public static void WED_SurveyHandlerCCTest7(){
		Lead leado = createLead2();

		// Json String expected
		String seqAnswerExpected = createJsonAnswer(true);

		PageReference pageRef = new PageReference(Site.getBaseUrl() + '/contact');
		strRole = '/contact';
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('workSheetToken',leado.workSheetToken__c);

        WED_SurveyHandlerCC controller = new WED_SurveyHandlerCC();
        /*String format = Label.WED_Label_SurveyHeader;
        String headerExpected = WED_CommonUtil.formatHeader(format, leado.LastName);*/

        System.assertEquals(true, WED_SurveyHandlerCC.isValidToken);
        System.assertEquals(seqAnswerExpected, WED_SurveyHandlerCC.seqAnswer);
        System.assertEquals(false, WED_SurveyHandlerCC.isLock);
        System.assertEquals(Label.WED_Label_Survey, WED_SurveyHandlerCC.header);
	}

	/*Test Constructor
      Test Case: Access as a staff with token exist and have a locked survey*/
    @isTest
	public static void WED_SurveyHandlerCCTest8(){
		Lead leado = createLead2();
		leado.WED_IsLock__c = true;
		update leado;
		
		// Json String expected
		String seqAnswerExpected = createJsonAnswer(true);

		PageReference pageRef = new PageReference(Site.getBaseUrl() + '/contact');
		strRole = '/contact';
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('workSheetToken',leado.workSheetToken__c);

        WED_SurveyHandlerCC controller = new WED_SurveyHandlerCC();
        /*String format = Label.WED_Label_SurveyHeader;
        String headerExpected = WED_CommonUtil.formatHeader(format, leado.LastName);*/

        System.assertEquals(true, WED_SurveyHandlerCC.isValidToken);
        System.assertEquals(seqAnswerExpected, WED_SurveyHandlerCC.seqAnswer);
        System.assertEquals(false, WED_SurveyHandlerCC.isLock);
        System.assertEquals(Label.WED_Label_Survey, WED_SurveyHandlerCC.header);
	}

	/*Test Data Saved
      Test Case: Doesn't exist data answer, doesn't exist Lead*/
    @isTest
	public static void saveDataTest1(){
		Lead leado = createLead();
		delete leado;

		WED_JsonResult jsonReturn = WED_SurveyHandlerCC.saveData(createJsonAnswer(true),leado.workSheetToken__c, 'false' );

		System.assertEquals(jsonReturn.errorMessage, Label.WED_Error_SurveyNotFound);
	}

	/*Test Data Saved
      Test Case: Exist data answer, record is locked and access as a customer*/
    @isTest
	public static void saveDataTest2(){
		Lead leado = createLead2();
		leado.WED_IsLock__c = true;
		update leado;
		
		//  JSON return result of saving data.
		WED_JsonResult jsonReturn = WED_SurveyHandlerCC.saveData(createJsonAnswer(true),leado.workSheetToken__c, 'false' );

		System.assertEquals(jsonReturn.errorMessage, Label.WED_Label_Lock);
	}

	/*Test Data Saved
      Test Case: Save data normally*/
    @isTest
	public static void saveDataTest3(){
		Lead leado = createLead2();

		WED_JsonResult jsonReturn = WED_SurveyHandlerCC.saveData(createJsonAnswer(true), leado.workSheetToken__c, 'false' );

		System.assertEquals(jsonReturn.errorMessage, Label.WED_Infor_Saved);
	}

	/*Test Data Saved
      Test Case: Save lead normally*/
    @isTest
	public static void leadTriggerTest(){
		Lead leado = createLeadTrigger();

		System.assertNotEquals(null, leado);
	}

}