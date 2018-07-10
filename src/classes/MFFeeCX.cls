public with sharing class MFFeeCX {
	public List<MF_Reimbursement_Detail__c> mfDetailList { get; set; }
	public List<MF_Traffic_Fee_Detail__c> mfTrafficDetailList { get; set; }
    public String prefixUrl { get; set; }
	private ApexPages.StandardController stdController;  
    public MFFeeCX(ApexPages.StandardController stdController) {    
        this.stdController = stdController; 
        //system.currentPageReference().getParameters().put('Id', 'a0GN000000AW5F2');
        prefixUrl = 'https://' + ApexPages.currentPage().getHeaders().get('Host');
        MF_Fee__c cont = (MF_Fee__c)stdController.getRecord();

        mfDetailList = [SELECT Id, MF_Fee__c, Name, Payment_Content__c, Payment_Date__c, Price__c, Receipt_Image__c, Title__c, Account__r.Name, Remark__c FROM MF_Reimbursement_Detail__c WHERE MF_Fee__c=:cont.Id];

        mfTrafficDetailList = [SELECT Arrive__c, Depart__c, Id, MF_Fee__c, Name, Payment_Date__c, Price__c, Receipt_Image__c, Remark__c, Transportation_Vehicle__c, Account__r.Name From MF_Traffic_Fee_Detail__c WHERE MF_Fee__c=:cont.Id];
    }

}