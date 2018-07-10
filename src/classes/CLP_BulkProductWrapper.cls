/**
 * CLP_BulkProductWrapper.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: Common class
 */
public with sharing class CLP_BulkProductWrapper {
	public Boolean 			success 		{get;set;}
	public String 			error_message 	{get;set;}	
	public String 			user_id 		{get;set;} 
	public String 			access_key 		{get;set;} 
	public List<Goods> 		goods 			{get;set;} 

	public CLP_BulkProductWrapper() {
		
	}

	public CLP_BulkProductWrapper(String uid, String key, String taxRate, List<Product2> productList){
		try {
			this.user_id = uid;
			this.access_key = key;
			List<Goods> gList = new List<Goods>();
			for(Product2 pp: productList){
				Goods p = new Goods();
				p.code = (pp.ProductCode == null) ? null : pp.ProductCode.left(33);
				p.item_code = pp.Item_Code__c;			
				p.item_name = max60Chars(pp.Name); 	// Coding/実装 #29831
				p.name = max60Chars(pp.Name); 				
				//p.demand_type = Integer.valueOf(pp.DemandType__c);
				p.demand_type = 0;					// Coding/実装 #30168
				p.unit_price = 0;					// Coding/実装 #29831 // 【SFDC-請求管理ロボ】商品登録バッチジョブ_0.3
				p.unit = pp.Unit__c;			
				p.tax_category = Integer.valueOf(pp.TaxCategory__c);		
				p.tax_rate = getTaxRate(taxRate, pp.TaxCategory__c);
				p.repetition_period_number = (pp.DemandType__c == '1' || pp.DemandType__c == '2') ? 1 : null; 	// Coding/実装 #29831
				p.repetition_period_unit = 1;							  // 【SFDC-請求管理ロボ】商品登録バッチジョブ_0.3
				p.period_format = 0;				// Coding/実装 #29831 // 【SFDC-請求管理ロボ】商品登録バッチジョブ_0.3
				p.bill_template_code = 10000;
				//p.account_title_code = pp.SalesAccountTitleCode__c == null ? 4100 : Integer.valueOf(pp.SalesAccountTitleCode__c);
				p.account_title_id = pp.SalesAccountTitleCode__c == null ? 4100 : Integer.valueOf(pp.SalesAccountTitleCode__c);
				p.sub_account_title_code = pp.SalesSubAccountTitleCode__c;   		
				p.account_title_code_account_receivable_trade = 1162;
				p.sub_account_title_code_account_receivable_trade = pp.AccountReceivableSubAccountTitleCode__c;
				p.account_title_code_advances_received = 2111;
				p.sub_account_title_code_advances_received = pp.AdvanceReceivedSubAccountTitleCode__c; 
				p.repeat_count_max = (pp.DemandType__c == '1' || pp.DemandType__c == '2') ? 1 : null;
				/*p.period_value = 1;
				p.period_unit = 1;
				p.period_criterion = 1;
				p.bill_issue_date_month = 0;
				p.bill_issue_date_day = 1;
				p.bill_sending_date_month = 0;
				p.bill_sending_date_day = 1;
				p.transfer_deadline_month = 0;
				p.transfer_deadline_day = 1;
				p.sales_recorded_date_month = 0;
				p.sales_recorded_date_day = 99;
				p.billing_method = 0;*/
				gList.add(p);
			}
			this.goods = gList;
		} catch(Exception ex){
			throw ex;
		}
	}

	// Goods (product linked mikata) class
	public class Goods {
		public String error_code						{get;set;}
		public String error_message						{get;set;}
		public Integer del_flg							{get;set;}
		public Integer item_number						{get;set;}
		public String item_code							{get;set;}
		public String code 								{get;set;}
		public String journal_cooperation_goods_code	{get;set;} 
		public String item_name 						{get;set;} 
		public String name 								{get;set;} 
		public Integer demand_type 						{get;set;} 
		public Integer unit_price 						{get;set;}
		public String unit 								{get;set;} 
		public Integer tax_category 					{get;set;} 
		public Integer tax_rate 						{get;set;}
		public String remarks_column 					{get;set;} 
		public Integer repetition_period_number 		{get;set;} 
		public Integer repetition_period_unit 			{get;set;} 
		public Integer repeat_count_max 				{get;set;} 
		public Integer period_format 					{get;set;} 
		public Integer period_value 					{get;set;} 
		public Integer period_unit 						{get;set;} 
		public Integer period_criterion 				{get;set;} 
		public Integer bill_issue_date_month 			{get;set;} 
		public Integer bill_issue_date_day 				{get;set;} 
		public Integer bill_sending_date_month 			{get;set;} 
		public Integer bill_sending_date_day 			{get;set;} 
		public Integer transfer_deadline_month 			{get;set;} 
		public Integer transfer_deadline_day 			{get;set;} 
		public Integer sales_recorded_date_month 		{get;set;} 
		public Integer sales_recorded_date_day			{get;set;}		
		public Integer billing_method 					{get;set;} 
		public Integer bill_template_code 				{get;set;} 
		public Integer account_title_code               {get;set;} 
		public Integer account_title_id             	{get;set;}
		public String sub_account_title_code 			{get;set;} 
		public Integer account_title_code_account_receivable_trade		{get;set;} 
		public String sub_account_title_code_account_receivable_trade 	{get;set;} 
		public Integer account_title_code_advances_received				{get;set;}
		public String sub_account_title_code_advances_received 			{get;set;} 
	}

	private String max60Chars(String str){
		return str.length() > 60 ? str.left(60) : str;
	}

	private static Integer getTaxRate(String tax, String taxCategory) {
		if (taxCategory == '0' || taxCategory == '1') {
			return (tax == null) ? 0 : Integer.valueOf(tax);	
		} else {
			return null;
		}	
	} 
}