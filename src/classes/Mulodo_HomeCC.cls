/**
 *   Author create: nguyen.hoc@mulodo.com
 *   Create Date: 2018/03/12
 *   Author update:
 *   Update Date: 2018/04/27
 *   Class Mulodo_HomeCC
 *   Description: get content of page and sub page for display
 */
public class Mulodo_HomeCC {
    public String content {get;set;}
    public String param {get;set;}
    public String allinactivePName {get; set;}
    public static String curPath {get; set;}
    public String curBaseUrl {get;set;}
    public Boolean isPreviewContent {get; set;}
    public Boolean isUserLogin {get;set;}

    public Mulodo_HomeCC() {
        curPath = curPath();
        allinactivePName = inactivePages();
        curBaseUrl = curBaseUrl();
        isPreviewContent = isPreviewContent();
        isUserLogin = isUserLogin();
    }

    /*Get all Inactive page from Page__c*/
    public String inactivePages() {
        String allinactivePName = '';

        for (Page__c pi : [SELECT Name FROM Page__c WHERE Flag__c = false]) {
            String pName = pi.Name;
            pName = pName.replaceAll(' ', '-');
            allinactivePName = pName + ':' + allinactivePName;
            allinactivePName = allinactivePName.toLowerCase();
        }

        return allinactivePName;
    }

    /**
     * Get content for Home Page and replace all link in content to match links in static resource
     */
    public PageReference doInit() {
        param = ApexPages.currentPage().getParameters().get('param');
		//if param of url is blank then set param is Home
        if (String.isBlank(param)) {
            param = 'home';
        }

        // replace - to  ' ' for seaching text from db ex: mulodo group
        if (param.indexOf('-') > -1) {
            param = param.replace('-', ' ');
        }
            
		// get content of main page need display
        List<Page__c> p = [SELECT Content__c, Flag__c FROM Page__c WHERE Group__c =:param AND Sub_Group__c ='' LIMIT 1];
        //if list page is empty then return null
        if (p.isEmpty()) {
            return null;
        }

        content = p[0].Content__c;
        String staticResourceUrl = '';

        //replace content with the right path from static resource
        staticResourceUrl = PageReference.forResource('MulodoMainPage').getUrl();
        content = replaceContent(content, staticResourceUrl, param.toLowerCase());

        //incase get content from preview page
        content = getPreviewPageContent(content, p[0].Flag__c);

        return null;
    }

    /**
     * replace all link to match static resource link in content
     */
    public string replaceContent(String content, String myUrl, String param) {
        param = '/' + param + '/';
        Integer index = myUrl.indexOf('?');
        myUrl = index == -1 ? myUrl : myUrl.subString(0, index);

        //replace url on homepage
        String myUrlHome =  myUrl + '/assets/';
        content = content.replaceAll('/assets/', myUrlHome);

        // replace url on subpage
        if (!param.equals('/home/')) {
            String myUrlPg =  myUrl + param;
            content = content.replaceAll(param, myUrlPg);
        }

        //replace url on admin ex: apex/mulodo_about
        if (isUserLogin) {
            content = content.replaceAll('mulodoSite/', curPath + '/mulodo_');
        }

        // replace all class of pages which Flag__c = false by class hideContent
        for(String inactiveSinglePage : allinactivePName.split(':')) {
            content = content.replaceAll(inactiveSinglePage + '-hidden', 'hideContent');
        }

        return content;
    }

    /**
     * Common function to get data from current subpage replace all link in content to match links in static resource
     */
    public PageReference doInitSubPageCommon() {
        String currentPage = Apexpages.currentPage().getUrl();
        String mainPage = currentPage.substring('/apex/mulodo_'.length()).toLowerCase();

        if (currentPage.indexOf('?') > -1) {
           mainPage = currentPage.substring('/apex/mulodo_'.length(), currentPage.indexOf('?')).toLowerCase();
        }

        //transfer mainpage to visual page
        param = mainPage;
        String subPage = ApexPages.currentPage().getParameters().get('param');
        String pageName = ApexPages.currentPage().getParameters().get('name');

        if (!String.isBlank(subPage) && subPage.indexOf('-') > -1) {
            subPage = subPage.replace('-', ' ');
        }

        //get content with mainpage and subpage condition
        List<Page__c> p = [SELECT Content__c, Flag__C FROM Page__c WHERE Group__c =:mainPage AND Sub_Group__c =:subPage LIMIT 1];

        if (!String.isBlank(pageName)) {
            if (pageName.indexOf('-') > -1) {
                pageName = pageName.replace('-', ' ');
            }

            // get content of page have sub page and name need display
            p = [SELECT Content__c, Flag__C FROM Page__c WHERE Group__c =:mainPage AND Sub_Group__c =:subPage AND  Name =:pageName LIMIT 1];
        }
        //if list page is empty then return null
        if (p.isEmpty()) {
            return null;
        }
        //set content values
        content = p[0].Content__c;
        content = replaceContent(content, PageReference.forResource('MulodoSubPage').getUrl(), mainPage);

        if (isPreviewContent()) {
            content = content.replaceAll('hideContent', '');
        }

        //get content from preview page
        content = getPreviewPageContent(content, p[0].Flag__c);

        return null;
    }

    /**
     * get Current Path (admin|Site)
     */
    public static string curPath(){
        curPath = 'apex';

        if(!isUserLogin()) {
            curPath = 'mulodoSite';
        } 

        return curPath;
    }

    /**
     * check user Login
     */
    public static Boolean isUserLogin(){
        Boolean isLoged = false;
        if(UserInfo.getUserId() != null && UserInfo.getSessionId() != null) {
            isLoged = true;
        }

        return isLoged;
    }

    /**
     * check preview content allow
     */
    public Boolean isPreviewContent() {
        Boolean isPreviewContent = false;
        String preview = ApexPages.currentPage().getParameters().get('preview');

        // check preview is visible and user is login
        if ((!String.isBlank(preview) && preview.equals('true')) || isUserLogin()) {
            isPreviewContent = true;
        }

        return isPreviewContent;
    }

    // get current base url
    public String curBaseUrl() {
        return System.URL.getSalesforceBaseUrl().toExternalForm();
    }

    //get preview page content
    public String getPreviewPageContent(String content, Boolean flagC){
        // Check page which Flag__c = false and replace current content by content of alert page
        if (!isPreviewContent() && !flagC) { 
            content = [SELECT Content__c FROM Page__c WHERE Group__c = 'Home' AND name = 'Preview Alert' LIMIT 1].Content__c;
        } 

        return content;
    }
}