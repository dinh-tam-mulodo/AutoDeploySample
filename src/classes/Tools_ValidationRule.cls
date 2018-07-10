public class Tools_ValidationRule {
	public String error;
    public String error_description;
    public String name {get;set;}

	public Integer size {get;set;} 
	public Integer totalSize {get;set;} 
	public Boolean done {get;set;} 
	public String queryLocator {get;set;} 
	public String entityTypeName {get;set;} 
	public List<Records> records {get;set;}

	public class EntityDefinition {
		public Attributes attributes {get;set;} 
		public String QualifiedApiName {get;set;}		
	}

	public class Attributes {
		public String type_Z {get;set;} // in json: type
		public String url {get;set;}		
	}
	
	public class Records {
		public Attributes attributes {get;set;} 
		public String Id {get;set;} 
		public EntityDefinition entityDefinition {get;set;}		
	}
}