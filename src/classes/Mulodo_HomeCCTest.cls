/**
 *   Author create: tran.binh@mulodo.com
 *   Create Date: 2018/03/14
 *   Author update:
 *   Update Date: 
 *   Class Mulodo_HomeCCTest
 *   Description: Test for class Mulodo_HomeCC
 */
@isTest
private class Mulodo_HomeCCTest {
     /**
     * test case when List Page Empty for Mulodo_HomeCC test
     */
    @isTest static void testInitWhenListPageEmpty() {
        //set paramater for url
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        PageReference result = home.doInit();
        system.assertEquals(null, result);
    }
    
    /**
     * test case Init With Page Home for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageHome() {
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'Home');
        //create data for page home
        Page__c page = new Page__c(
        	Content__c = 'content home test',
            Group__c = 'Home',
            Sub_Group__c = ''
        );
        insert page;
        home.doInit();
        system.assertEquals('content home test', home.content);
    }
    
    /**
     * test case Init With Page About for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageAbout() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_About'); 
        Test.setCurrentPage(pageRef); 
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'about');
        home.doInitSubPageCommon();
        //create data for page about
        Page__c page = new Page__c(
        	Content__c = 'content about test',
            Group__c = 'about',
            Sub_Group__c = ''
        );
        insert page;
        
        home.doInit();
        system.assertEquals('content about test', home.content);
    }
    
    /**
     * test case Init With Page About And Sub Page for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageAboutAndSubPage() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_About?param=company'); 
        Test.setCurrentPage(pageRef); 
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param', 'company');
        //create data for page home
        Page__c page = new Page__c(
        	Content__c = 'content about test',
            Group__c = 'about',
            Sub_Group__c = 'company'
        );
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content about test', home.content);
    }
    
        /**
     * test case Init With Page inquiry for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageInquiry() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_Inquiry'); 
        Test.setCurrentPage(pageRef); 
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'inquiry');
        //create data for page inquiry
        Page__c page = new Page__c(
        	Content__c = 'content inquiry test',
            Group__c = 'inquiry',
            Sub_Group__c = ''
        );
        
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content inquiry test', home.content);
    }
    
    /**
     * test case Init With Page PrivacyPolicy for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPagePrivacyPolicy() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_PrivacyPolicy'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'privacy_policy');
        //create data for page privacy policy
        Page__c page = new Page__c(
        	Content__c = 'content privacy policy test',
            Group__c = 'privacy_policy',
            Sub_Group__c = ''
        );
        
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content privacy policy test', home.content);
    }
    
    /**
     * test case Init With Page SiteMap for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageSiteMap() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_SiteMap'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'sitemap');
        //create data for page sitemap
        Page__c page = new Page__c(
        	Content__c = 'content sitemap test',
            Group__c = 'sitemap',
            Sub_Group__c = ''
        );
        
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content sitemap test', home.content);
    }
    
    /**
     * test case Init With Page Recruit for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageRecruit() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_Recruit'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'recruit');
        //create data for page recruit
        Page__c page = new Page__c(
        	Content__c = 'content recruit test',
            Group__c = 'recruit',
            Sub_Group__c = ''
        );
        insert page;
        
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content recruit test', home.content);
    }
    
    /**
     * test case Init With Page Recruit And Sub Page for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageRecruitAndSubPage() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_Recruit?param=CEO Message'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'CEO Message');
        //create data for page recruit
        Page__c page = new Page__c(
        	Content__c = 'content recruit test',
            Group__c = 'recruit',
            Sub_Group__c = 'CEO Message'
        );
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content recruit test', home.content);
    }
    
    /**
     * test case Init With Page Team for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageTeam() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_Team'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'team');
        //create data for page team
        Page__c page = new Page__c(
        	Content__c = 'content team test',
            Group__c = 'team',
            Sub_Group__c = ''
        );
        
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content team test', home.content);
    }
    
    /**
     * test case Init With Page Service for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageService() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_Service'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'service');
        //create data for page service
        Page__c page = new Page__c(
        	Content__c = 'content service test',
            Group__c = 'service',
            Sub_Group__c = ''
        );
        
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content service test', home.content);
    }
    
    /**
     * test case Init With Page Project for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageProject() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_Project'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'project');
        //create data for page project
        Page__c page = new Page__c(
        	Content__c = 'content project test',
            Group__c = 'project',
            Sub_Group__c = ''
        );
        
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content project test', home.content);
    }
    
    /**
     * test case Init With Page Voice for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageVoice() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_Voice'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'voice');
        //create data for page voice
        Page__c page = new Page__c(
        	Content__c = 'content voice test',
            Group__c = 'voice',
            Sub_Group__c = ''
        );
        
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content voice test', home.content);
    }
    
    /**
     * test case Init With Page Voice And Sub Page for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageVoiceAndSubPage() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_Voice?param=client&name=Recochoku Inari'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'client');
        ApexPages.currentpage().getparameters().put('name' , 'Recochoku Inari');
        //create data for page Recochoku Inari
        Page__c page = new Page__c(
        	Content__c = 'content voice of Recochoku Inari test',
            Group__c = 'voice',
            Sub_Group__c = 'client',
            Name = 'Recochoku Inari'
        );
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content voice of Recochoku Inari test', home.content);
    }
    
    /**
     * test case Init With Page News for Mulodo_HomeCC test
     */
    @isTest static void testInitWithPageNews() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_News'); 
        Test.setCurrentPage(pageRef);
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'news');
        //create data for page news
        Page__c page = new Page__c(
        	Content__c = 'content news test',
            Group__c = 'news',
            Sub_Group__c = ''
        );
        
        insert page;
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content news test', home.content);
    }
	
    /**
     * test case Flag Is False
     */
    @isTest static void testFlagIsFalse() {
        //set url for page
        PageReference pageRef = new PageReference('/apex/Mulodo_News'); 
        Test.setCurrentPage(pageRef);
        
        //set paramater for url
        ApexPages.currentpage().getparameters().put('param' , 'news');
        //create data for page news
        Page__c page = new Page__c(
        	Content__c = 'content news test',
            Group__c = 'news',
            Sub_Group__c = '',
            Flag__c = false
        );
        
        insert page;
        
        //initialization class Mulodo_HomeCC
        Mulodo_HomeCC home = new Mulodo_HomeCC();
        home.doInitSubPageCommon();
        home.doInit();
        system.assertEquals('content news test', home.content);
    }
}