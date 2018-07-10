// CLOUD PAYMENT
// 経理のミカタ
// API
// 決済情報
public with sharing class MikataPayment {
    public Id code { get; private set; } // 決済情報コード(決済情報ID)
    public String name { get; private set; } // 決済情報名
    public Id bank_transfer_pattern_code { get; private set; } // 請求元銀行口座パターンコード(請求元銀行口座パターンID)
    public Integer payment_method { get; private set; } // 決済手段
    public String source_bank_account_name { get; private set; } // 振込元口座名義
    public String customer_number { get; private set; } // 顧客番号
    public Integer bank_code { get; private set; } // 銀行コード
    public String bank_name { get; private set; } // 銀行名
    public Integer branch_code { get; private set; } // 支店コード
    public String branch_name { get; private set; } // 支店名
    public Integer bank_account_type { get; private set; } // 預金種目
    public Integer bank_account_number { get; private set; } // 口座番号
    public String bank_account_name { get; private set; } // 口座名義

    // コンストラクタ
    public MikataPayment(PaymentMethod__c paymentMethod) {
        this.code = paymentMethod.Id;
        this.name = paymentMethod.Name;
        this.bank_transfer_pattern_code = paymentMethod.BillingSourceBankAccountPatternId__c;
        this.setPaymentMethod(paymentMethod.RecordType.Name);
        this.source_bank_account_name = paymentMethod.BillingSourceBankAccountName__c;
        this.customer_number = paymentMethod.CustomerNumber__c;
        this.bank_code = MikataUtil.toInteger(paymentMethod.BankCode__c);
        this.bank_name = paymentMethod.BankName__c;
        this.branch_code = MikataUtil.toInteger(paymentMethod.BranchCode__c);
        this.branch_name = paymentMethod.BranchName__c;
        this.bank_account_type = MikataUtil.toInteger(paymentMethod.BankAccountType__c);
        this.bank_account_number = MikataUtil.toInteger(paymentMethod.BankAccountNumber__c);
        this.bank_account_name = paymentMethod.BankAccountName__c;
    }

    // 決済手段を設定する
    private void setPaymentMethod(String recordTypeName) {
        if (String.isNotBlank(recordTypeName)) {
            // 「番号:<レコードタイプ名>」の番号の部分を設定する
            String recordTypeNumber = recordTypeName.substringBefore(':');

            if (String.isNotBlank(recordTypeNumber)) {
                this.payment_method = Integer.valueOf(recordTypeNumber);
            }
        }
    }
}