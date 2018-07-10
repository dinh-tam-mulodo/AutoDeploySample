public with sharing class Tools_calloutJSONPermissionObjects {
	
	public boolean hasError;
	public String status;
	public String error;
    public String error_description;
	public Integer totalSize {get;set;} 
	public Boolean done {get;set;} 
	public List<Records> records {get;set;}

	public class Parent {
		public Attributes attributes {get;set;} 
		public String ProfileId {get;set;}
	}
	
	public class Attributes {
		public String type_Z {get;set;} // in json: type
		public String url {get;set;}
	}
	
	public class Records {
		public Attributes attributes {get;set;} 
		public String Id {get;set;} 
		public String ParentId {get;set;} 
		public String SobjectType {get;set;} 
		public Boolean PermissionsRead {get;set;} 
		public Boolean PermissionsCreate {get;set;} 
		public Boolean PermissionsEdit {get;set;} 
		public Boolean PermissionsDelete {get;set;} 
		public Boolean PermissionsViewAllRecords {get;set;} 
		public Boolean PermissionsModifyAllRecords {get;set;} 
		public Parent Parent {get;set;}
	}

	public class FieldPermissions {
		
	}
}