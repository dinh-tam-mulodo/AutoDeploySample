/**
 *   Author create: nguyen.hoc@mulodo.com
 *   Create Date: 2018/03/22
 *   Author update:
 *   Update Date: 2018/03/28
 *   Class Mulodo_ListPageCC
 *   Description: Display list page of Mulodo Site to screen.
 */
public with sharing class Mulodo_ListPageCC{
    public final Integer LIST_SIZE_PAGE = 10;
    
    public Integer totalRecord { get; set; }
    public List<Page__c> pages {get; set;}
    public Map<String,String> previewList{get; set;}
    public Integer count { get; set; }
    public Integer totalSize { get; set; }
    public String action { get; set; }
    // custom size of list per mulodoSite will be changed be user
    public Integer customListSize { get; set; }
    public String curPath {get{return Mulodo_HomeCC.curPath();} set;}
    public Boolean isUserLogin{get{return Mulodo_HomeCC.isUserLogin();} set;}

	/**
     * function init for get list page display
     */
    public Mulodo_ListPageCC(){
        pages = initPages();
    }

    //get init pages
    public List<Page__c> initPages(){
        totalSize      = [SELECT count() FROM Page__c WHERE Flag__c = false];
        count          = 0;
        customListSize = LIST_SIZE_PAGE;

        //select all page with first conditions
        pages = [SELECT Name, Group__c, Sub_Group__c, Flag__c FROM Page__c WHERE Flag__c = false LIMIT:customListSize OFFSET: count];       
        previewList = previewList(pages);

        return pages;
    }
    
	/**
     * function save information of flag when change values of flag.
     */
    public PageReference save(){
        try{
            update pages;
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }

        //init pages
        pages = initPages();

        return null;
    }

    /**
     * Result when click button First, Previous, Next, End
     */
     public PageReference selectAction () {
        //get paramater from apex with action click
        String action = Apexpages.currentPage().getParameters().get('paramValue');

        if(action == 'First') {
            count = 0;
        } else if(action == 'Previous') {
            count -= customListSize;
        } else if(action == 'Next') {
            count += customListSize;
        } else if(action == 'End') {
            Integer mod = math.mod( totalSize, customListSize );
            count = mod != 0 ? totalSize - mod : totalSize - customListSize;
        }

        //get all pages match conditions
        pages =  [SELECT Name, Group__c, Sub_Group__c, Flag__c FROM Page__c WHERE Flag__c = false LIMIT: customListSize OFFSET: count];
        previewList = previewList(pages);

        return null;
    }

    /**
     * This will disable the previous and first buttons
     */
    public Boolean getDisablePrevious () {
        return count > 0 ? false : true;
    }

    /**
     * This will disable the next and end buttons
     */
    public Boolean getDisableNext () {
        if ( count + customListSize < totalSize ) {
            return false;
        }
            return true;
    }

    /**
     * This will get current page
     */
    public Integer getCurrentPage () {
        if( totalSize == 0 ){
            return 0;
        }

        return count / customListSize + 1;
    }

    /**
     * This will get total record
     */
    public Integer getTotalRecord () {
        return totalSize;
    }

    /**
     * This will get total page
     */
    public Integer getTotalPage () {
        if( totalSize == 0){
            return 0;
        } else if( customListSize >= totalSize ) {
            return 1;
        } else if( math.mod( totalSize, customListSize ) != 0) {
            return totalSize / customListSize + 1;
        }
        
        return totalSize / customListSize;
    }

    //return preview link
    public Map<String, String> previewList(List<Page__c> pages) {
        String previewP = '';
        Map<String, String> previewList = new Map<String, String>();

        for(Page__c p : pages) {
            previewP = p.Group__c;

            if (p.Sub_Group__c != null) {
                previewP += '?param='+p.Sub_Group__c;
            }

            if (p.name!=p.Group__c&&p.name!=p.Sub_Group__c&&p.name!=null&&p.Sub_Group__c != null) {
                previewP += '&name='+p.name;
            }
            previewP = previewP.toLowerCase().replaceAll(' ', '-');
            previewList.put(p.Id, previewP);
        }

        return previewList;
    }
}