global with sharing class MF_FeeDetailsObject {
    public MF_FeeDetailsObject() {

    }
    public MF_Fee__c master;
    public Contact contact;
    public List <MF_Reimbursement_Detail__c> detail;
}