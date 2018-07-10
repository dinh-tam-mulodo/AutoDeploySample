global with sharing class NAGEL_AjaxRelatedComponentController {
  public class ApplicationException extends Exception{}
  //private final static String LIMIT_ROWS=10000;
  
  public String ParentId
  {
    get;set;
  }
  public  string ObjectName
  {
    get;
    set;
  }
  public string FieldsName{
    get;
    set;
  }
  public List<NAGEL_FieldObject> FieldsList
  {
    get;
    private set;
  }
  public String JsonField{
    get;
    set;
  }
  

  // Url New Object
  public String urlNewObject {
    get
    {
    
      String typePrefix = NAGEL_SchemaCache.objectDescribe(ObjectName).getKeyPrefix();
      return '/' + typePrefix + '/e?retURL='+ParentId+'&saveURL='+ParentId+'&cancelURL='+ParentId;
    }
  }
  
  // URL View List
  public PageReference urlViewDetail
  {
    get
    {
      String typePrefix = NAGEL_SchemaCache.objectDescribe(ObjectName).getKeyPrefix();
      PageReference page = new PageReference('/' + typePrefix + '/o');
      return page;
    }
    
  }
  // Init param
  public void getInit()
  {
    try{
      ObjectName=ObjectName.replace(' ','');
      FieldsName=FieldsName.replace(' ','');
      // Check Type object and access
      Schema.DescribeSObjectResult type = NAGEL_SchemaCache.objectDescribe(ObjectName);
      if(type==null){
        throw new ApplicationException('SObject with name ' + ObjectName + ' does not exist.');
      }
      /*
      if(!type.isAccessible()) {
        throw new ApplicationException('SObject with name ' + ObjectName + ' is not accessible for current user.');
      }*/
      FieldsList=new List<NAGEL_FieldObject>();
      // Check Field type and access
      List<String> fields=FieldsName.split(',');
      NAGEL_FieldObject fobj=null;
      for(String str:fields){
        fobj=new NAGEL_FieldObject(ObjectName,str);
        FieldsList.add(fobj);
      }
      JsonField=JSON.serialize(FieldsList);
    }
    catch(Exception ex){
      ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.FATAL, 'Error');
      ApexPages.addMessage(message);
    }
  }
  
  /*
    Delete all
  */
  @remoteAction
  global static String deleteAll(string ids,String objectName)
  {
    string sql='';
    try
    {
      String []vals=ids.split(',');
      sql='SELECT Id FROM '+ String.escapeSingleQuotes(objectName)+' WHERE Id in:vals';
      List<SObject> l=Database.query(sql);
      if(l.size()>0){
        delete l;
        
      }
      return 'success';
    }catch(Exception ex)
    {
      return ex.getMessage();
    }
  }
  /*
    Save Chanege
  */
  @remoteAction
  global static String saveChange(String FieldName,String Ids,String jsonInput,String typeParam)
  {
    string sql='';
    try
    {
      List<String> vals=Ids.split(',');
      List<String> FieldsList=FieldName.split(',');
      List<Object> sources =(List<Object>)JSON.deserializeUntyped(jsonInput);
      //Map<String,Object> objs=null;
    
      List<SObject> sobj=Database.query('SELECT Id FROM '+ String.escapeSingleQuotes(typeParam)+' WHERE Id in:vals');
        if(vals.size()==0||sources==null||sources.size()==0||sobj==null||sobj.size()==0){
          throw new ApplicationException('Upate faile');
        }
      for(Object source:sources){
        Map<String,Object> objs=(Map<String,Object>)source;
        for(SObject o:sobj){

          if((String)objs.get('id')==(String)o.get('id')){
            for(String fil:FieldsList){
              Schema.DescribeFieldResult field = NAGEL_SchemaCache.fieldDescribe(typeParam,fil);
              if(field.isUpdateable()){
                  if(field.getType()==Schema.DisplayType.Picklist){
                    List<Schema.PicklistEntry> pics= field.getPicklistValues();
                    Boolean check=false;
                  for(Schema.PicklistEntry pic:pics){
                    if(objs.get(fil)==pic.getValue()){
                      check=true;
                      break;
                    }
                  }
                  if(check){
                    o.put(fil,objs.get(fil));
                  }else{
                    o.put(fil,null);
                  }
                      
                  }else{
                    o.put(fil,objs.get(fil));
                  }
                
              }
            }
          }
        }
      }
      update sobj;
      return 'success';
    }catch(Exception ex)
    {
      return ex.getMessage();
    }
  }
  /*
  Get Rows
   */
  @remoteAction
  global static Map<String,Object> getRows(String jsonInput,String FieldsName,String ObjectName,String FilterParam,Integer lim, Integer off)
  {
     Map<String,Object> mResult=new Map<String,Object>();
    String sql='SELECT '+ FieldsName+' FROM '+ String.escapeSingleQuotes(ObjectName)+ ' WHERE '+FilterParam+' LIMIT :lim OFFSET :off';
    try
    {

        List<NAGEL_FieldObject> objs= (List<NAGEL_FieldObject>)JSON.deserialize(jsonInput, List<NAGEL_FieldObject>.class);
        if(objs!=null){
          for(NAGEL_FieldObject o:objs){
            if(o.IsRelationShip){
              FieldsName=FieldsName.replace(o.FieldNm,o.FieldRelationShipNm+'.Name');
            }
          }
        }
        sql='SELECT '+ FieldsName+' FROM '+ String.escapeSingleQuotes(ObjectName)+ ' WHERE '+FilterParam+' LIMIT :lim OFFSET :off';
        
        Integer count=Database.countQuery('SELECT COUNT() FROM '+ String.escapeSingleQuotes(ObjectName)+ ' WHERE '+FilterParam);
          List<SObject> ls=Database.query(sql);
          mResult.put('list', ls);
          mResult.put('total',count);

    }catch(Exception ex){
      mResult.put('list', new List<Object>());
        mResult.put('total',0);
        
    }
    return mResult;
}
}