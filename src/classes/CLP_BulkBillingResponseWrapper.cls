public with sharing class CLP_BulkBillingResponseWrapper {	
	public Boolean 			success 		{get;set;}
	public String 			error_message 	{get;set;}	
	public String 			user_id {get;set;} 
	public String 			access_key {get;set;} 
	public List<Billing> 	billing {get;set;} 

	public CLP_BulkBillingResponseWrapper(){
		this.billing = (billing != null)? billing : new List<Billing>();
	}

	public CLP_BulkBillingResponseWrapper(String userId, String accessKey, List<Billing> billing){
		this.user_id = userId;
		this.access_key = accessKey;
		this.billing = (billing != null)? billing : new List<Billing>();
	}

	public class Billing {
		public Billing(){
			individual = new List<Individual>();
			payment = new List<Payment>();
			sub_account_title = new List<Sub_account_title>();
		}
		public String error_code {get;set;} 
		public String error_message {get;set;} 
		public String code {get;set;} 
		public String name {get;set;}
		public List<Individual> individual {get;set;} 
		public List<Payment> payment {get;set;} 
		public List<Sub_account_title> sub_account_title {get;set;} 
	}

	public class Payment {
		public Integer error_code {get;set;} 
		public String error_message {get;set;} 
		public Integer del_flg	{get;set;}
		public String number_Z {get;set;} // in json: number
		public String code {get;set;} 
		public String name {get;set;} 
		public String bank_transfer_pattern_code {get;set;} 
		public String payment_method {get;set;} 
		public String register_status {get;set;} 
		public String source_bank_account_name {get;set;} 
		public String customer_number {get;set;} 
		public String bank_code {get;set;} 
		public String bank_name {get;set;} 
		public String branch_code {get;set;} 
		public String branch_name {get;set;} 
		public String bank_account_type {get;set;} 
		public String bank_account_number {get;set;} 
		public String bank_account_name {get;set;} 
		public String payment_type {get;set;} 
		public String cod {get;set;} 
		public String bank_check_bank_code {get;set;} 
		public String bank_check_bank_name {get;set;} 
		public String bank_check_branch_code {get;set;} 
		public String bank_check_branch_name {get;set;} 
		public String bank_check_kind {get;set;} 
		public String bank_check_bank_account_number {get;set;} 
		public String url {get; set;}
		public String credit_card_regist_kind {get;set;} 
	}
	
	public class Individual {
		public String error_code {get;set;} 
		public String error_message {get;set;} 
		public String number_Z {get;set;} // in json: number
		public String code {get;set;} 
		public String name {get;set;} 
		public String link_customer_code {get;set;} 
		public String address1 {get;set;} 
		public String address2 {get;set;} 
		public String address3 {get;set;} 
		public String zip_code {get;set;} 
		public String pref {get;set;} 
		public String city_address {get;set;} 
		public String building_name {get;set;} 
		public String set_post_address {get;set;} 
		public String post_address1 {get;set;} 
		public String post_address2 {get;set;} 
		public String post_address3 {get;set;} 
		public String post_zip_code {get;set;} 
		public String post_pref {get;set;} 
		public String post_city_address {get;set;} 
		public String post_building_name {get;set;} 
		public String tel {get;set;} 
		public String email {get;set;} 
		public String cc_email {get;set;} 
		public String memo {get;set;} 
		public String billing_method {get;set;} 
		public String issue_month {get;set;} 
		public String issue_day {get;set;} 
		public String sending_month {get;set;} 
		public String sending_day {get;set;} 
		public String deadline_month {get;set;} 
		public String deadline_day {get;set;} 
		public String payment_method_code {get;set;} 
		public String bs_owner_code {get;set;} 
		public String ref_billing_code {get;set;} 
		public String ref_individual_number {get;set;} 
		public String ref_individual_code {get;set;} 
		public String bill_template_code {get;set;} 
		public String del_flg {get;set;}
		public Sub_account_title sub_account_title {get;set;} 	
	}

	public class Sub_account_title {
		public String error_code {get;set;} 
		public String error_message {get;set;} 
		public String account_receivable_code {get;set;} 
		public String advances_received_code {get;set;} 
		public String suspense_received_code {get;set;} 
		public String account_title_code {get;set;} 
		public String journal_cooperation_code {get;set;}
	}

}