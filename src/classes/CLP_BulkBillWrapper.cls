public with sharing class CLP_BulkBillWrapper {
    public Boolean          success             {get;set;}
    public String           error_message       {get;set;}  
    public String           user_id     {get;set;} 
    public String           access_key  {get;set;} 
    public Integer          limit_count {get;set;}
    public Integer          page_count  {get;set;}
    public Integer          total_page_count {get;set;}
    public List<Bill>       bill        {get;set;} 
    private Integer         dayToAdd;

    public CLP_BulkBillWrapper() {}

    public CLP_BulkBillWrapper(String userId, String accessKey, List<Bill> listBill) {
        this.user_id = userId;
        this.access_key = accessKey;
        this.bill = (listBill == null) ? new List<Bill>() : listBill; 
        this.dayToAdd = 1;
    }

    public class Bill {
        public String error_code                    {get; set;}
        public String error_message                 {get; set;}
        public String number_z                      {get; set;}
        public String bs_residence_code             {get; set;}
        public String billing_code                  {get; set;}
        public String billing_name                  {get; set;}
        public String billing_individual_number     {get; set;}
        public String billing_individual_code       {get; set;}
        public String billing_individual_name       {get; set;}
        public String demand_number                 {get; set;}
        public Integer subtotal_amount_billed       {get; set;}     
        public Integer consumption_tax_amount       {get; set;}
        public Integer total_amount_billed          {get; set;}
        public Integer unclearing_amount            {get; set;}
        public String message_column                {get; set;}
        public Integer billing_method               {get; set;}
        public String issue_date                    {get; set;}
        public String make_date                     {get; set;}
        public String sending_scheduled_date        {get; set;}     
        public String sending_date                  {get; set;}
        public String update_date                   {get; set;}
        public String confirm_date                  {get; set;}
        public Integer mail_send_flg                {get; set;}
        public Integer post_send_flg                {get; set;}
        public Integer payment_method               {get; set;}
        public String payment_method_number         {get; set;}     
        public String payment_method_code           {get; set;}
        public String payment_method_name           {get; set;}
        public Integer settlement_result            {get; set;}
        public String transfer_deadline             {get; set;}
        public String transfer_date                 {get; set;}
        public Integer payment_status               {get; set;}
        public String memo                          {get; set;}
        public String template_code                 {get; set;} 
        public String bs_department_code            {get; set;}
        public String bs_department_name            {get; set;}
        public String bs_owner_code                 {get; set;}
        public String bs_owner_name                 {get; set;}
        public Integer valid_flg                    {get; set;}
        public Integer delete_flg                   {get; set;}
        public Integer limit_count                  {get; set;}
        public Integer page_count                   {get; set;}
        public Integer total_page_count             {get; set;}
        public Integer gid                          {get; set;}
        public String erasure_deposit_date          {get; set;}
        public String erasure_cancel_date           {get; set;}
        public String issue_start_date              {get; set;}
        public String issue_stop_date               {get; set;}
        public String update_start_date             {get; set;} 
        public String update_stop_date              {get; set;}
        public String deadline_start_date           {get; set;}
        public String deadline_stop_date            {get; set;}
        public String download_url                  {get; set;}
        public List<BillDetail> bill_detail         {get; set;}

        public Bill() {
            bill_detail = new List<BillDetail>();   
        }
    }

    public class BillDetail {
        public String demand_number             {get; set;}
        public String demand_code               {get; set;}
        public String item_number               {get; set;}
        public String item_code                 {get; set;}
        public String goods_name                {get; set;} 
        public String pattern_period_format     {get; set;}
        public String demand_start_date         {get; set;} 
        public String demand_end_date           {get; set;}
        public String criterion_date            {get; set;} 
        public String link_customer_code        {get; set;}
        public String goods_code                {get; set;}
        public Integer link_goods_code          {get; set;} 
        public Integer unit_price               {get; set;}
        public String quantity                  {get; set;}
        //public Integer unit                     {get; set;}
        public String unit                      {get; set;}
        public Integer tax_category             {get; set;} 
        public String consumption_tax           {get; set;}
        public Integer subtotal_amount_billed   {get; set;}
        public Integer consumption_tax_amount   {get; set;}
        public Integer total_amount_billed      {get; set;} 
        public Integer unclearing_amount        {get; set;} 
        public String remark                    {get; set;}
        public String recorded_date             {get; set;}
        public String payment_method            {get; set;}
        public Integer payment_status           {get; set;}
        public Integer valid_flg                {get; set;}
        public String delete_flg                {get; set;}
    }

    public void setListBillToSearch(List<LastReference__c> lastRefList, String billNumber) {
        for (LastReference__c lr : lastRefList) {
            Bill billRq = new Bill();
            billRq.update_start_date = (lr.LastReferenceDate__c == null) ? getFormatDate(Date.today()) : getFormatDate(lr.LastReferenceDate__c);
            billRq.update_stop_date = getFormatDate(Date.today().addDays(this.dayToAdd));
            billRq.number_z = (billNumber == null) ? null : billNumber;
            //billRq.page_count = indexPage;
            //billRq.limit_count = 50;        // get 50 record per running batch
            this.bill.add(billRq);
        }
    } 

    public void setListBillToUpsert(List<Bill__c> listBill) {
        for (Bill__c bill : listBill) {
            Bill billRq = new Bill();
            billRq.number_z = bill.number__c;                               // required param
            billRq.billing_code = getBillingCode(bill);                     // required param
            billRq.message_column = bill.MessageColumn__c;
            billRq.sending_scheduled_date = (bill.SendingScheduledDate__c == null) ? null : getFormatDate(bill.SendingScheduledDate__c);
            billRq.transfer_deadline = (bill.PaymentDeadlineDate__c == null) ? null : getFormatDate(bill.PaymentDeadlineDate__c);
            billRq.payment_status = (bill.PaymentStatus__c == null) ? null : Integer.valueOf(bill.PaymentStatus__c);
            this.bill.add(billRq);
        }
    }

    public void setListBillToStop(List<Bill__c> listBill) {
        for (Bill__c bill : listBill) {
            Bill billRq = new Bill();
            billRq.number_z = bill.number__c;                               // required param
            billRq.billing_code = getBillingCode(bill);                     // required param
            this.bill.add(billRq);
        }
    }

    public void setListBillToGetUrl(List<Bill__c> listBill) {
        for (Bill__c bill : listBill) {
            Bill billRq = new Bill();
            billRq.number_z = bill.number__c;                               // required param
            billRq.billing_code = getBillingCode(bill);                     // required param
            billRq.update_start_date = (bill.Update_Date__c == null) ? getFormatDate(Date.today()) : getFormatDate(bill.Update_Date__c);
            billRq.update_stop_date = getFormatDate(Date.today().addDays(this.dayToAdd));   
            this.bill.add(billRq);
        }
    }

    public void setListBillDetail(Bill__c bill, BillDetail__c biDet) {
        // Bill mikata
        Bill billRq = new Bill();
        billRq.number_z = bill.number__c;                                   // required param
        billRq.billing_code = getBillingCode(bill);                         // required param

        // Bill detail mikata
        BillDetail biDetReq = new BillDetail();
        biDetReq.goods_code = biDet.GoodsCode__c;
        biDetReq.unit_price = (biDet.Price__c == null) ? null : Integer.valueOf(biDet.Price__c);
        biDetReq.quantity = (biDet.Quantity__c == null) ? null : String.valueOf(biDet.Quantity__c);
        //biDetReq.unit = (biDet.Unit__c == null) ? null : Integer.valueOf(biDet.Unit__c);
        biDetReq.unit = biDet.Unit__c;
        biDetReq.consumption_tax_amount = (biDet.Consumption_Tax_Amount__c == null) ? null : Integer.valueOf(biDet.Consumption_Tax_Amount__c);
        biDetReq.remark = biDet.Remark__c;
        biDetReq.demand_start_date = (biDet.PeriodStartDate__c == null) ? null : getFormatDate(biDet.PeriodStartDate__c);
        biDetReq.demand_end_date = (biDet.PeriodEndDate__c == null) ? null : getFormatDate(biDet.PeriodEndDate__c);
        
        // Add bill detail
        billRq.bill_detail.add(biDetReq);

        // Add bill
        this.bill.add(billRq);
    }

    private String getFormatDate(Date aDate) {
        // return date with format yyyy/MM/dd
        String dateFormat = 'yyyy/MM/dd';
        Datetime dt = Datetime.newInstance(aDate.year(), aDate.month(), aDate.day());
        return dt.format(dateFormat);
    }

    private String getBillingCode(Bill__c bi) {
        String returnCode = null;
        if (String.isNotBlank(bi.AccountId__r.SeikyusakiCode__c)) {
            returnCode = bi.AccountId__r.SeikyusakiCode__c;
        } else if (String.isNotBlank(bi.BillingCode__c)) {
            returnCode = bi.BillingCode__c;
        }
        return returnCode;
    }
}