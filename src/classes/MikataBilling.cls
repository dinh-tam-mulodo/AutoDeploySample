// CLOUD PAYMENT
// 経理のミカタ
// API
// 請求先
public with sharing class MikataBilling {
    public Id code { get; private set; } // 請求先コード(取引先ID)
    public String name { get; private set; } // 請求先名
    public List<MikataBillingIndividual> individual { get; private set; } // 請求先部署
    public List<MikataPayment> payment { get; private set; } // 決済情報

    // コンストラクタ
    public MikataBilling(Account account) {
        this.code = account.Id;
        this.name = account.Name;
        this.individual = new List<MikataBillingIndividual>();

        for (Seikyusakibusho__c seikyusakibusho : account.Seikyusakibusho__r) {
            this.individual.add(new MikataBillingIndividual(account, seikyusakibusho));
        }

        this.payment = new List<MikataPayment>();

        for (PaymentMethod__c payment : account.PaymentMethods__r) {
            this.payment.add(new MikataPayment(payment));
        }
    }
}