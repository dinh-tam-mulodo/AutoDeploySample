public class MF_DummyDataMaker {
    public static final String COMPANY_NAME = 'Mulodo VN';
    public static final String BRANCH_NAME = 'Mulodo Branch';
    public static final String DEPARTMENT_NAME = 'Department Name';
    public static final String DEPARTMENT_DESCRIPTION = 'Department description';
    public static final String DEPARTMENT_NAME_2 = 'Department Name 2';
    public static final String DEPARTMENT_DESCRIPTION_2 = 'Department description 2';
    public static final String COMPANY_NAME_2 = 'Mulodo VN 2';
    public static final String CONTACT_EMAIL = 'superman_testing@mulodo.com';
    public static final String CONTACT_FIRSTNAME = 'red';
    public static final String CONTACT_LASTNAME = 'underwear';
	public static String CONTACT_ID = '';    
	public static void createDummyData(){
        MF_Company__c company = new MF_Company__c();
        company.Name = COMPANY_NAME;
        insert company;

        MF_Branch__c branch = new MF_Branch__c();
        branch.Name = BRANCH_NAME;
        branch.MF_Company__c = company.Id;
        insert branch;

        MF_Department__c dept = new MF_Department__c();
        dept.Name = DEPARTMENT_NAME;
        dept.MF_Branch__c = branch.Id;
        dept.Description__c = DEPARTMENT_DESCRIPTION;
        insert dept;

        MF_Department__c cdept = new MF_Department__c();
        cdept.Name = DEPARTMENT_NAME_2;
        cdept.MF_Branch__c = branch.Id;
        cdept.ParentId__c = dept.Id;
        cdept.Description__c = DEPARTMENT_DESCRIPTION_2;
        insert cdept;

        company.Name = COMPANY_NAME_2;
        Account acct = new Account();
        acct.Name = 'internal';
        acct.Phone = '0909333333';
        acct.Website = 'www.google.com.vn';
        insert acct;
  
        Contact cont = new Contact();
        cont.FirstName = CONTACT_FIRSTNAME ;
        cont.LastName = CONTACT_LASTNAME;
        cont.Username__c = CONTACT_EMAIL;
        cont.AccountId = acct.Id;
        cont.Phone = '09091111111';
        cont.Email = CONTACT_EMAIL;
        cont.MF_Department__c = dept.Id;
        insert cont;
        CONTACT_ID = cont.id;

        MF_Question__c question1 = new MF_Question__c();
        question1.Question_Text__c = 'Where are you now?';
        question1.IsDisplay__c = true;
        insert question1;

        MF_Question__c question2 = new MF_Question__c();
        question2.Question_Text__c = 'How are you?';
        question2.IsDisplay__c = true;
        insert question2;

        MF_Choice__c choice1 = new MF_Choice__c();
        choice1.MF_Question__c = question1.Id;
        choice1.Choice_Value__c = 'Home';
        insert choice1;

        MF_Choice__c choice2 = new MF_Choice__c();
        choice2.MF_Question__c = question2.Id;
        choice2.Choice_Value__c = 'Fine';
        insert choice2;

        MF_Response__c response1 = new MF_Response__c();
        response1.MF_Question__c = question1.Id;
        response1.Response_Text__c = choice1.Choice_Value__c;
        response1.Contact__c = cont.Id;
        insert response1;

        MF_Response__c response2 = new MF_Response__c();
        response2.MF_Question__c = question2.Id;
        response2.Response_Text__c = choice2.Choice_Value__c;
        response2.Contact__c = cont.Id;
        insert response2;
    }

    public static void createDummyDataForExternal(){

    }

    /**
     * Helper method to create Account standard object records
     * 
     * @param Integer numToCreate: This parameter orders which amount of records should be created and inserted
     * 
     * @returns List<Account>: Created and inserted list of Account standard object records
     */
    public static List<Account> createAccounts(Integer numToCreate) {
        List<Account> listToReturn = new List<Account>();
        for ( Integer i = 0; i < numToCreate; i++ ) {
            listToReturn.add( new Account( Name = 'Account ' + i ) );
        }
        insert listToReturn;
        return listToReturn;
    }


    /**
     * Helper method to create Contact standard object records
     * 
     * @param Account account: This parameter supplies a single master record to populate on all the children
     * @param Integer numToCreate: This parameter controls how many Contact standard object records should be created
     * @param Boolean doInsert: This parameter commands if created data should be inserted here
     * 
     * @returns static List<Contact>: Created and inserted list of Contact standard object records
     */
     public static List<Contact> createContacts( Account account, Integer numToCreate, Boolean doInsert ) {
        Contact contact = new Contact(
                    FirstName = 'Parent',
                    LastName = 'Contact',
                    AccountId = account.Id,
                    Contact_Type__c = 'Internal'
                    );
        insert contact;
        List<Contact> listToReturn = new List<Contact>();
        for ( Integer i = 0; i < numToCreate; i++ ) {
            listToReturn.add(
                new Contact(
                    FirstName = 'John' + i,
                    LastName = 'Doe' + i,
                    AccountId = account.Id,
                    Created_By_Contact__c = contact.Id,
                    Contact_Type__c = 'External',
                    Company_Name__c = 'Mulodo'
                    )
                );
        }
        if (doInsert)
            insert listToReturn;
        return listToReturn;
    }

    /**
     * Helper method to create MF_Display__c object records
     */
    public static void createMFDisplay() {
        MF_Display__c display = new MF_Display__c();
        display.Object_Name__c = 'Contact';
        display.Display_Field__c = 'Id, Name';
        insert display;
    }
}