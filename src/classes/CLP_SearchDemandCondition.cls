/**
 * CLP_SearchDemandCondition.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: Search condition JSON object for search demand controller
 */
global with sharing class CLP_SearchDemandCondition {
	public String fields;
	public Integer pageSize;
	public Integer page;
	public Integer offset; 
	public String sortColumn;
	public String sortOption;
	public List<FilterOption> opts;
	public class FilterOption{
		public String filter_id;
		public String filter_key;		
		public String filter_value;		
	}
}