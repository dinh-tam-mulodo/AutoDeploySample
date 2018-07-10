// CLOUD PAYMENT
// 経理のミカタ
// API
// 請求書
public with sharing class MikataBill {
    public Id code { get; private set; } // 請求書コード
    public String billing_code { get; private set; } // 請求先コード
    public String message_column { get; private set; } // 通信欄
    public String sending_scheduled_date { get; private set; } // 請求送付予定日
    public String sending_date { get; private set; } // 請求書送付日
    public String transfer_deadline { get; private set; } // 決済期限
    public Integer payment_status { get; private set; } // 消込ステータス
    public String erasure_deposit_date { get; private set; } // 消込計上日
    public String erasure_cancel_date { get; private set; } // キャンセル計上日
    public String memo { get; private set; } // メモ

    // コンストラクタ
    public MikataBill(Bill__c bill) {
        this.code = bill.Id;
        this.billing_code = bill.AccountId__c;
        this.message_column = bill.MessageColumn__c;
        this.sending_scheduled_date = null;
        this.sending_date = null;
        this.transfer_deadline = MikataUtil.dateString(bill.PaymentDeadlineDate__c);
        this.payment_status = Integer.valueOf(bill.PaymentStatus__c);
        this.erasure_deposit_date = null;
        this.erasure_cancel_date = null;
        this.memo = null;
    }
}