// CLOUD PAYMENT
// 経理のミカタ
// API
// 請求先部署
public with sharing class MikataBillingIndividual {
    public Id code { get; private set; } // 請求先部署コード(請求先部署ID)
    public String name { get; private set; } // 請求先部署名
    public String link_customer_code { get; private set; } // 会計ソフト連携用取引先コード
    public String address1 { get; private set; } // 宛名1
    public String address2 { get; private set; } // 宛名2
    public String address3 { get; private set; } // 宛名3
    public Integer zip_code { get; private set; } // 郵便番号
    public String pref { get; private set; } // 都道府県
    public String city_address { get; private set; } // 市区町村番地
    public String building_name { get; private set; } // 建物名
    public Integer set_post_address { get; private set; } // 郵送宛先情報
    public String post_address1 { get; private set; } // 郵送先宛名1
    public String post_address2 { get; private set; } // 郵送先宛名2
    public String post_address3 { get; private set; } // 郵送先宛名3
    public Integer post_zip_code { get; private set; } // 郵送先郵便番号
    public String post_pref { get; private set; } // 郵送先都道府県
    public String post_city_address { get; private set; } // 郵送先市区町村番地
    public String post_building_name { get; private set; } // 郵送先建物名
    public String tel { get; private set; } // 電話番号
    public String email { get; private set; } // メールアドレス
    public String cc_email { get; private set; } // CC送信先メールアドレス
    public String memo { get; private set; } // メモ
    public Integer billing_method { get; private set; } // 請求方法
    public Integer issue_month { get; private set; } // 請求書発行日_月
    public Integer issue_day { get; private set; } // 請求書発行日_日
    public Integer sending_month { get; private set; } // 請求書送付日_月
    public Integer sending_day { get; private set; } // 請求書送付日_日
    public Integer deadline_month { get; private set; } // 決済期限_月
    public Integer deadline_day { get; private set; } // 決済期限_日
    public Id payment_method_code { get; private set; } // 決済手段コード(決済手段ID)
    public Id bs_owner_code { get; private set; } // 請求元担当者コード(請求元担当者ID)
    public Id ref_billing_code { get; private set; } // 合計請求書用請求先コード(請求先ID)
    public Id ref_individual_code { get; private set; } // 合計請求書用請求先部署コード(請求先部署ID)
    public Integer bill_template_code { get; private set; } // 請求書テンプレートコード

    public List<MikataBillingIndividualSubAccountTitle> sub_account_title { get; private set; } // 補助科目コード

    // コンストラクタ
    public MikataBillingIndividual(Account account, Seikyusakibusho__c seikyusakibusho) {
        this.code = seikyusakibusho.Id;
        this.name = seikyusakibusho.Name;
        this.link_customer_code = seikyusakibusho.link_customer_code__c;
        this.address1 = seikyusakibusho.address1__c;
        this.address2 = seikyusakibusho.address2__c;
        this.address3 = seikyusakibusho.address3__c;
        this.setZipCode(seikyusakibusho.zip_code__c);
        this.pref = seikyusakibusho.pref__c;
        this.city_address = seikyusakibusho.city_address__c;
        this.building_name = seikyusakibusho.building_name__c;
        this.set_post_address = null;
        this.post_address1 = null;
        this.post_address2 = null;
        this.post_address3 = null;
        this.post_zip_code = null;
        this.post_pref = null;
        this.post_city_address = null;
        this.post_building_name = null;
        this.tel = seikyusakibusho.tel__c;
        this.email = seikyusakibusho.email__c;
        this.cc_email = seikyusakibusho.cc_email__c;
        this.memo = null;
        this.billing_method = null;
        this.issue_month = null;
        this.issue_day = null;
        this.sending_month = null;
        this.sending_day = null;
        this.deadline_month = null;
        this.deadline_day = null;
        this.payment_method_code = null;
        this.bs_owner_code = null;
        this.ref_billing_code = null;
        this.ref_individual_code = null;
        this.bill_template_code  = 10000;

        this.sub_account_title = new List<MikataBillingIndividualSubAccountTitle>();
        this.sub_account_title.add(new MikataBillingIndividualSubAccountTitle(account));
    }

    // 郵便番号設定
    public void setZipCode(String zip_code) {
        if (zip_code == null) return;
        zip_code = zip_code.replace('-', '');
        if (zip_code.length() == 0) return;
        if (!zip_code.isNumeric()) return;
        this.zip_code = Integer.valueOf(zip_code);
    }
}