public with sharing class MF_Contact {
	public MF_Contact() {		
	}	
	// stardard field
	public String Id {get;set;}
	public String AccountId{get;set;}
	public String ApproverId{get;set;}
	public String FirstName{get;set;}
	public String LastName{get;set;}
	public String ContactType{get;set;}	
	public Datetime BirthDate{get;set;}	
	public String Email{get;set;}
	public String Phone{get;set;}
	public String Fax{get;set;}
	public String Skype{get;set;}
	public String Address{get;set;}
	// internal field	
	public String UserName{get;set;}
	public String Department{get;set;}
	// external field
	public String CompanyName{get;set;}
	public String Tag{get;set;}
	public Blob BusinessCard{get;set;}
	public String BusinessCardId{get;set;}
}