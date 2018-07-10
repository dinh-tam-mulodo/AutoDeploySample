public class CLP_BulkAccountBillingWrapper {
	public Boolean 			success 		{get;set;}
	public String 			error_message 	{get;set;}	
	public String 			user_id {get;set;} 
	public String 			access_key {get;set;} 
	public List<Billing> 	billing {get;set;} 

	public CLP_BulkAccountBillingWrapper(){ 
	    this.billing = new List<Billing>();
	}

	public CLP_BulkAccountBillingWrapper(String userId, String accessKey, List<Billing> billing){
		this.user_id = userId;
		this.access_key = accessKey;
		this.billing = (billing != null)? billing : new List<Billing>();
	}

	public class Billing {
		public String error_code {get;set;} 
		public String error_message {get;set;} 
		public String code {get;set;} 
		public String del_flg {get;set;}
	}

	public void createListBillingByAccount(List<Account> listAcc){
		if(this.billing == null){
			this.billing = new List<Billing>();
		}
		for(Account acc : listAcc){
			Billing bill = new Billing();
			bill.code = acc.SeikyusakiCode__c;
			bill.del_flg = acc.StopFlg__c;
			this.billing.add(bill);
		}
	}
	public void createListBillingByBuffer(List<MikataInteBuffer__c> listBuffers){
		if(this.billing == null){
			this.billing = new List<Billing>();
		}
		for(MikataInteBuffer__c bf : listBuffers){
			Billing bill = new Billing();
			bill.code = bf.RecordCode__c;
			bill.del_flg = CLP_MikataConstant.FLG_DELETE;
			this.billing.add(bill);
		}
	}
}