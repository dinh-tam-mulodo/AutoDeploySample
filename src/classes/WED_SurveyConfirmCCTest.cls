@isTest
public class WED_SurveyConfirmCCTest {
	public static final Id ORG_ID = UserInfo.getOrganizationId();
	public static String roleUrl;

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Descrition: Create Lead
    */
	public static Lead createLead(){
		Lead leadSurvey = new Lead();
		leadSurvey.Raiten_Riyuu__c = '多くのエリア・会場を扱っているから;旅行会社と異なり、挙式専門スタッフと相談できるから;キャンペーンや特典がが魅力的だったから;その他';
		leadSurvey.Rizokon_Kentouriyuu__c = '昔からリゾート挙式に憧れていたから;家族がリゾート挙式を希望しているから;その他';
		leadSurvey.Kekkonsiki_Youbou__c = '家族や友人に感謝の気持ちを伝えたい;その他;あてはまるものは無い';
        leadSurvey.JimotoWedding__c = '地元でのウェディング（ホテルやゲストハウス）とリゾ婚で迷っている';
		leadSurvey.Kyosiki_Kentoueria_CS_Syousai__c = 'ハワイ全般;イギリス';
        leadSurvey.Kyosiki_Kentoueria_CS_daiiti__c = 'その他';
		leadSurvey.Kaijyou_Kodawari__c = '海が見える;パーティ会場・演出;その他';
		leadSurvey.KibouChaperu__c = 'Text In Question 7';
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

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Descrition: Generate Answer JSON
    */

	public static String generateAnswer(){
		String answer;

		answer = '{';
		answer += '"ans9":"結婚式＋お披露目パーティ",';
        answer += '"ans8Sub2":{"child":"他のエリアの経験はある"},';
        answer += '"ans8Sub1":{},';
        answer += '"ans8":{"parent":"ない"},';
        answer += '"ans7Sub2":{},';
        answer += '"ans7Sub1":{"child":"2回"},';
        answer += '"ans7":{"parent":"ある"},';
        answer += '"ans6Text":"Text In Question 7",';
        answer += '"ans6":"希望ある",';
        answer += '"ans5Text":"Question 6",';
        answer += '"ans5":{"item12":"その他","item6":"パーティ会場・演出","item1":"海が見える"},';
        answer += '"ans4Text":"Question 5",';
        answer += '"ans4N":"地元でのウェディング（ホテルやゲストハウス）とリゾ婚で迷っている",';
        answer += '"ans4Best":"その他",';
        answer += '"ans4":{"item16":"イギリス","item1":"ハワイ全般"},';
        answer += '"ans3Text":"Question 3",';
        answer += '"ans3":{"item16":"あてはまるものは無い","item15":"その他","item1":"家族や友人に感謝の気持ちを伝えたい"},';
        answer += '"ans2Text":"Question 2",';
        answer += '"ans21Best":"この中にはない・特になし",';
        answer += '"ans21":{"item15":"ウェディングスタイル","item1":"ゼクシィ海外ムック"},';
        answer += '"ans20Text2":"Text202",';
        answer += '"ans20Text1":"Text201",';
        answer += '"ans20":{"item10":"その他","item3":"検索ワードを教えてください"},';
        answer += '"ans2":{"item12":"その他","item6":"家族がリゾート挙式を希望しているから","item1":"昔からリゾート挙式に憧れていたから"},';
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
        answer += '"ans10PendYM":"",';
        answer += '"ans10Date":"",';
        answer += '"ans10ChangeYM":"2018年03月",';
        answer += '"ans10":{"value":"大まかな時期を決めている"},';
        answer += '"ans1":{"item12":"その他","item10":"キャンペーンや特典がが魅力的だったから","item4":"旅行会社と異なり、挙式専門スタッフと相談できるから","item1":"多くのエリア・会場を扱っているから"}';
        answer += '}';
		return answer;
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Descrition: Create Survey Answer
    */
	public static List<Document> createDocument(){
		List<Document> docList = new List<Document>();
		
		String folderName = Label.WED_Label_FolderName;
		Folder f = [Select Id From Folder where Name =: folderName Limit 1];

		for (Integer i = 0; i < 5; i++){
			Document doc = new Document();
			doc.Name = 'name' + String.valueOf(i);
			doc.FolderId = f.Id;
			docList.add(doc);
		}
		insert docList;

		return docList;
	}

	/*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Descrition: Create Map contain Date intend to celebrate the wedding
    */
	public static Map<String, String> createDateMap(String strVal){
		Map<String, String> mapDt =  new Map<String, String>();
		mapDt.put('value',strVal);

		return mapDt;
	}


	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: init Controller
    Test Case: No Lead
    */
	@isTest
	public static void testWED_SurveyConfirmCC1() {
		PageReference pageRef = Page.WED_SurveyConfirmPage;
	    Test.setCurrentPage(pageRef);
	    roleUrl = 'test/contact/WED_SurveyWeddingPage';
	    WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: init Controller
    Test Case: Valid Lead - Valid Answer - Staff
    */
	@isTest
	public static void testWED_SurveyConfirmCC2() {
		Lead l = createLead();
		 
		PageReference pageRef = Page.WED_SurveyConfirmPage;
		pageRef.getParameters().put('workSheetToken', l.workSheetToken__c);
	    Test.setCurrentPage(pageRef);
	    roleUrl = 'test/contact/WED_SurveyWeddingPage';
	    
	    WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: init Controller
    Test Case: Valid Lead - Valid Answer - Customer
    */
	@isTest
	public static void testWED_SurveyConfirmCC3() {
		Lead l = createLead();
		 
		PageReference pageRef = Page.WED_SurveyConfirmPage;
		pageRef.getParameters().put('workSheetToken', l.workSheetToken__c);
	    Test.setCurrentPage(pageRef);
	    roleUrl = 'test/survey/WED_SurveyWeddingPage';
	    
	    WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: doRoutine
    Test Case: Token is invalid
    */
	@isTest
	public static void doRoutineTest1() {
		roleUrl = 'test/contact/WED_SurveyWeddingPage';
		WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
		WED_SurveyConfirmCC.isValidToken = false;
		controller.doRoutine();
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: doRoutine
    Test Case: Survey is lock
    */
	@isTest
	public static void doRoutineTest2() {
		roleUrl = 'test/contact/WED_SurveyWeddingPage';
		WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();

		WED_SurveyConfirmCC.isValidToken = true;
		WED_SurveyConfirmCC.authorized = false;
		WED_SurveyConfirmCC.isLock = true;

		controller.doRoutine();
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: doRoutine
    Test Case: Survey exist
    */
	@isTest
	public static void doRoutineTest3() {
		roleUrl = 'test/contact/WED_SurveyWeddingPage';
		WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
		WED_SurveyConfirmCC.isValidToken = true;
		
		controller.doRoutine();
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: redirectLock
    Test Case: Survey exist
    */
	@isTest
	public static void redirectLockTest1() {
		roleUrl = 'test/contact/WED_SurveyWeddingPage';
		WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
		WED_SurveyConfirmCC.redirectLock();
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: getListImage
    Test Case: 
    */
	@isTest
	public static void getListImageTest1() {
		createDocument();
		roleUrl = 'test/contact/WED_SurveyWeddingPage';
		WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
		Map<String,String> result = WED_SurveyConfirmCC.getListImage('host');
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: redirectLastSurvey
    Test Case: 
    */
	@isTest
	public static void redirectLastSurveyTest1() {
		roleUrl = 'test/contact/WED_SurveyWeddingPage';
		WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
		WED_SurveyConfirmCC.redirectLastSurvey('token');
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: redirectLastSurvey
    Test Case:     Customer
    */
	@isTest
	public static void redirectLastSurveyTest2() {
		roleUrl = 'test/survey/WED_SurveyWeddingPage';
		WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
		WED_SurveyConfirmCC.redirectLastSurvey('token');
	}

	/*
    Created Date: 23/11/17
    Create By: Minh Tuan
    Test Function: redirectFinish
    Test Case: 
    */
	@isTest
	public static void redirectFinishTest1() {
		roleUrl = 'test/contact/WED_SurveyWeddingPage';
		WED_SurveyConfirmCC controller = new WED_SurveyConfirmCC();
		WED_SurveyConfirmCC.redirectFinish('token');
	}

	/*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: lockSurvey
    Test Case:  Lock normal
    */
    @isTest
	public static void lockSurveyTest() {
		Lead leado = createLead();
		WED_JsonResult result = WED_SurveyConfirmCC.lockSurvey(leado.workSheetToken__c);

		String strExpect = Label.Wed_Label_Lock;

		System.assertEquals(strExpect, result.errorMessage);
		
	}



	/*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingDate
    Test Case:  日程を決めている -> Just show the date
    */
	@isTest
	public static void settingDateTest1() {
		String optionChoose = '日程を決めている';
		Date dateObj = Date.newInstance(2017, 12, 2);
		String strExpect = '2017年12月2日';

		String strActual = WED_SurveyConfirmCC.settingDate(dateObj, optionChoose);

		System.assertEquals(strExpect, strActual);

	}

	/*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingDate
    Test Case:  大まかな時期を決めている -> Date + ごろ
    */
	@isTest
	public static void settingDateTest2() {
		String optionChoose = '大まかな時期を決めている';
		Date dateObj = Date.newInstance(2017, 12, 2);
		String strExpect = '2017年12月2日ごろ';

		String strActual = WED_SurveyConfirmCC.settingDate(dateObj, optionChoose);

		System.assertEquals(strExpect, strActual);

	}

	/*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingDate
    Test Case:  特に時期は決めていない -> Date + ごろまでには
    */
	@isTest
	public static void settingDateTest3() {
		String optionChoose = '特に時期は決めていない';
		Date dateObj = Date.newInstance(2017, 12, 2);
		String strExpect = '2017年12月2日ごろまでには';

		String strActual = WED_SurveyConfirmCC.settingDate(dateObj, optionChoose);

		System.assertEquals(strExpect, strActual);
	}

	/*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingDate
    Test Case:  Data dependent is empty
    */
	@isTest
	public static void settingDateTest4() {
		String optionChoose = '';
		Date dateObj = Date.newInstance(2017, 12, 2);
		String strExpect = '';

		String strActual = WED_SurveyConfirmCC.settingDate(dateObj, optionChoose);

		System.assertEquals(strExpect, strActual);
	}

	/*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: settingDate
    Test Case:  Data dependent is other
    */
	@isTest
	public static void settingDateTest5() {
		String optionChoose = 'OtherValue';
		Date dateObj = Date.newInstance(2017, 12, 2);
		String strExpect = '2017年12月2日';

		String strActual = WED_SurveyConfirmCC.settingDate(dateObj, optionChoose);

		System.assertEquals(strExpect, strActual);
	}


	/*
    Created Date: 04/12/17
    Create By: Dung Nguyen
    Test Function: Setting data JSON to show on screen.
    Test Case:     N/A
    */
	@isTest
	public static void settingJsonSurveyAnswerTest1() {
		Lead leadSurvey = createLead();

		String jsonExpect = generateAnswer();

		String jsonActual = WED_SurveyConfirmCC.settingJsonSurveyAnswer(leadSurvey);

		System.assertEquals(jsonExpect, jsonActual);
	}
	
}