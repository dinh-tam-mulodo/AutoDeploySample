public with sharing class Tools_calloutJSONPermissionSet {
	public boolean hasError;
	public String status;
	public String error;
    public String error_description;
    
	public Attributes attributes {get;set;} 
	public String Id {get;set;} 
	public String Name {get;set;} 
	public String CreatedDate {get;set;} 
	public String CreatedById {get;set;} 
	public String LastModifiedDate {get;set;} 
	public String LastModifiedById {get;set;} 
	public String Description {get;set;} 
	public Metadata Metadata {get;set;} 
	public String FullName {get;set;} 
	
	public class Attributes {
		public String type_Z {get;set;} // in json: type
		public String url {get;set;} 
	}
	
	public class ApplicationVisibilities {
	}
	
	public class Metadata {
		public List<ApplicationVisibilities> applicationVisibilities {get;set;} 
		public List<ApplicationVisibilities> classAccesses {get;set;} 
		public Boolean custom {get;set;} 
		public List<ApplicationVisibilities> customPermissions {get;set;} 
		public String description {get;set;} 
		public List<ApplicationVisibilities> externalDataSourceAccesses {get;set;} 
		public List<ApplicationVisibilities> fieldPermissions {get;set;} 
		public String loginHours {get;set;} 
		public List<LoginIpRanges> loginIpRanges {get;set;} 
		public List<ApplicationVisibilities> objectPermissions {get;set;} 
		public List<ApplicationVisibilities> pageAccesses {get;set;} 
		//public List<ApplicationVisibilities> profileActionOverrides {get;set;} 
		public List<ApplicationVisibilities> recordTypeVisibilities {get;set;} 
		public List<ApplicationVisibilities> tabVisibilities {get;set;} 
		public String urls {get;set;} 
		public String userLicense {get;set;} 
		public List<UserPermissions> userPermissions {get;set;}
	}
	
	public class LoginIpRanges {
		public String description {get;set;} 
		public String endAddress {get;set;} 
		public String startAddress {get;set;} 

		
	}
	
	public class UserPermissions {
		public Boolean enabled {get;set;} 
		public String name {get;set;}
	}
}