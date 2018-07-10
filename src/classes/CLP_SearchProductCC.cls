public with sharing class CLP_SearchProductCC {
	public Integer total_size {get;set;}
	public List<OpportunityLineItem> products {get;set;}
	public String search_text {get;set;}
	public CLP_SearchProductCC() {
		total_size = 0;
	}

	public PageReference search(){
		if(String.isBlank(search_text)){
			products = [Select ProductCode,Name From OpportunityLineItem 					
					order by ProductCode asc limit 50000];
		}else {
		String key_search = String.escapeSingleQuotes('%'+search_text +'%');
		products = [Select ProductCode,Name From OpportunityLineItem 
					where Name like: key_search 
					order by ProductCode asc limit 50000];
		}
		total_size = products.size();
		return null;
	}

}