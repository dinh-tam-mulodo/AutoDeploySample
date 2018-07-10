trigger WED_TokenGenarateTrigger on Lead (before insert, before update) {
	List<Lead> lstLead = new List<Lead>();
    for(Lead lead : Trigger.New) {
        if(String.isEmpty(lead.workSheetToken__c)) {
            Long randomizeNumber = Crypto.getRandomLong();
            String shasign = EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',Blob.valueOf(lead.Email + '' + lead.Phone + '' + date.today() + '' + randomizeNumber)));
            lead.workSheetToken__c = shasign;
        }
    }

}