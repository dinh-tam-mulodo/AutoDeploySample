@isTest
private class NAGEL_FieldObjectTest {
    static final String EXISTING_SOBJECT = 'Contact';
    static final String NOT_EXISTING_SOBJECT = 'object_not_existed';
    static final String EXISTING_FIELD = 'Phone';
    static final String NOT_EXISTING_FIELD = 'field_not_existed';
    /**
    * verify object not existed
    */
    @isTest static void testObjectNotExisted()
    {
        NAGEL_FieldObject objt=null;
        try
        {
            objt=new NAGEL_FieldObject(EXISTING_SOBJECT,NOT_EXISTING_FIELD);
            System.assertEquals(null, objt);
            

        }catch(Exception ex)
        {
            System.assertEquals(null, objt);
        }
        

    }
    /**
    * verify info obejct 
    */
    @isTest static void checkInforObject(){
        NAGEL_FieldObject objt=new NAGEL_FieldObject(EXISTING_SOBJECT,EXISTING_FIELD);
        System.assertEquals(true, objt.Updateable);
        System.assertEquals(false, objt.IsRelationShip);
        System.assertEquals(null, objt.FieldRelationShipNm);
        System.assertEquals(false, objt.IsPicList);

    }
}