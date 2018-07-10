/**
 *   Author create: tran.binh@mulodo.com
 *   Create Date: 2018/03/14
 *   Author update:
 *   Update Date:
 *   Class Mulodo_HomeCCTest
 *   Description: Test for class Mulodo_HomeCC
 */
@isTest
private class Mulodo_ListPageCCTest {
    
    /**
     * test case setup list page for Mulodo Site
     */
	@testSetup static void dataFactory() {
		//create data for page home
        List<Page__c> pageList = new List<Page__c>();
			pageList.add(new Page__c(
				Content__c = 'content home test',
                Group__c = 'Home',
                Sub_Group__c = '',
                Flag__c = true
			));
        
        	pageList.add(new Page__c(
				Content__c = 'content about test',
                Group__c = 'About',
                Sub_Group__c = ''
			));
		insert pageList;
	}
    
    /**
     * test case when List Page for Mulodo_ListPageCC test
     */
    @isTest static void testInitWhenListPage() {
        Mulodo_ListPageCC listPage = new Mulodo_ListPageCC();
        
        system.assertEquals(2, listPage.pages.size());
    }
    
    /**
     * test case save information flag for Mulodo_ListPageCC test
     */
    @isTest static void testSave() {
        //initialization class Mulodo_ListPageCC
        Mulodo_ListPageCC listPage = new Mulodo_ListPageCC();
        //set paramater for url
        ApexPages.currentpage().getHeaders().put('Host' , 'mulodoSite');
        //create data for page home
        Page__c page = new Page__c(
        	Content__c = 'content home test',
            Group__c = 'Home',
            Sub_Group__c = '',
            Flag__c = true
        );
        PageReference result = listPage.save();
        system.assertEquals('System.PageReference[https://mulodoSite/apex/Mulodo_ListPage]', String.valueOf(result));
    }

    /**
     * test case for initPage
     */
    @isTest static void testInitPage() {
       Mulodo_ListPageCC listPage = new Mulodo_ListPageCC();
        
       system.assertEquals(1, listPage.pages.size());
    }

    /**
     * test case for getPageUrl
     */
    @isTest static void testGetPageURL() {
       Mulodo_ListPageCC listPage = new Mulodo_ListPageCC();
        //set paramater for url
        ApexPages.currentpage().getHeaders().put('Host' , 'mulodoSite');
        //create data for page home
        Page__c page = new Page__c(
            Content__c = 'content home test',
            Group__c = 'Home',
            Sub_Group__c = '',
            Flag__c = true
        );
        PageReference result = listPage.save();
        system.assertEquals('System.PageReference[https://mulodoSite/apex/Mulodo_ListPage]', String.valueOf(result));
    }

    /*
     * Test fir get disable previous
     */
    @isTest static void testGetDisablePrevious() {
       Mulodo_ListPageCC listPage = new Mulodo_ListPageCC();
       listPage.count = 1;
        
       system.assertEquals(true, listPage.getDisablePrevious());
    }
}