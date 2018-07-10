public class CLP_BulkBillingWrapper {
	public Boolean 			success 		{get;set;}
	public String 			error_message 	{get;set;}	
	public String 			user_id {get;set;} 
	public String 			access_key {get;set;} 
	public List<Billing> 	billing {get;set;} 

	public CLP_BulkBillingWrapper(){
		this.billing = (billing != null)? billing : new List<Billing>();
	}

	public CLP_BulkBillingWrapper(String userId, String accessKey, List<Billing> billing){
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
		public List<Sub_account_title> sub_account_title {get;set;} 	
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

	// get billing index by account billingCode && billingName
	public Integer getBillingByCodeName(String billingCode, String billingName){
		for(Integer i = 0; i < this.billing.size(); i++){
			if(this.billing[i].code == billingCode && this.billing[i].name == billingName){
				if(this.billing[i].individual == null){
					this.billing[i].individual = new List<Individual>();
				}
				return i;
			}
		}
		Billing bill = new Billing();
		bill.code = (String.isBlank(billingCode)) ? '' : billingCode;
		bill.name = (String.isBlank(billingName)) ? '' : billingName.left(100);
		bill.individual = new List<Individual>();
		bill.payment = new List<Payment>();
		bill.sub_account_title = new List<Sub_account_title>();
		this.billing.add(bill);
		
		return this.billing.size()-1;
	}

	// set list billingindividual group by billing code
	public void setListBillIndividual(List<Seikyusakibusho__c> biList , Boolean isStop){
		
		for(Seikyusakibusho__c s : biList){
			Integer billingIndex = getBillingByCodeName(s.Seikyusakimei__r.SeikyusakiCode__c, s.Seikyusakimei__r.Name);
			Individual i = new Individual();
			// set List billingindividual when bulk stop
			if (isStop){
				i.code = s.billing_individual_number__c;
				i.del_flg = s.StopFlg__c;
			}
			else // set list billingindividual when bulk upsert
			{
				//required
				i.code = s.billing_individual_number__c;
				i.name = s.name;
				i.address1 = s.address1__c;
				i.zip_code = s.zip_code__c.left(7);
				i.pref = s.pref__c;
				i.city_address = s.city_address__c;
				i.email = s.email__c;
				// optional
				i.cc_email = s.cc_email__c;
				i.address2 = s.address2__c;
				i.address3 = s.address3__c;
				i.building_name = s.building_name__c;
				i.tel = s.tel__c; //Only required when add, payment_method=1,2,6,7,8
				Sub_account_title accTitle = new Sub_account_title();
				accTitle.account_receivable_code = s.account_receivable_code__c;
				accTitle.advances_received_code = s.advances_received_code__c;
				accTitle.suspense_received_code = s.suspense_received_code__c;
				i.sub_account_title = new List<Sub_account_title>{accTitle};								
			}
			this.billing[billingIndex].individual.add(i);			
		}
	}
	// set list billingindividual group by billing code to delete
	public void setListBillIndividualToDelete(List<MikataInteBuffer__c> bfList){
		for(MikataInteBuffer__c bf : bfList){
			Integer billingIndex = getBillingByCodeName(bf.AccountId__r.SeikyusakiCode__c, bf.AccountId__r.Name);
			Individual i = new Individual();
			// set List billingindividual when bulk stop
			i.code = (bf.RecordCode__c == null) ? '' : bf.RecordCode__c;
			i.del_flg = CLP_MikataConstant.FLG_DELETE;
			
			this.billing[billingIndex].individual.add(i);			
		}
	}

	// set list billing payment group by billing code and name
	public void setListBillPayment(List<PaymentMethod__c> listPayMet){
		for(PaymentMethod__c payMet : listPayMet){
			Payment aPayment = new Payment();
			aPayment.name = payMet.Name;			
			aPayment.code = payMet.PaymentMethodCode__c;
			aPayment.payment_method = payMet.PaymentMethod__c;
			aPayment.bank_transfer_pattern_code = '1';

			// BankTransfer '0'
			if (payMet.PaymentMethod__c == CLP_MikataConstant.PM_BANK_TRANSFER) {           
                aPayment.source_bank_account_name = payMet.source_bank_account_name__c;
                aPayment.bank_transfer_pattern_code = payMet.Bank_Transfer_Pattern_Code__c;  	// * done
            
            // CreditCard '1'
            } else if (payMet.PaymentMethod__c == CLP_MikataConstant.PM_CREDIT_CARD) {  
            	aPayment.credit_card_regist_kind = '2'; 		// 【SFDC-請求管理ロボ】決済手段登録連携バッチジョブ_0.4.xls (line 10)

            // BankCheck '2'
            } else if (payMet.PaymentMethod__c == CLP_MikataConstant.PM_BANK_CHECK) { 
                aPayment.source_bank_account_name = payMet.source_bank_account_name__c;
                /*aPayment.bank_code = payMet.bank_check_bank_code__c;
                aPayment.bank_name = payMet.bank_check_bank_name__c;
                aPayment.branch_code = payMet.bank_check_branch_code__c;
                aPayment.branch_name = payMet.bank_check_branch_name__c;
                aPayment.bank_account_number = payMet.bank_check_bank_account_number__c;    	// * done
                //aPayment.bank_account_type = payMet.bank_check_kind__c;                      	// * done
                aPayment.bank_check_kind = payMet.bank_check_kind__c;                      		// * done*/

           	// CP_AccountTransfer '3' 
            } else if (payMet.PaymentMethod__c == CLP_MikataConstant.PM_CP_ACCOUNT_TRANSFER) {
                aPayment.bank_code = (payMet.BankCode__c == null) ? null : payMet.BankCode__c;
                aPayment.branch_code = payMet.BranchCode__c; 
                //aPayment.bank_name = payMet.BankName__c;
                //aPayment.branch_name = payMet.BranchName__c;
                aPayment.bank_account_type = payMet.BankAccountType__c;         // * done
                aPayment.bank_account_number = payMet.BankAccountNumber__c;    	// * done
                aPayment.bank_account_name = payMet.BankAccountName__c;			// * done (30 digit max) 
                
            // RL_AccountTransfer '4'
            } else if (payMet.PaymentMethod__c == CLP_MikataConstant.PM_RL_ACCOUNT_TRANSFER) {  
                aPayment.bank_code = (payMet.BankCode__c == null) ? null : payMet.BankCode__c;
                aPayment.branch_code = payMet.BranchCode__c;
                //aPayment.bank_name = payMet.BankName__c;
                //aPayment.branch_name = payMet.BranchName__c;
                aPayment.bank_account_type = payMet.BankAccountType__c;         				// * done
                aPayment.bank_account_number = payMet.BankAccountNumber__c;     	
                aPayment.bank_account_name = payMet.BankAccountName__c;
                
            // Other_AccountTransfer '5'
            } else if (payMet.PaymentMethod__c == CLP_MikataConstant.PM_OTHER_ACCOUNT_TRANSFER) {  
                aPayment.bank_code = (payMet.BankCode__c == null) ? null : payMet.BankCode__c;
                aPayment.bank_name = payMet.BankName__c;
                aPayment.branch_code = payMet.BranchCode__c;
                aPayment.branch_name = payMet.BranchName__c;
                aPayment.bank_account_type = payMet.BankAccountType__c;         				// * done
                aPayment.bank_account_number = payMet.BankAccountNumber__c;    	
                aPayment.bank_account_name = payMet.BankAccountName__c;
                aPayment.customer_number = payMet.CustomerNumber__c; 
                
            // PaymentSlip '7'
            } else if (payMet.PaymentMethod__c == CLP_MikataConstant.PM_PAYMENT_SLIP) {}
            
            Integer billingIndex = getBillingPaymentByCodeName(payMet.AccountId__r.SeikyusakiCode__c, payMet.AccountId__r.Name);
			this.billing[billingIndex].payment.add(aPayment);
		}
	}

	// set list billing payment group by billing code and name
	public void setListBillPaymentStop(List<PaymentMethod__c> listPayMet){
		for(PaymentMethod__c payMet : listPayMet){
			Payment aPayment = new Payment();
			aPayment.code = payMet.PaymentMethodCode__c;	
			aPayment.del_flg = Integer.valueOf(payMet.StopFlg__c);
            Integer billingIndex = getBillingPaymentByCodeName(payMet.AccountId__r.SeikyusakiCode__c, payMet.AccountId__r.Name);
			this.billing[billingIndex].payment.add(aPayment);
		}
	}

	// set list billing payment group by billing code and name
	public void setListBillPaymentDelete(List<MikataInteBuffer__c> bufferPayMetsList){
		for(MikataInteBuffer__c bufferPayMet : bufferPayMetsList){
			Payment aPayment = new Payment();
			aPayment.code = bufferPayMet.RecordCode__c;	
			aPayment.del_flg = Integer.valueOf(CLP_MikataConstant.FLG_DELETE);
            Integer billingIndex = getBillingPaymentByCodeName(bufferPayMet.AccountId__r.SeikyusakiCode__c, bufferPayMet.AccountId__r.Name);
			this.billing[billingIndex].payment.add(aPayment);
		}
	}

	// set list billing payment group by billing code and name
	public void setListBillPaymentAccountTransfer(List<PaymentMethod__c> listPayMet){
		for(PaymentMethod__c payMet : listPayMet){
			Payment aPayment = new Payment();
			aPayment.code = payMet.PaymentMethodCode__c;	
            Integer billingIndex = getBillingPaymentByCodeName(payMet.AccountId__r.SeikyusakiCode__c, payMet.AccountId__r.Name);
			this.billing[billingIndex].payment.add(aPayment);
		}
	}

	// set list billing payment group by billing code and name
	public void setListBillPaymentCreditCard(List<PaymentMethod__c> listPayMet){
		for(PaymentMethod__c payMet : listPayMet){
			Payment aPayment = new Payment();
			aPayment.name = payMet.Name;			
			aPayment.code = payMet.PaymentMethodCode__c;
			aPayment.payment_method = payMet.PaymentMethod__c;
            Integer billingIndex = getBillingPaymentByCodeName(payMet.AccountId__r.SeikyusakiCode__c, payMet.AccountId__r.Name);
			this.billing[billingIndex].payment.add(aPayment);
		}
	}

	// get billing index by account billingCode && billingName
	public Integer getBillingPaymentByCodeName(String billingCode, String billingName){
		for(Integer i = 0; i < this.billing.size(); i++){
			if(this.billing[i].code == billingCode && this.billing[i].name == billingName){
				if(this.billing[i].payment == null){
					this.billing[i].payment = new List<Payment>();
				}
				if(this.billing[i].individual == null){
					this.billing[i].individual = new List<Individual>();
				}
				if(this.billing[i].sub_account_title == null){
					this.billing[i].sub_account_title = new List<Sub_account_title>();
				}
				return i;
			}
		}
		Billing bill = new Billing();
		bill.code = (String.isBlank(billingCode)) ? '' : billingCode;	// billing code is unique (Account.SeikyusakiCode__c)
		bill.name = (String.isBlank(billingName)) ? '' : billingName.left(100);
		bill.individual = new List<Individual>();
		bill.payment = new List<Payment>();
		bill.sub_account_title = new List<Sub_account_title>();
		this.billing.add(bill);
		return this.billing.size()-1; // index 0 for first element
	}
}