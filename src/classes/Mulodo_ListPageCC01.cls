/**
 *   Author create: nguyen.hoc@mulodo.com
 *   Create Date: 2018/03/22
 *   Author update:
 *   Update Date:
 *   Class Mulodo_ListPageCC
 *   Description: Display list page of Mulodo Site to screen.
 */
public with sharing class Mulodo_ListPageCC01 {
    public List<Page__c> pagess {get; set;}
    public String subPatch {get; set;}
	/**
     * function init for get list page display
     */
    public Mulodo_ListPageCC01(){
        pagess = [SELECT Name, Group__c, Sub_Group__c, Flag__c FROM Page__c WHERE Flag__c = false LIMIT 200];
        if(UserInfo.getUserId() != null && UserInfo.getSessionId() != null) {
            subPatch = 'apex';
        } else {
            subPatch = 'mulodoSite';
        }
    }

	/**
     * function save information of flag when change values of flag.
     */
    public PageReference save(){
        try{
            update pagess;
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }

        return getPageURL();
    }

    /**
     * function get url of page
     */
    public PageReference getPageURL() {
        String hostVal  = ApexPages.currentPage().getHeaders().get('Host');

        if(UserInfo.getUserId() != null && UserInfo.getSessionId() != null) {
            subPatch = 'apex';
        } else {
            subPatch = 'mulodoSite';
        }

        String urll = 'https://' + hostVal + '/' + subPatch + '/Mulodo_ListPage01';
		system.debug(hostVal);
        PageReference pageRef = new PageReference(urll);
        pageRef.setRedirect(true);
		// return information of url
        return pageRef;
    }
}