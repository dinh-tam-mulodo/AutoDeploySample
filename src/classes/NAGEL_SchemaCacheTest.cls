@isTest
private class NAGEL_SchemaCacheTest {
    static final String EXISTING_SOBJECT = 'Contact';
    static final String NOT_EXISTING_SOBJECT = 'object_not_existed';
    static final String EXISTING_FIELD = 'Phone';
    static final String NOT_EXISTING_FIELD = 'field_not_existed';
     /**
     * Verify that Object describe from cache is the sames as from API
     */
    @isTest static void testObjectInfoForExistingObject() {
        // Setup
        Schema.SObjectType fromApex = Schema.getGlobalDescribe().get(EXISTING_SOBJECT);
        
        // Exercise
        Schema.SObjectType fromCache = NAGEL_SchemaCache.object(EXISTING_SOBJECT);
        
        // Verify
        System.assertEquals(fromApex, fromCache);
        
    }
     /**
     * Verify that null is returned for not existing object
     */
    @isTest static  void testObjectInfoForNotExistingObject() {
        // Exercise
        Schema.SObjectType fromCache = NAGEL_SchemaCache.object(NOT_EXISTING_SOBJECT);
        
        // Verify
        System.assertEquals(null, fromCache);
    }

     /**
     * Verify that field describes from cache are the same as from API
     */
    @isTest static void testGetFieldsOfExistingObject() {
        // Setup
        Map<String, Schema.SObjectField> fromApex = Schema.getGlobalDescribe().get(EXISTING_SOBJECT).getDescribe().fields.getMap();
        
        // Exercise
        Map<String, Schema.SObjectField> fromCache = NAGEL_SchemaCache.fields(EXISTING_SOBJECT);
        
        // Verify
        System.assertEquals(fromApex.size(), fromCache.size());
        
        for(String fieldName : fromApex.keySet()) {
            System.assertEquals(fromApex.get(fieldName), fromCache.get(fieldName));
        }
    }
     
    
     /**
     * Verify that null is returned when field list contains non existing field
     */
    @isTest static  void testGetFieldsOfNotExistingObject() {
        
        // Exercise
        Map<String, Schema.SObjectField> fromCache = NAGEL_SchemaCache.fields(NOT_EXISTING_SOBJECT);
        
        // Verify
        System.assertEquals(null, fromCache);
    }
    /**
     * Verify that field info and describe from cache equals the one requested from the API
     */
     @isTest static void testGetFieldInfoOfExistingField() {
        // Setup
        Schema.SObjectField infoFromApex = Schema.getGlobalDescribe().get(EXISTING_SOBJECT).getDescribe().fields.getMap().get(EXISTING_FIELD);
        Schema.DescribeFieldResult describeFromApex = Schema.getGlobalDescribe().get(EXISTING_SOBJECT).getDescribe().fields.getMap().get(EXISTING_FIELD).getDescribe();
        
        // Exercise
        Schema.SObjectField infoFromCache = NAGEL_SchemaCache.field(EXISTING_SOBJECT, EXISTING_FIELD);
        Schema.DescribeFieldResult describeFromCache = NAGEL_SchemaCache.fieldDescribe(EXISTING_SOBJECT, EXISTING_FIELD);
        
        // Verify
        System.assertEquals(infoFromApex, infoFromCache);
        System.assertEquals(describeFromApex, describeFromCache);
    }
    
    /**
     * Verify that null is returned for field info and describe when non existing field
     */
    @isTest static void testGetFieldInfoOfNotExistingField() {
        // Exercise
        Schema.SObjectField infoFromCache = NAGEL_SchemaCache.field(EXISTING_SOBJECT, NOT_EXISTING_FIELD);
        Schema.DescribeFieldResult describeFromCache = NAGEL_SchemaCache.fieldDescribe(EXISTING_SOBJECT, NOT_EXISTING_FIELD);
        
        // Verify
        System.assertEquals(null, infoFromCache);
        System.assertEquals(null, describeFromCache);
    }
    /**
     *   Verify object from cached 
    */
    @isTest static void  testobjectDescribeExsting()
    {
       Schema.DescribesObjectResult fromCache= NAGEL_SchemaCache.objectDescribe(EXISTING_SOBJECT);
       Schema.DescribesObjectResult describeFromApex = Schema.getGlobalDescribe().get(EXISTING_SOBJECT).getDescribe();
        System.assertEquals(fromCache, describeFromApex);

    }
    /**
    * Verify field from cached
    */
    @isTest static void testfieldDescribesExisting()
    {
        // Exercise
         Schema.DescribeFieldResult fromCache = NAGEL_SchemaCache.fieldDescribe(EXISTING_SOBJECT, EXISTING_FIELD);
         Schema.DescribeFieldResult describeFromApex=Schema.getGlobalDescribe().get(EXISTING_SOBJECT).getDescribe().Fields.getMap().get(EXISTING_FIELD).getDescribe();
         System.assertEquals(fromCache, describeFromApex);
    }
    /**
    * Verifu field from cache
    */
    /*
    @isTest static void testfieldDescribesMap()
    {

        Map<String, Schema.DescribeFieldResult>  fromCache=NAGEL_SchemaCache.fieldDescribesMap(EXISTING_SOBJECT);
        System.assertEquals(true, fromCache.containsKey(EXISTING_FIELD)); 

    }*/
   
    
}