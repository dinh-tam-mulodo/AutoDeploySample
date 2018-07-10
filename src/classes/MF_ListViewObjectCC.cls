global with sharing class MF_ListViewObjectCC extends MF_UserAuthentication {
    global string ckContactId{get;set;}
    global String sName {get;set;}

    global MF_ListViewObjectCC() {
        //Set user cookie to ckContactId  
        ckContactId = cookieContactId;
        if(ApexPages.currentPage().getParameters().get('sname') != null)
        {
        	sName = ApexPages.currentPage().getParameters().get('sname').Capitalize();      	
        }
        else 
        {
        	sName = '';
        }
    }

    /**
     * Get list external SObject
     * @param  Json string have condition to search,sort,pagination
     * @return List SObject
     */
    @RemoteAction
    global static MF_ListSObject getListExternalContact(string condition, String sName) {
    	Set<String> dspSet = getDisplayFields(sName); //get field is displayed from DB

        //Add default display field if not any field is selected
        if(dspSet.size() == 0)
            dspSet.add('Name'.toLowerCase());
        List<String> fieldResult = new List<String>();
        fieldResult.addAll(dspSet);
        String fieldListStr = String.join(fieldResult, ',');
        return getListExternalContactWithField(condition, fieldListStr, sName);
    }

    /**
     * Get list external SObject
     * @param  condition Json string have condition to search,sort,pagination
     * @param  fieldList List of field want to get
     * @return           List SObject have SObject type is external
     */
    private static MF_ListSObject getListExternalContactWithField(string condition, String fieldList, String sName) {
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
                            + 'FROM ' + String.escapeSingleQuotes(sName);

        soqlList =   'SELECT ' + String.escapeSingleQuotes(fieldList) + ' FROM ' + String.escapeSingleQuotes(sName);
        //System.debug(soqlList);
        soqlCondition = '';
        if (String.isNotBlank(cond.whereCond)) {
            soqlCondition += ' Where ' + cond.whereCond;
        }
        if(String.isNotBlank(cond.sortBy) && String.isNotBlank(cond.sortOrder)){
            soqlOrder = ' ORDER BY ' + cond.sortBy + ' ' + cond.sortOrder;
        }

        if (String.isNotBlank(String.valueOf(cond.currentPage)) && String.isNotBlank(String.valueOf(cond.perPage))){
            Integer offsetPage = (cond.currentPage*cond.perPage) - cond.perPage;
            soqlLimit = ' LIMIT ' + cond.perPage + ' OFFSET ' + offsetPage;
        }

        try {	
	        //Get total records
	        Integer total = Database.countQuery(soqlCount + soqlCondition);

	        //Get list SObject with condition paging
	        List<SObject> contactList = Database.Query(soqlList + soqlCondition + soqlOrder + soqlLimit);
	        MF_ListSObject result = new MF_ListSObject();
	        result.total = total;
	        result.externalList = contactList;
	        return result;
        } catch(Exception e) {
        	System.debug(e.getMessage());
        }
        return new MF_ListSObject();
    }

    /**
     * Mass delete SObject by Id list
     */
    @RemoteAction
    global static Integer massDeleteRecords(List<String> recordsList, String sName) 
    {
    	try { 		
    		String sqlQuery = 'SELECT ID FROM '+ String.escapeSingleQuotes(sName) + ' Where ID IN:recordsList';
    		List<SObject> deleteList =  Database.Query(sqlQuery);
    		delete deleteList;
    		return deleteList.size();
    	} catch(Exception e) {
    		System.debug(e.getMessage());
    	}
    	return 0;
    }

    /**
     * Get all fields of SObject
     */
    @RemoteAction
    global static List<FieldDisplayObject> getListFields(String sName) {
        Set<String> dspSet = getDisplayFields(sName); //get field is displayed from DB
        //Add default display field if not any field is selected
        if(dspSet.size() == 0)
            dspSet.add('Name'.toLowerCase());

        //Get all standard & custom field of SObject
        List<FieldDisplayObject> dspLst =  new list<FieldDisplayObject>();
        try {
        	Map<String, Schema.SObjectField> fsMap = Schema.getGlobalDescribe().get(sName).getDescribe().fields.getMap();
        	for (String fieldName: fsMap.keySet()) {
        		FieldDisplayObject dspObj = new FieldDisplayObject();
        		dspObj.apiName = fieldName;
        		dspObj.labelName = fsMap.get(fieldName).getDescribe().getLabel();
        		dspObj.fieldType = fsMap.get(fieldName).getDescribe().getType().name();
        		dspObj.pickVal = fsMap.get(fieldName).getDescribe().getPicklistValues();
        		if(dspSet.contains(fieldName.toLowerCase())){
        			dspObj.isDisplayed = true;
        			dspObj.indexOrder = FindIndexOfSet(dspSet, fieldName.toLowerCase());
        		}
        		else {
        			dspObj.isDisplayed = false;
        		}
        		dspLst.add(dspObj);
        	}
        } 
        catch(Exception e) {
        	System.debug(e.getMessage());
        }       
        return dspLst;
    }

    private static Integer FindIndexOfSet(Set<String> dspSet, String value){
    	List<String> dspList = new List<String>(dspSet);
    	System.debug(dspSet +' :inFindIndexOfSet');
    	System.debug(dspList+' :inFindIndexOfSet');
    	for(Integer i = 0; i < dspList.size(); i++){
    		if(value == dspList[i])
    			return i;
    	}
    	return -1;
    }

    /**
     * Get display fields of SObject in MF_Display__c
     * @param  sName Name of SObject
     */
    @RemoteAction
    global static Set<String> getDisplayFields(String sName){
        List<String> fieldList = new List<String>();
        Set<String> fieldSet = new Set<String>();
        try {
        	String objName = Schema.getGlobalDescribe().get(sName).getDescribe().getName();
        	List<MF_Display__c> dspList = [Select Display_Field__c From MF_Display__c Where Object_Name__c =:objName];
        	if(dspList.size() > 0){
        		MF_Display__c dsp = dspList[0];
        		fieldList = dsp.Display_Field__c.toLowerCase().split(',');
        	}
        	fieldSet.addAll(fieldList);   
        } 
        catch(Exception e) {
        	System.debug(e.getMessage());
        }
        return fieldSet;
    }

    /**
     * Save all fields u want to display to database
     */
    //@RemoteAction
    //global static void saveDisplayFields(List<String> fieldList, String sName) {
    //    for(Schema.SobjectField strFld: Schema.getGlobalDescribe().get(sName).getDescribe().fields.getMap().Values())
    //    {
    //        if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE)
    //        {
    //            system.debug('==parent object='+strFld.getDescribe().getLabel()+ ' : ' + strFld.getDescribe().getReferenceTo());
    //        } 
    //    }
    //}

    /**
     * Save all fields u want to display to database and get external SObject list with displayed field
     */
    @RemoteAction
    global static MF_ListSObject saveDisplayFieldsAndGetExternalContact(String condition, List<String> fieldList, String sName) {
        System.debug(condition);
        System.debug(fieldList);
        //Remove duplicate value
        Set<String> fieldSet = new Set<String>();
        List<String> fieldResult = new List<String>();
        fieldSet.addAll(fieldList);
        fieldResult.addAll(fieldSet);

        //Add default display field if not any field is selected
        if(fieldResult.size() == 0) {
            fieldResult.add('Name'.toLowerCase());
        }
        MF_ListSObject result = new MF_ListSObject();
        try {
        	//Save to DB
        	String objName = Schema.getGlobalDescribe().get(sName).getDescribe().getName();
        	MF_Display__c dsp = new MF_Display__c();
        	dsp.Object_Name__c = objName;
        	dsp.Display_Field__c = String.join(fieldResult, ',');
        	upsert dsp Object_Name__c;
        	result = getListExternalContactWithField(condition, String.join(fieldResult, ','), sName);	
        } 
        catch(Exception e) {
        	System.debug(e.getMessage());
        }
        return result;
        
    }

}