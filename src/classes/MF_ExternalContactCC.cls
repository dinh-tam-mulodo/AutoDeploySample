global with sharing class MF_ExternalContactCC extends MF_UserAuthentication {
    global string ckContactId{get;set;}

    global MF_ExternalContactCC() {
        //Set user cookie to ckContactId  
        ckContactId = cookieContactId;
    }

    /**
     * Get list internal contact 
     * @return List contact have contact type is internal
     */
	@RemoteAction
    global static List<Contact> getListInternalContact() {
        return [SELECT Id, Name FROM Contact WHERE Contact_Type__c = 'Internal'];
    }

    /**
     * Get list external contact
     * @param  Json string have condition to search,sort,pagination
     * @return List contact have contact type is external
     */
    @RemoteAction
    global static MF_ListSObject getListExternalContact(string condition) {
        String fieldList = 'Id, Account.Name, Name, MF_Department__r.MF_Branch__r.MF_Company__r.Name, Phone, Email, Comment__c, Chatter__c, Business_Card__c, CreatedDate, Created_By_Contact__r.Name,Tag__c ';
        return getListExternalContactWithField(condition, fieldList);
    }

    /**
     * Get list external contact
     * @param  condition Json string have condition to search,sort,pagination
     * @param  fieldList List of field want to get
     * @return           List contact have contact type is external
     */
    private static MF_ListSObject getListExternalContactWithField(string condition, String fieldList) {
        String soqlCount = '';
        String soqlList = '';
        String soqlCondition = '';
        String soqlOrder = '';
        String soqlLimit = '';

        //Parse Json to object MF_ExternalContactSearchObject
        MF_ExternalContactSearchObject cond = new MF_ExternalContactSearchObject();
        try {           
            cond = (MF_ExternalContactSearchObject) JSON.deserialize(condition, MF_ExternalContactSearchObject.class);
        } catch(Exception e) {
            return null;
        }

        //Build query
        soqlCount =  'SELECT count() '
                            + 'FROM Contact '
                            + 'WHERE Contact_Type__c = \'External\'';

        soqlList =   'SELECT ' + String.escapeSingleQuotes(fieldList) + ' FROM Contact '
                        + 'WHERE Contact_Type__c = \'External\'';

        soqlCondition = '';
        if (String.isNotBlank(cond.contactId)) {
            soqlCondition += ' AND Created_By_Contact__c = \'' + cond.contactId + '\'';
        }
        if (String.isNotBlank(cond.fullname)) {
            soqlCondition += ' AND Name LIKE \'%' + String.escapeSingleQuotes(cond.fullname) + '%\'';
        }
        if (String.isNotBlank(cond.comp)) {
            soqlCondition += ' AND Account.Name LIKE \'%' + String.escapeSingleQuotes(cond.comp) + '%\'';
        }
        if(String.isNotBlank(cond.sortBy) && String.isNotBlank(cond.sortOrder)){
            soqlOrder = ' ORDER BY ' + cond.sortBy + ' ' + cond.sortOrder;
        }

        if (String.isNotBlank(String.valueOf(cond.currentPage)) && String.isNotBlank(String.valueOf(cond.perPage))){
            Integer offsetPage = (cond.currentPage*cond.perPage) - cond.perPage;
            soqlLimit = ' LIMIT ' + cond.perPage + ' OFFSET ' + offsetPage;
        }

        //Get total records
        Integer total = Database.countQuery(soqlCount + soqlCondition);

        //Get list contact with condition paging
        List<Contact> contactList = Database.Query(soqlList + soqlCondition + soqlOrder + soqlLimit);
        MF_ListSObject result = new MF_ListSObject();
        result.total = total;
        result.externalList = contactList;
        return result;
    }

}