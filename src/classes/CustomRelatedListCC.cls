public with sharing class CustomRelatedListCC {
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews = 
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Contact'];
         // Perform isAccessible() check here
        return listviews;
    }
    @AuraEnabled
    public static DataWrapper getData(String objectName,Id parentId,String parentField,String fields,Integer offset,Integer defaultSize){    
    String queryTotal = 'Select count() From ' + String.escapeSingleQuotes(objectName) + ' where '+ String.escapeSingleQuotes(parentField) +' = \'' + String.escapeSingleQuotes(parentId) + '\'';
    String queryData = 'SELECT '+String.escapeSingleQuotes(fields)+' FROM '+String.escapeSingleQuotes(objectName) +' where '+String.escapeSingleQuotes(parentField)+' = \'' + String.escapeSingleQuotes(parentId) + '\' limit '+ defaultSize +' offset '+ offset;  
    system.debug(queryData) ;
    // create a instance of wrapper class.
    List<SObject> objects = Database.query(queryData);  
    DataWrapper obj =  new DataWrapper();
    // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
    obj.pageSize = defaultSize;
    //obj.page = page;
    obj.total = Database.countQuery(queryTotal);
    obj.records = objects;
    obj.showLabels = getObjectLabels(objectName,fields);
    obj.objectIcon = getObjectIcon(objectName);
    List<String> dspFields = new List<String>();
    
    for(String f: fields.split(',')){
        dspFields.add(f);
    }    
    obj.showFields = dspFields;
    // return the wrapper class instance .
    return obj;
}

@AuraEnabled
public static String saveMulipleChecked(String[] checkedIds){
    System.debug(checkedIds);
    return 'OK';
}

@AuraEnabled
public static DataWrapper fetchAllData(String objectName,String fields,Decimal pageNumber) {

    String queryTotal = 'Select count() From ' + String.escapeSingleQuotes(objectName);
    Integer total = Database.countQuery(queryTotal);
    String queryData = 'SELECT  ' + String.escapeSingleQuotes(fields) + ' FROM ' + String.escapeSingleQuotes(objectName) + ' LIMIT ' + total + ' OFFSET 0';  
    system.debug('queryTotal:' + queryTotal);
    system.debug('queryData:' + queryData);
    // create a instance of wrapper class.
    List<SObject> objects = Database.query(queryData);    
    DataWrapper obj =  new DataWrapper();
    // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
    
    obj.page = (Integer) pageNumber;
    obj.total = total;
    obj.pageSize = total;
    obj.records = objects;    
    List<String> dspFields = new List<String>();
    for(String f: fields.split(',')){ 
        dspFields.add(f);
      /*  if(f!='Id'){
           
        }*/
    }
    obj.showFields = dspFields;
    // return the wrapper class instance .
    return obj;
}
@AuraEnabled
public static DataWrapper deleteRecord(String objectName,Id parentId,String parentField,String fields,Integer offset,Integer defaultSize,String recordId){
     DataWrapper data =  new DataWrapper();
    List<String> params = new List<String>{String.escapeSingleQuotes(objectName),'\''+String.escapeSingleQuotes(recordId)+'\''};
    String query = String.format('Select Id From {0} Where Id = {1}', params);
    system.debug(query);
    sObject obj = Database.query(query);
    Database.DeleteResult rs = Database.Delete(obj,false);
    if(rs.isSuccess()){
        String queryTotal = 'Select count() From ' + String.escapeSingleQuotes(objectName) + ' where '+ String.escapeSingleQuotes(parentField) +' = \'' + String.escapeSingleQuotes(parentId) + '\'';
        String queryData = 'SELECT '+String.escapeSingleQuotes(fields)+' FROM '+String.escapeSingleQuotes(objectName) +' where '+String.escapeSingleQuotes(parentField)+' = \'' + String.escapeSingleQuotes(parentId) + '\' limit '+ defaultSize +' offset '+ offset;  
    
        // create a instance of wrapper class.
        List<SObject> objects = Database.query(queryData);  
        system.debug(objects) ; 
       
        // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
        data.pageSize = defaultSize;
        //obj.page = page;
        data.total = Database.countQuery(queryTotal);
        data.records = objects;
        data.showLabels = getObjectLabels(objectName,fields);
        data.objectIcon = getObjectIcon(objectName);
        system.debug(data.objectIcon)    ;
        List<String> dspFields = new List<String>();    
        for(String f: fields.split(',')){
            dspFields.add(f);
          /*  if(f!='Id'){
               
            }*/
        }    
        data.showFields = dspFields;
    }

    return data;
}
@AuraEnabled
public static DataWrapper deleteSelected(String objectName,Id parentId,String parentField,String fields,Integer offset,Integer defaultSize,List<String> recordIds){
     DataWrapper data =  new DataWrapper();
     system.debug(recordIds);    
    String lstRecords = '';
    for(String str: recordIds){
        lstRecords+= !String.isNotEmpty(lstRecords) ? '\''+String.escapeSingleQuotes(str)+'\'' : ',\''+String.escapeSingleQuotes(str)+'\'';
    }
    List<String> params = new List<String>{objectName,lstRecords};
    String query = String.format('Select Id From {0} Where Id in ({1})', params);
    system.debug(query);
    List<sObject> objs = Database.query(query);
    Database.DeleteResult[] rs = Database.Delete(objs,false);
    if(rs[0].isSuccess()){
        String queryTotal = 'Select count() From ' + String.escapeSingleQuotes(objectName) + ' where '+ String.escapeSingleQuotes(parentField) +' = \'' + String.escapeSingleQuotes(parentId) + '\'';
        String queryData = 'SELECT '+String.escapeSingleQuotes(fields)+' FROM '+String.escapeSingleQuotes(objectName) +' where '+String.escapeSingleQuotes(parentField)+' = \'' + String.escapeSingleQuotes(parentId) + '\' limit '+ defaultSize +' offset '+ offset;  

        // create a instance of wrapper class.
        List<SObject> objects = Database.query(queryData);  
        system.debug(objects) ; 
       
        // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
        data.pageSize = defaultSize;
        //obj.page = page;
        data.total = Database.countQuery(queryTotal);
        data.records = objects;
        data.showLabels = getObjectLabels(objectName,fields);
        data.objectIcon = getObjectIcon(objectName);        
        List<String> dspFields = new List<String>();    
        for(String f: fields.split(',')){
            dspFields.add(f);
              /*  if(f!='Id'){
                   
                }*/
        }    
        data.showFields = dspFields;
    }

    return data;
}
/*==================== PRIVATE METHOD =================*/
private static List<String> getObjectLabels(String objectName,String fields){
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType objSchema = schemaMap.get(objectName);
    Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
    List<String> labels = new List<String>();
    for(String f: fields.toLowerCase().split(',')){
        for (String fieldName: fieldMap.keySet()) {
            if(fieldName==f){
                String label = fieldMap.get(fieldName).getDescribe().getLabel();
                labels.add(label);
                break;
            }
        }
    }
    return labels;
}
private static String getObjectIcon(String objectName){
    List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
    List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
    String icon = '';
    for(DescribeTabSetResult tsr : tabSetDesc) {
        List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
        for(Schema.DescribeTabResult tr : tabDesc) {
            if(tr.getSobjectName() == objectName){
                iconDesc.addAll(tr.getIcons());
                break;                
            }
        }        
        for (Schema.DescribeIconResult ir : iconDesc) {
            //system.debug(ir);
            if (ir.getContentType() == 'image/svg+xml'){
                icon = ir.getUrl();
                break;
            }
        } // end for DescribeIconResult
        if(String.isNotBlank(icon)){
            Integer s = icon.indexOf('/custom/') + '/custom/'.length(),
            e = icon.length() - 4;
            icon = icon.substring(s, e);
            break;
        }
    } // end for DescribeTabSetResult
    return icon;
}

 // create a wrapper class with @AuraEnabled Properties    
 public class DataWrapper {
    @AuraEnabled public String objectIcon {get;set;}
    @AuraEnabled public Integer pageSize {get;set;}
    @AuraEnabled public Integer page {get;set;}
    @AuraEnabled public Integer total {get;set;}
    @AuraEnabled public List<Object> records {get;set;}
    @AuraEnabled public List<String> showFields {get;set;}
    @AuraEnabled public List<String> showLabels {get;set;}
}
}