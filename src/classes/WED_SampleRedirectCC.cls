global without sharing class WED_SampleRedirectCC {
    private WED_Sample_Object__c wed_obj;

	public WED_SampleRedirectCC(ApexPages.StandardController stdController) {
        //String idParameter = ApexPages.currentPage().getParameters().get('id');
        String idParameter = stdController.getId();
        //this.wed_obj = (WED_Sample_Object__c)stdController.getRecord();
        this.wed_obj = [SELECT Id, Age__c, Home_Town__c FROM WED_Sample_Object__c
                       WHERE Id =:idParameter];
        System.debug('aaaaaaa: ' + wed_obj);
    }

    public String getGreeting() {
        return 'Hello ' + wed_obj.Age__c + ',' + wed_obj.Home_Town__c + ' (' + wed_obj.id + ')';
    }
}