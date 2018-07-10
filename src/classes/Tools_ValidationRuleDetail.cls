public with sharing class Tools_ValidationRuleDetail {	
	public String error;
    public String error_description;
    public String name {get;set;}
    public String objectName{get;set;}


	public String Id {get;set;} 
	public String ValidationName {get;set;} 
	public Boolean Active {get;set;} 
	public String Description {get;set;}
	public String ManageableState {get;set;} 
	public String CreatedById {get;set;} 
	public String CreatedDate {get;set;} 
	public String LastModifiedById {get;set;} 
	public String LastModifiedDate {get;set;} 
	public Metadata Metadata {get;set;} 
	public String FullName {get;set;} 
	public String EntityDefinitionId {get;set;} 
	public String ErrorDisplayField {get;set;} 
	public String ErrorMessage {get;set;} 
	
	public class Metadata {
		public String description {get;set;} 
		public String errorConditionFormula {get;set;} 
		public String errorDisplayField {get;set;} 
		public String errorMessage {get;set;} 
		public String urls {get;set;} 
		public Boolean active {get;set;} 
	}
}