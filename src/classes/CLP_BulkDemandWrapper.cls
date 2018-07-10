/**
 * CLP_BulkDemandWrapper.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: Common class
 */
public with sharing class CLP_BulkDemandWrapper {
	public Boolean success {get;set;}
	public String error_message {get;set;}	
	public String user_id {get;set;} 
	public String access_key {get;set;} 
	public List<Demand> demand {get;set;} 
	public CLP_BulkDemandWrapper(){

	}
	public CLP_BulkDemandWrapper(String uid,String key, List<DemandDetail__c> demandList,Boolean isUnStop){
		try{
			user_id = uid;
			access_key = key;
			List<Demand> demands = new List<Demand>();
			for(DemandDetail__c dd: demandList){
				Demand d = new Demand();				
				d.code = isUnStop ? null : dd.Id; // bulk upsert will send id as code
				d.billing_code = IsNull(dd.Account__r.SeikyusakiCode__c); 
				// not neccessary b/c it has billing_individual_code
				//d.billing_individual_number = dd.Seikyuusakibusho__r.billing_individual_number__c;
				d.billing_individual_code = dd.Seikyuusakibusho__r.billing_individual_number__c; 
				d.number_Z = isUnStop ? dd.DemandDetailCode__c : null; // bulk unstop will send DemandDetailCode__c as number
				d.payment_method_code = isNull(dd.PaymentMethod__r.PaymentMethodCode__c);
				d.goods_code = dd.GoodsCode__c;
				d.item_code = isNull(dd.Item_code__c);
				d.type = Integer.valueOf(dd.DemandType__c);
				d.goods_name = isNull(dd.ProductName__c);
				d.price = isNull(dd.Price__c);
				d.quantity = isNull(dd.Quantity__c);
				d.unit = isNull(dd.Unit__c);
				d.tax_category = isNull(dd.TaxCategory__c);
				d.tax = dd.TaxRate__c;
				d.billing_method = Integer.valueOf(dd.PaymentProcess__c);
				d.repetition_period_number =  IsNull(dd.Repeat_Period_Number__c);
				d.repetition_period_unit = (Integer.valueOf(dd.DemandType__c) == 1 || Integer.valueOf(dd.DemandType__c) == 2) ? '1' : '';
				d.start_date = formatDate(dd.StartDate__c);
				d.repeat_count = IsNull(dd.Repeat_Count__c);
				d.period_format = IsNull(dd.Period_Format__c);
				d.period_value = IsNull(dd.Period_Value__c);
				d.period_unit = IsNull(dd.Period_Unit__c);
				d.period_criterion = (IsNull(dd.Period_Format__c) != '2' && IsNull(dd.Period_Format__c) != '3') ? '0' : IsNull(dd.Period_Criterion__c);
				d.sales_recorded_month = dd.BillIssueCriteria_Month__c;
				d.sales_recorded_day = dd.BillIssueCriteria_Date__c;
				d.issue_month = dd.BillIssueCriteria_Month__c;
				d.issue_day = dd.BillIssueCriteria_Date__c;
				d.sending_month = dd.BillSendScheduleCriteria_Month__c;
				d.sending_day = dd.BillSendScheduleCriteria_Day__c;
				d.deadline_month = dd.TransferDeadline_Month__c;
				d.deadline_day = dd.TransferDeadline_Day__c;
				d.slip_deadline_month = dd.SlipDeadline_Month__c;
				d.slip_deadline_day = dd.SlipDeadline_Day__c;
				d.bill_template_code = dd.Bill_Template_Code__c;
				d.memo = '';
				// update on 2017/09/26
				d.bs_owner_code = dd.BsOwnerCode__c;
				d.account_title_code = '4100';
				d.remark = dd.Remark__c;

				demands.add(d);
			}
			demand = demands;
		}catch(Exception ex){
			throw ex;
		}
	}

	// demand list
	public class Demand {
		public Demand(){}
		public String error_code{get;set;}
		public String error_message{get;set;}
		//public String code {get;set;} 
		public String billing_code {get;set;} 
		public String billing_individual_number {get;set;} 
		public String billing_individual_code {get;set;} 
		public String payment_method_code {get;set;} 
		public String number_Z {get;set;} // in json: number
		public String code {get;set;} 
		public String item_code {get;set;} 
		public Integer type {get;set;} // in json: type
		public String goods_code {get;set;} 
		public String link_goods_code {get;set;} 
		public String goods_name {get;set;} 
		public Decimal price {get;set;} 
		public Decimal quantity {get;set;} 
		public String unit {get;set;} 
		public String tax_category {get;set;} 
		public String tax {get;set;} 
		public String remark {get;set;} 
		public Integer billing_method {get;set;} 
		public String repetition_period_number {get;set;} 
		public String repetition_period_unit {get;set;} 
		public String start_date {get;set;} 
		public String repeat_count {get;set;} 
		public String period_format {get;set;} 
		public String period_value {get;set;} 
		public String period_unit {get;set;} 
		public String period_criterion {get;set;} 
		public String sales_recorded_month {get;set;} 
		public String sales_recorded_day {get;set;} 
		public String issue_month {get;set;} 
		public String issue_day {get;set;} 
		public String sending_month {get;set;} 
		public String sending_day {get;set;} 
		public String deadline_month {get;set;} 
		public String deadline_day {get;set;} 
		public String slip_deadline_month {get;set;} 
		public String slip_deadline_day {get;set;} 
		public String memo {get;set;} 
		public String bill_template_code {get;set;} 
		public String bs_owner_code {get;set;} 
		public String account_title_code {get;set;}
		public Integer del_flg{get;set;}		

		// api demand/search
		public Integer repeat_count_limit{get;set;}
		public String next_issue_date {get;set;}
		public String next_sending_date {get;set;}
		public String next_deadline_date {get;set;}
		public String next_slip_deadline_date {get;set;}
		public String next_period_start_date{get;set;}
		public String next_period_end_date{get;set;}
	}

	private String isNull(String str){
		return str == null ? '' : str;
	}

	private Decimal isNull(Decimal val){
		return val == null ? 0 : val;
	}

	private Integer isNull(Integer val){
		return val == null ? 0 : val;
	}

	private String formatDate(Date d){
		String month = d.month() < 10 ? '0' + d.month() : String.valueOf(d.month());
		String day = d.day() < 10 ? '0' + d.day() : String.valueOf(d.day());
		return d.year() +'/'+ month +'/'+ day;
	}
}