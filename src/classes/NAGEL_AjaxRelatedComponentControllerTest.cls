@isTest
private class NAGEL_AjaxRelatedComponentControllerTest {
	static final String EXISTING_SOBJECT = 'contact';
    static final String NOT_EXISTING_SOBJECT = 'object_not_existed';
    static final String FIELDS = 'Name,Phone,Fax';
 static final String JSONS_FIELD='[{"Updateable":false,"Piclist":{},"ObjectNm":"Contact","Label":"Full Name","IsRelationShip":false,"IsPicList":false,"FieldRelationShipNm":null,"FieldNm":"Name"},{"Updateable":true,"Piclist":{},"ObjectNm":"Contact","Label":"Business Phone","IsRelationShip":false,"IsPicList":false,"FieldRelationShipNm":null,"FieldNm":"Phone"},{"Updateable":true,"Piclist":{},"ObjectNm":"Contact","Label":"Business Fax","IsRelationShip":false,"IsPicList":false,"FieldRelationShipNm":null,"FieldNm":"Fax"}]';
	/*
	* Verify function init
	*/
	@isTest static void testGetInit(){
		
		NAGEL_AjaxRelatedComponentController comp=new NAGEL_AjaxRelatedComponentController();
		comp.ObjectName=EXISTING_SOBJECT;
		comp.FieldsName=FIELDS;
		comp.getInit();
		// verify size field
		System.assertEquals(3, comp.FieldsList.size());
		// verify url new object
		System.assertNotEquals(null,comp.urlNewObject);
		// verify url view object
		System.assertNotEquals(null,comp.urlViewDetail);
	}
	/*
	* Verify function object not existed
	*/
	@isTest static void testObjectNotExisted()
	{
		NAGEL_AjaxRelatedComponentController comp=null;
		try
		{
			 comp=new NAGEL_AjaxRelatedComponentController();
			comp.ObjectName=NOT_EXISTING_SOBJECT;
			comp.FieldsName=FIELDS;
			comp.getInit();
		}catch(Exception ex){
			// verify null object
			 System.assertEquals(null, comp.FieldsList);
		}
	}
	/*
	* Verify function get row
	*/
	@isTest static void testGetRows(){
		Account acc=new Account();
		acc.Name='Test Account';
		insert(acc);
		acc=[SELECT Id FROM Account Limit 1];
		String filter=acc.id;
		String a='AccountId=\''+acc.id+'\'';
		Contact ct=new Contact();
		ct.AccountId=acc.id;
		ct.Description='TEST';
		ct.FirstName='GAO';
		ct.LastName='Nagel';
		insert ct;
		Map<String,Object> resutl=NAGEL_AjaxRelatedComponentController.getRows(JSONS_FIELD,FIELDS,EXISTING_SOBJECT,a,10,0);
		System.assertEquals(1, resutl.get('total'));
		
	}
	/*
	* Verify exception get rows
	*/
	@isTest static void testGetRowsException(){
		Account acc=new Account();
		acc.Name='Test Account';
		insert(acc);
		acc=[SELECT Id FROM Account Limit 1];
		String filter=acc.id;
		String a='AccountId=\''+acc.id+'\'';
		Contact ct=new Contact();
		ct.AccountId=acc.id;
		ct.Description='TEST';
		ct.FirstName='GAO';
		ct.LastName='Nagel';
		insert ct;
		 Map<String,Object> resutl=NAGEL_AjaxRelatedComponentController.getRows(JSONS_FIELD,FIELDS,NOT_EXISTING_SOBJECT,a,10,0);
		 System.assertEquals(0, resutl.get('total'));
	
	}
}