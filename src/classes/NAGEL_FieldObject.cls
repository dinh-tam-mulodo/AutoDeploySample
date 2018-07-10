public with sharing class NAGEL_FieldObject {
    public class FieldException extends Exception{}
    private String ObjectNm='';
    public NAGEL_FieldObject(String ObjNm, String FdNm) {
        ObjectNm=ObjNm;
        FieldNm=FdNm;
        Schema.DescribeFieldResult field = NAGEL_SchemaCache.fieldDescribe(ObjectNm, FdNm);
        if(field == null) {
            throw new FieldException('Field with name ' + FdNm + ' does not exist in sobject ' + ObjectNm);
        }
        /*
        if(!field.isAccessible()) {
            throw new FieldException('Field with name ' + FdNm + ' is not accessible for current user');
        }*/
        Piclist=new Map<String,String>();
        Updateable=field.isUpdateable();
        Label=field.getLabel();
        IsPicList=false;
        if(field.getType()==Schema.DisplayType.Picklist){
            IsPicList=true;
            List<Schema.PicklistEntry> pics= field.getPicklistValues();
            for(Schema.PicklistEntry pic:pics){
                Piclist.put(pic.getValue(),pic.getLabel());
            }
             Piclist.put('','--None--');
        }
        IsRelationShip=false;
        FieldRelationShipNm=field.getRelationshipName();
        if(FieldRelationShipNm!=null){
            IsRelationShip=true;
            Updateable=false;
            
        }
    }
    public Boolean IsRelationShip
    {
        get;
        set;
    }
    public string FieldRelationShipNm{
        get;
        set;
    }
    public String Label{
        get;
        set;
    }
    public String FieldNm{
        get;
        set;
    }
    public Boolean Updateable{
        get;
        set;
    }
    public Boolean IsPicList{
        get;
        set;
    }
    public Map<String,String> Piclist{
        get;
        set;
    }

}