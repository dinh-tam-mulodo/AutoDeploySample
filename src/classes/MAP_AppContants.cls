public with sharing class MAP_AppContants {
	 public static final String API_URL_FORMAT = '{0}?app={1}&fl=hpurl,hpurlnor,pageurl,pageurlnor,orgid,shogonor,gyoshu,add,addnor,emp,pub,tel,zip,fax,compno,mail,shihon,pref,revenue&q=*%20AND%20(pageitem:%EF%BC%91%EF%BC%8E%E4%BC%81%E6%A5%AD%E6%A6%82%E8%A6%81)&fq=({2})';
	 public static final Integer MAXIMUM_ITEM_PER_REQUEST = 500;
	 public static final String DISPLAY_FIELD = 'ShowFields';
	 public static final String HIDDEN_FIELD = 'HideFields';
	 public static final String APP_PREFIX = MAP_CommonUtil.getPrefix();
	 public static final String OBJ_TARGET_COMPANY = APP_PREFIX + 'MAP_TargetCompany__c';
	 public static final String FIELD_DISABLE_MAPPING  = 'MAPlusTfI';
	 public static final String FIELD_LASTNAME_MAPPING  = APP_PREFIX + 'LastName';
}