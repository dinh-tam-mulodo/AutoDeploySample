/**
* @description: this class used to define functions for Internal Contact Page
* @author: vo.yen
**/
global with sharing class MF_InternalContactCC extends MF_UserAuthentication {
    public Contact loggedUser {get;set;}
    public MF_InternalContactCC() {
        String contactId = ApexPages.currentPage().getParameters().get('contactId');
        if(contactId != null){
            MF_CookieUtil.setCookieValue(MF_CookieUtil.COOKIE_CONTACT_ID, contactId, MF_CookieUtil.COOKIE_PATH, true);
        }
        System.debug(MF_UserAuthentication.cookieContactId);
        if (MF_UserAuthentication.cookieContactId != null){
          loggedUser = getInfoOfContact(MF_UserAuthentication.cookieContactId);  
          System.debug(loggedUser);
        }
    }
    @RemoteAction
    global static List<Contact> insertContact(String jsonString){
        List<Contact> contacts  = (List<Contact>) JSON.deserialize(jsonString, List<Contact>.class);
        return contacts;
    }


    /**
    * @description: get info logged contact
    * @author: vo.yen
    **/
    public static Contact getInfoOfContact(Id contactId)
    {
        Contact contactInfo = [ SELECT Id, Name, Contact_Type__c, MF_Department__r.MF_Branch__r.MF_Company__c
                                FROM Contact 
                                WHERE Id = :contactId
                               ];
        return contactInfo;
    }
    /**
    * @description: get all info about compay of logged contact: company name, branch, deparment
    * @author: vo.yen
    **/
    @RemoteAction
    global static List<MF_CompanysObject> getCompanyInfo(Id companyId)
    {
        List<MF_Company__c> CompanyList = [ SELECT Id, Name 
                                            FROM MF_Company__c
                                            WHERE Id = :companyId
                                            ];
        List<MF_Branch__c> branchList = [   SELECT Id, Name, MF_Company__c
                                            FROM MF_Branch__c
                                            WHERE MF_Company__c = :companyId
                                            ];

        Set <String> branchID = new Set <String>();
        for(MF_Branch__c branch : branchList){
            branchID.add(branch.Id);
        }

        List<MF_Department__c> depParentList = [   SELECT Id, Name, ParentId__c, MF_Branch__c
                                                FROM MF_Department__c
                                                WHERE MF_Branch__c IN :branchID
                                                AND ParentId__c = ''
                                            ];
        List<MF_Department__c> depChildList = [   SELECT Id, Name, ParentId__c, MF_Branch__c
                                                FROM MF_Department__c
                                                WHERE MF_Branch__c IN :branchID
                                                AND ParentId__c != ''
                                            ];

        List<MF_CompanysObject> companies = new List<MF_CompanysObject>();
        for(MF_Company__c company : CompanyList){
            MF_CompanysObject c = new MF_CompanysObject();
            c.Id = company.Id;
            c.Name = company.Name;
            List<MF_BranchsObject> branches = new List<MF_BranchsObject>();
            // assign data of branch of company
            for(MF_Branch__c branch : branchList){
                if (branch.MF_Company__c == company.Id) {
                    MF_BranchsObject b = new MF_BranchsObject();
                    b.Id = branch.Id;
                    b.Name = branch.Name;
                    List<MF_DeptsObject> mainDepts = new List<MF_DeptsObject>();
                    // assign department for branch
                    for(MF_Department__c dept : depParentList){
                        if (dept.MF_Branch__c == branch.Id) {
                            MF_DeptsObject d = new MF_DeptsObject();
                            d.Id = dept.Id;
                            d.Name = dept.Name;
                            List<MF_Department__c> childDepts = new List<MF_Department__c>();
                            // assign dept child of department
                            for(MF_Department__c child : depChildList){
                                if (child.ParentId__c == dept.Id) {
                                    MF_Department__c ch = new MF_Department__c();
                                    ch = child;
                                    childDepts.add(ch);
                                }
                            }
                            d.departmentChild = childDepts;
                            mainDepts.add(d);
                        }
                    }
                    b.department = mainDepts;
                    branches.add(b);
                }
            }
            c.branch = branches;
            companies.add(c);
        }
        return companies;
    }



    /**
    * @description: get list internal contact (include search function)
    * @author: vo.yen
    **/
    @RemoteAction
    global static MF_InternalContactListObject getListInternalContact(String condition) {
        MF_InternalContactSearchObject cond = (MF_InternalContactSearchObject) JSON.deserialize(condition, MF_InternalContactSearchObject.class);

        String soqlCount =  'SELECT count() '
                            + 'FROM Contact '
                            + 'WHERE Contact_Type__c = \'Internal\'';

        String soqlList =   'SELECT Id, Name, MF_Department__r.Name, Phone, Email,Description,Fax,HomePhone,MobilePhone,Birthdate,DoNotCall,OtherPhone,Title,LeadSource,AssistantName,AssistantPhone, Skype_Account__c, Comment__c, Chatter__c, EmployeeNo__c '
                        + 'FROM Contact '
                        + 'WHERE Contact_Type__c = \'Internal\'';

        String soqlCondition = '';
        if (cond.child != null) {
            soqlCondition += ' AND MF_Department__c = \'' + cond.child + '\'';
        }
        if (cond.dept != null) {
            soqlCondition += ' AND (MF_Department__c = \'' + cond.dept + '\'';
            soqlCondition += ' OR MF_Department__r.ParentId__c = \'' + cond.dept + '\')';
        }
        if (cond.branch != null) {
            soqlCondition += ' AND MF_Department__r.MF_Branch__c = \'' + cond.branch + '\'';
        }
        if (cond.company != null) {
            soqlCondition += ' AND MF_Department__r.MF_Branch__r.MF_Company__c = \'' + cond.company + '\'';
        }
        if (cond.kname != null && cond.kname != '') {
            soqlCondition += ' AND Name LIKE \'%' + String.escapeSingleQuotes(cond.kname) + '%\'';
        }
        if (cond.kdept != null && cond.kdept != '') {
            soqlCondition += ' AND MF_Department__r.Name LIKE \'%' + String.escapeSingleQuotes(cond.kdept) + '%\'';
        }
        if (cond.ktel != null && cond.ktel != '') {
            soqlCondition += ' AND Phone LIKE \'%' + String.escapeSingleQuotes(cond.ktel) + '%\'';
        }
        if (cond.kemail != null && cond.kemail != '') {
            soqlCondition += ' AND Email LIKE \'%' + String.escapeSingleQuotes(cond.kemail) + '%\'';
        }
        String soqlOrder = ' ORDER BY ' + cond.sortBy + ' ' + cond.sortOrder;

        Integer offsetPage = (cond.currentPage*cond.perPage) - cond.perPage;
        String soqlLimit = ' LIMIT ' + cond.perPage + ' OFFSET ' + offsetPage;

        Integer total = Database.countQuery(soqlCount + soqlCondition);

        List<Contact> contactList = Database.Query(soqlList + soqlCondition + soqlOrder + soqlLimit);
        Set <String> contactId = new Set <String>();
        for(Contact contact : contactList){
            contactId.add(contact.Id);
        }

        List<MF_Response__c> activities = [   SELECT Id, Name, Contact__c, Response_Text__c, MF_Question__r.Name, MF_Question__r.Question_Text__c
                                            FROM MF_Response__c
                                            WHERE Contact__c IN :contactId ORDER BY CreatedDate ASC
                                        ];
        List <MF_InternalContactsObject> internalList = new List<MF_InternalContactsObject>();
        for(Contact contact : contactList){
            MF_InternalContactsObject tmp = new MF_InternalContactsObject();
            tmp.Id = contact.Id;
            tmp.Name = contact.Name;
            tmp.DeptName = contact.MF_Department__r.Name;
            tmp.Phone = contact.Phone;
            tmp.Email = contact.Email;
            tmp.Comment = contact.Comment__c;
            tmp.Chatter = contact.Chatter__c;
            tmp.Skype_Account = contact.Skype_Account__c;
            tmp.EmployeeNo = contact.EmployeeNo__c;
            tmp.Description = contact.Description;
            tmp.Fax = contact.Fax;
            tmp.HomePhone = contact.HomePhone;
            tmp.MobilePhone = contact.MobilePhone;
            tmp.Birthdate =  contact.Birthdate;
            tmp.DoNotCall = contact.DoNotCall;
            tmp.OtherPhone = contact.OtherPhone;
            tmp.Title = contact.Title;
            tmp.LeadSource = contact.LeadSource;
            tmp.AssistantName = contact.AssistantName;
            tmp.AssistantPhone = contact.AssistantPhone;
            List<String> tmpResponse = new List<String>();
            String location;
            String feel;
            for(MF_Response__c activity : activities){
                if (activity.Contact__c == contact.Id) {
                    if (activity.MF_Question__r.Name == 'Q-0001' || activity.MF_Question__r.Question_Text__c == 'Where are you now?') {
                        location = activity.Response_Text__c;
                    } else {
                        feel = activity.Response_Text__c;
                    }
                }
            }
            tmpResponse.add(location);
            tmpResponse.add(feel);
            tmp.activity = tmpResponse;
            internalList.add(tmp);
        }
        MF_InternalContactListObject result = new MF_InternalContactListObject();
        result.total = total;
        result.internalList = internalList;
        return result;
    }
    /**
    * @description: set value of flag to require contact update profile
    * @author: vo.yen
    **/
    @RemoteAction
    global static Boolean requiredUpdateProfile(String condition) {
        MF_InternalContactSearchObject cond = (MF_InternalContactSearchObject) JSON.deserialize(condition, MF_InternalContactSearchObject.class);

        List <Contact> contactListForUpdate = [SELECT Id, Is_Required_Update__c FROM Contact WHERE Id IN :cond.contactId for update];
        for(Contact c : contactListForUpdate){
            c.Is_Required_Update__c = true;
        }
        update contactListForUpdate;
        return true;
    }
    /**
    * @description: get data detail of contact
    * @author: vo.yen
    **/
    @RemoteAction
    global static Contact getDetailContact(Id contactId) {
        Contact info = [SELECT Id, FirstName, LastName, Email, Contact_Type__c, Username__c, Birthdate, Address__c, Phone, Fax, MF_Department__r.Name, MF_Department__r.MF_Branch__r.Name,Skype_Account__c, Chatter__c, EmployeeNo__c, Chatter__r.Name FROM Contact WHERE Id = :contactId];
        return info;
    }
}