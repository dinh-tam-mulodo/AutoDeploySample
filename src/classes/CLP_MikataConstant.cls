/**
 * CLP_MikataConstant
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: Constant value using for MikataApi class
 */
public with sharing class CLP_MikataConstant {
	public static MikataConfig__c mikataConfig = MikataConfig__c.getInstance(getProfileAdmin())!=null
			? MikataConfig__c.getInstance(getProfileAdmin()) 
			: new MikataConfig__c();
	public static String ERROR_DONTHAVE_PERMISSION = 'エラー：このユーザは権限がありません。';
	// unify flag can't edit
	public static final String[] UNIFY_FLAG = new String[]{CLP_CommonUtil.ENV_PREFIX + 'ManipulateStatus__c'
														   ,CLP_CommonUtil.ENV_PREFIX + 'IsIntegrated__c'
														   ,CLP_CommonUtil.ENV_PREFIX + 'IsStop__c'
														   ,CLP_CommonUtil.ENV_PREFIX + 'StopFlg__c'
														   ,CLP_CommonUtil.ENV_PREFIX + 'DemandDetailCode__c'
														   ,CLP_CommonUtil.ENV_PREFIX + 'PeriodStartDate__c'
														   ,CLP_CommonUtil.ENV_PREFIX + 'PeriodEndDate__c'
														};	
	// demand manipulate status
	public static final String DEMAND_IN_EDIT = '0'; //作成中
	public static final String DEMAND_DATA_DEFECT = '1'; //連携成功 
	public static final String DEMAND_LINK_AWAITING = '2'; //連携待ち
	public static final String DEMAND_LINK_SUCCESS = '3'; //データ不備
	public static final String DEMAND_FAILED_DATA_DEFECT = '4'; //連携失敗（データ不備）
	public static final String DEMAND_FAILED_INTERFACE = '5'; //連携失敗（通信エラー）

	// product.StopFlg__c	
	public static final String FLG_STOP = '0'; // stop flag
	public static final String FLG_DELETE = '1'; // delete flag

	// MikataInteBuffer__c SObjectType__c
	public static final String SOBJECT_PRODUCT = 'Product2';
	public static final String SOBJECT_DEMAND_DETAIL = 'DemandDetail__c';
	public static final String SOBJECT_LOGGER = 'Logger__c';
	public static final String SOBJECT_BUFFER = 'MikataInteBuffer__c';
	public static final String SOBJECT_BILL_INDIVIDUAL = 'Seikyusakibusho__c';
	public static final String SOBJECT_PAYMENT_METHOD = 'PaymentMethod__c';
	public static final String SOBJECT_ACCOUNT = 'Account';
	public static final String SOBJECT_BILL = 'Bill__c';
	public static final String SOBJECT_BILL_DETAIL = 'BillDetail__c';
	public static final String SOBJECT_LAST_REFERENCE = 'LastReference__c';

	// PaymentMethod__c.PaymentMethod__c	
	public static final String PM_BANK_TRANSFER = '0';
	public static final String PM_CREDIT_CARD = '1';
	public static final String PM_BANK_CHECK = '2';
	public static final String PM_CP_ACCOUNT_TRANSFER = '3';
	public static final String PM_RL_ACCOUNT_TRANSFER = '4';
	public static final String PM_OTHER_ACCOUNT_TRANSFER = '5';
	public static final String PM_PAYMENT_SLIP = '7';

	// PaymentMethod__c.RegisterStatus__c	
	public static final String PM_UNREGISTERED = '0';
	public static final String PM_PENDING = '1';
	public static final String PM_MAIL_SENT = '2';
	public static final String PM_IN_APPLICATION = '3';
	public static final String PM_INFORMATION_ERROR = '4';
	public static final String PM_COMPLETE = '5';
	public static final String PM_FAILURE = '6';

	// get profile administartor
    private static Id getProfileAdmin(){
        Profile p = [select Id from Profile where Name = 'System Administrator' OR Name = 'システム管理者'];
        return p.Id;
    }
}