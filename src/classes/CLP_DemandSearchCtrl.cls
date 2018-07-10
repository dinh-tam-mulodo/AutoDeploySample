public with sharing class CLP_DemandSearchCtrl extends CMN_SearchBaseCtrl{

    private ApexPages.StandardController standardController;
    
    public CLP_DemandSearchCtrl(ApexPages.StandardController controller){
        

    }
    String[] payMethods = new String[]{};
    public List<SelectOption> getItem() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0','銀行振込'));
        options.add(new SelectOption('1','クレジットカード'));
        options.add(new SelectOption('2','バンクチェック'));
        options.add(new SelectOption('3','CP口座振替'));
        options.add(new SelectOption('4','RL口座振替'));
        options.add(new SelectOption('5','その他口座振替'));
        options.add(new SelectOption('7','コンビニ払込票（ハガキ）'));
        return options;
    }
    public String[] getPaymentMethods() {
        return payMethods;
    }
    public void setPaymentMethods(String[] payMethods) {
        this.payMethods = payMethods;
    }

    public void nextAndSaveCurrentPageNumber() {
        next();
    }
    public void previousAndSaveCurrentPageNumber() {
        previous();
    }
    public void firstAndSaveCurrentPageNumber() {
        first();
    }
    public void lastAndSaveCurrentPageNumber() {
        last();
    }
    public void setJumpSaveCurrentPageSize() {
        jump();
    }
    public void setSizeSaveCurrentPageSize() {
        changeSize();
    }

}