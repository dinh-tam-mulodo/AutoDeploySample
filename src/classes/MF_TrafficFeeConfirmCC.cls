/*
* MF_TrafficFeeConfirmCC
* Show traffic fee list by id
* Submit to approval traffic receipt
*/
public class MF_TrafficFeeConfirmCC {
    public List<MF_Traffic_Fee_Detail__c> trafficReceiptList{get;set;}
    public String name{get;set;}
    public String employeeNo{get;set;}
    public String totalFee{get;set;}
    public Boolean viewPDF{get;set;}
    public String idMfFeeToSubmit{get;set;}
    public Datetime createdDate{get;set;}
    public String feeStatus{get;set;}
    public Boolean displayAlertSuccess{get;set;}
    public Boolean displayAlertFail{get;set;}

    public MF_TrafficFeeConfirmCC(){
        displayAlertSuccess = false;
        displayAlertFail = false;
    }
    public PageReference mapJsonToObject(){
        String idMfFee = ApexPages.currentPage().getParameters().get('id');
        //view case
        if (idMfFee != null) {
            System.debug(idMfFee);
            idMfFeeToSubmit = idMfFee;
            viewTrafficFeeConfirmWithMfFeeId(idMfFee);
            if (ApexPages.currentPage().getParameters().get('view') == 'pdf'){
               viewPDF = true;
            } else {
               viewPDF = false; 
            }
            return null;
        } else {
            return saveTrafficFeeList();
        }
    }
    /**
    * viewTrafficFeeConfirmWithMfFeeId
    * VIEW traffic fee list by mfFEE id
    */
    private void viewTrafficFeeConfirmWithMfFeeId(String idMfFee){
        List<MF_Fee__c> mfFee = [select Amount__c, Contact__c, CreatedDate, Fee_Status__c from MF_Fee__c where id=:idMfFee and Fee_Type__c = 'Traffic'];
        if (mfFee.size() > 0) {
            totalFee =  String.valueOf(mfFee.get(0).Amount__c);
            List<Contact> contacts = [select EmployeeNo__c, Name from Contact where id=:mfFee.get(0).Contact__c];
            name = contacts.get(0).name;
            employeeNo = contacts.get(0).EmployeeNo__c;
            createdDate = mfFee.get(0).CreatedDate;
            feeStatus = mfFee.get(0).Fee_Status__c;
            trafficReceiptList = [select Payment_Date__c, Depart__c, Arrive__c, Transportation_Vehicle__c, Price__c, Remark__c, Receipt_Image__c, Account__r.Name from MF_Traffic_Fee_Detail__c where MF_Fee__c=:idMfFee];
        }
    }
    /**
    * saveTrafficFeeList
    * save with parameter from VFP test
    */
    private PageReference saveTrafficFeeList(){
        trafficReceiptList = new List<MF_Traffic_Fee_Detail__c>();
        name = ApexPages.currentPage().getParameters().get('employee-name');
        employeeNo = ApexPages.currentPage().getParameters().get('employee-no');
        totalFee = ApexPages.currentPage().getParameters().get('total-price');
        Map<String, Object> priceReceiptMap = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list-price'));
        Map<String, Object> arriveMap = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list-arrive'));
        Map<String, Object> paymentDateMap = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list-payment-date'));
        Map<String, Object> departMap = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list-depart'));
        Map<String, Object> remarkMap = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list-remark'));
        Map<String, Object> accountMap = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list_account'));
        Map<String, Object> vehicleMap = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list-vehicle'));
        List<Object> imageMap = (List<Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list-image'));
        List<Object> imageNameList = (List<Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('list-image-name'));  
        for (Integer i = 0; i < priceReceiptMap.size(); i++){
            MF_Traffic_Fee_Detail__c trafficFee = new MF_Traffic_Fee_Detail__c();
            String dateString = (String) paymentDateMap.get(String.valueOf(i));
            trafficFee.Payment_Date__c = Date.newInstance(Integer.valueOf(dateString.substring(0, 4)),Integer.valueOf(dateString.substring(5, 7)),Integer.valueOf(dateString.substring(8, 10)));
            //System.debug(dateString);
            trafficFee.Depart__c = (String) departMap.get(String.valueOf(i));
            trafficFee.Arrive__c = (String) arriveMap.get(String.valueOf(i));
            trafficFee.Transportation_Vehicle__c = (String) vehicleMap.get(String.valueOf(i));
            
            trafficFee.Price__c = (Integer) priceReceiptMap.get(String.valueOf(i));
            trafficFee.Account__c = (String) accountMap.get(String.valueOf(i));
            trafficFee.Remark__c = (String) remarkMap.get(String.valueOf(i));
            trafficReceiptList.add(trafficFee);
        }
        //save to DB
        List<Contact> contacts = [select id, MF_Approver__c from Contact where EmployeeNo__c=:employeeNo];
        if (contacts.size() > 0){
            //create savepoint
            Savepoint sp = Database.setSavepoint();
            try {
                MF_Fee__c mfFee = new MF_Fee__c();
                mfFee.Amount__c = Double.valueOf(totalFee);
                mfFee.Contact__c = contacts.get(0).id;
                mfFee.Fee_Type__c = 'Traffic';
                mfFee.Fee_Status__c = '';
                mfFee.Approver__c = contacts.get(0).MF_Approver__c;
                insert mfFee;
                // assign id value recored just inserted into MF_Fee__c
                idMfFeeToSubmit = mfFee.Id;
                createdDate = System.now();
                //insert traffic fee
                for(MF_Traffic_Fee_Detail__c trafficFee: trafficReceiptList){
                    trafficFee.MF_Fee__c = mfFee.Id;
                }
                insert trafficReceiptList;
                
                //save image
                List<Attachment> attachmentList = new List<Attachment>();
                for (Integer i = 0; i < imageMap.size(); i++) {
                    if (imageMap.get(i) != null) {
                        Attachment objA = new Attachment();
                        objA.body = EncodingUtil.base64Decode(String.valueOf(imageMap.get(i))) ;
                        objA.name = String.valueOf(imageNameList.get(i));
                        objA.parentid= trafficReceiptList.get(i).id;
                        objA.ContentType = 'application/jpg';
                        attachmentList.add(objA); 
                    }
                }
                //insert attachmentList
                insert attachmentList;
                //update trafficReceiptList
                for (Integer i = 0; i < attachmentList.size(); i++){
                    string Attid = attachmentList.get(i).id;
                    string attachmentid = Attid.substring(0,15);
                    trafficReceiptList.get(i).Receipt_Image__c = '/servlet/servlet.FileDownload?file=' + attachmentid;
                }
                update trafficReceiptList;
                Set<Id> trafficId = new Set<Id>();
                for(MF_Traffic_Fee_Detail__c trafficFee: trafficReceiptList){
                    trafficId.add(trafficFee.Id);
                }
                trafficReceiptList = [SELECT Id, Name, Account__r.Name, Transportation_Vehicle__c,Payment_Date__c,Depart__c, Arrive__c,Price__c, Receipt_Image__c, Remark__c FROM MF_Traffic_Fee_Detail__c WHERE Id IN :trafficId];
                ApexPages.currentPage().getParameters().put('id', mfFee.Id);
                return null;

            } catch(System.DmlException e){
                Database.rollback(sp);
                PageReference redirectPage = Page.MF_TrafficFeePage;
                redirectPage.getParameters().put('hasError','true');
                return redirectPage;
            }
        }
        return null;
    }
    /***
     * getApproveReceipt
     **/
    public void getApproveReceipt(){
        List<MF_Fee__c> mfFeeList = [select id from MF_Fee__c where id=:idMfFeeToSubmit];
        if (mfFeeList.size() > 0){
            mfFeeList.get(0).Fee_Status__c = 'Pending';
            try{
                update mfFeeList.get(0); 
                displayAlertSuccess = true;      
            } catch(DmlException e){ 
                displayAlertFail = true;
            } 
        }
        viewTrafficFeeConfirmWithMfFeeId(idMfFeeToSubmit);
    }
}