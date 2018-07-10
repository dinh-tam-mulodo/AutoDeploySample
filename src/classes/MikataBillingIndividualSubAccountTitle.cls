// CLOUD PAYMENT
// 経理のミカタ
// API
// 請求先部署補助科目コード
public with sharing class MikataBillingIndividualSubAccountTitle {
    public String account_receivable_code { get; private set; } // 請求先部署売掛金補助科目コード
    public String advances_received_code { get; private set; } // 請求先部署前受金補助科目コード
    public String suspense_received_code { get; private set; } // 請求先部署仮受金補助科目コード

    // コンストラクタ
    public MikataBillingIndividualSubAccountTitle(Account account) {
        this.account_receivable_code = account.AccountReceivableSubAccountTitleCode__c;
        this.advances_received_code = account.AdvanceReceivedSubAccountTitleCode__c;
        this.suspense_received_code = account.SuspenseReceiptSubAccountTitleCode__c;
    }
}