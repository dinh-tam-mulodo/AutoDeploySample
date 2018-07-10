public with sharing class REC_AccountCC {

    // private ApexPages.StandardController controller = null;

    public Account acc = null;
    public String accountName { get; set; }
    public List<Account> accountList { get; set; }
    public Id accountId { get; set; }
    public Integer test { get; set; }
    public Id parentId { get; set; }

    // 項目変更対象外項目セット（SFの標準項目等）
    //private Set<String> exceptSet = new Set<String>{'Id', 'CreatedDate', 'CreatedById', 'LastModifiedDate', 'LastModifiedById', 'IsDeleted', 'OwnerId' };

    //private final List<String> STATUS_LIST = new List<String>{'Creating','Rejected','Submitted','Accepted','Processing'};
    private ApexPages.StandardController controller = null;

    //private CMN_SFDCFieldUtil fieldUtil = new CMN_SFDCFieldUtil(new List<String>{'Account'}, true);


    public REC_AccountCC(ApexPages.StandardController ctrl){
        try {
            parentId = null;
            if (null!=System.currentPageReference().getParameters().get('parentId')){
                parentId = System.currentPageReference().getParameters().get('parentId');
                //super.set
            }           
            acc = (Account)ctrl.getRecord();
            accountId = acc.Id;           
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '#### ' + e.getMessage()));
        }

    }

    public PageReference editExt() {
       PageReference pr = new PageReference('/apex/VoxerMDM__PRM_PortalAccountEdit');

       if (parentId != null){
            pr.getParameters().put('parentId', parentId);
       }
       return pr;

    }

    






}