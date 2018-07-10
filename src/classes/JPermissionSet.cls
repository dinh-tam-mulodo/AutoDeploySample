/* Tuan 29/08/17
   Wrapper Class */
public with sharing class JPermissionSet {
	public Boolean selected{get; set;}
	public String id {get;set;}
    public string label {get;set;}
    public String name{get; set;}
    public String description{get; set;}        
       
    public JPermissionSet(Tools_calloutJSONPermissionSets.JSONPermissionSet obj, String selectedPermissionSets) {
     	id = obj.Id;
        name = obj.name;
        label = obj.label;
        description = obj.description;
        Set<String> permissionSets = new Set<String>();
        if(selectedPermissionSets != null){
            for(String str : selectedPermissionSets.split(';')){
                permissionSets.add(str);
            }                 
        }
        if (permissionSets != null && permissionSets.contains(obj.id)) {
            selected = true;
        } else {
            selected = false;
        }
    }
}