/**
 * CLP_LoggerUtil.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: Common CLP_Logger class
 */
public with sharing class CLP_LoggerUtil {
    private static final String NEW_LINE_HEX_CODE = '0D0A';
    public static List<String> errors = new List<String>();
    private static String convertToHex(Integer num) {
        String ret;
        Integer value = num;
        if (value != null) {
            String temp = '';
            while (value > 0) {
                temp = hexTable.get(Math.mod(value, 16)) + temp;
                value = value/16;
            }
            ret = temp;
        }
        return ret;
    }
    private static  final List<String> hexTable = new List<String>{'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}; 
    private static  final String NON_ENCODE_STRINGS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .-_*';
    public static  final String CHARACTER_CODE_WIN31J = 'windows-31J';
    private static String encodeWin31JHex(String value) {
        String ret = null;
        if (value != null) {
            String hexCodes = '';
            Integer len = value.length();
            for (Integer i = 0; i < len; i++) {
                String charStr = value.substring(i, i + 1);
                if (NON_ENCODE_STRINGS.indexOf(charStr) >= 0) {
                    String hex = convertToHex(charStr.codePointAt(0));
                    charStr = paddingZero(hex, 2);
                }
                hexCodes += charStr;
            }
            ret = (EncodingUtil.urlEncode(hexCodes,CHARACTER_CODE_WIN31J)).replaceAll('%','');
        }
        return ret;
    }
    private static  String paddingZero(Integer val, Integer length) {
        return paddingZero(String.valueOf(val), length);
    }
    private static  String paddingZero(String val, Integer length) {
        String ret = val;
        if (ret != null) {
            for (Integer i = val.length(); i < length; i++) {
                ret = '0' + ret;
            }
        }
        return ret;
    }
    
    // create csv log
    public static Id createCsv(List<Logger__c> records) {
        String coverText = '"';
        String seperateText = '","';
        List<String> rows = new List<String>();
        
        try {
            rows.add('"発生箇所","コンテンツ","リクエスト","レスポンス","作成日","作成者"');
            for (Logger__c record: records) {
                List<String> row = new List<String>();
                row.add(record.Origin__c);
                row.add(record.Content__c);
                row.add(record.Request__c);
                row.add(record.Response__c);
                row.add(String.valueOf(record.CreatedDate));
                row.add(record.LK_RelatedUser__r.Name );
                rows.add(coverText + String.join(row, seperateText) + coverText);
            }
        } catch (Exception e) {
            errors.add('csv変換エラー: ' + e.getMessage());
            system.debug('errors:'+errors);
            throw e;
            return null;
        }

        if (rows.size() > 1) {
            // get first row data
            Logger__c logger = records.get(0);

            String logName = string.format('請求管理ロボ_{0}_連携ログ_{1}_{2}.csv',
                            new String[]{
                                logger.Origin__c,
                                Datetime.now().format('yyyyMMddHHmmss'),
                                logger.LK_RelatedUser__r.Name
                            });
            Document doc = new Document();
            
            List<Folder> folderList = [select Id from Folder where DeveloperName = 'FolderCustomLog'];
            doc.FolderId = folderList.get(0).Id;

            doc.Name = logName;

            String csvText = '';
            for (String row: rows) {
                if (String.isNotBlank(csvText)) {
                    csvText += NEW_LINE_HEX_CODE;
                }
                csvText += encodeWin31JHex(row);
            }
            doc.Body = EncodingUtil.convertFromHex(csvText);
            
            try {
                String[] listField = new String[]{'FolderId','Name','Body'};
                if(CLP_CommonUtil.checkFLS('Document',listField, CLP_CommonUtil.FLSType.CREATE_OBJECT)){
                    insert doc;
                }
                return doc.Id;
            } catch(Exception e) {
                errors.add('csvの作成に失敗しました。\r\n' + e.getMessage());
                system.debug('errors:'+errors);
                throw e;
                return null;
            }
        } else {
            errors.add('受注情報に明細が存在しないためcsvに変換できませんでした。');
            system.debug('errors:'+errors);
            return null;
        }
    }
    // delete logs
    public static void deleteLogs(List<Logger__c> records){
        //check delete
        if (Logger__c.sObjectType.getDescribe().isDeletable()) {
            delete records;
        }
    }
    // delete document
    public static void deleteDocument(Id docId){
        List<Document> docs = [Select Id from Document where Id =: docId];
        if (Document.sObjectType.getDescribe().isDeletable()) {
            delete docs;
        } 
    }
    // send email log to related user
    public static void sendEmail(Id documentId,Id userId,EmailTemplate emailTemplate,Map<String,String> keyMaps){
        try{
            //initial email to send
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddressList = new List<String>();
            if(!String.isBlank(CLP_MikataConstant.mikataConfig.NotifyTo1__c))
                toAddressList.add(CLP_MikataConstant.mikataConfig.NotifyTo1__c);
            if(!String.isBlank(CLP_MikataConstant.mikataConfig.NotifyTo2__c))
                toAddressList.add(CLP_MikataConstant.mikataConfig.NotifyTo2__c);
            if(!String.isBlank(CLP_MikataConstant.mikataConfig.NotifyTo3__c))
                toAddressList.add(CLP_MikataConstant.mikataConfig.NotifyTo3__c);
            if(!toAddressList.isEmpty())
                mail.setToAddresses(toAddressList);
            mail.setCharset('Shift-JIS');
            mail.setSubject(emailTemplate.Subject);
            mail.setTargetObjectId(userId);
            mail.setSaveAsActivity(false);
            mail.setEntityAttachments(new Id[]{documentId});
            String body = emailBinding(emailTemplate.Body,keyMaps);
            mail.setPlainTextBody(body);
            //send email
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
        }catch(Exception ex){
            throw ex;
        } 
    }

    // binding data into email
    private static String emailBinding(String emailBody,Map<String,String> keyMaps){
        for(String key : keyMaps.keyset()){
            emailBody = emailBody.replace(key,keyMaps.get(key));
        }
        return emailBody;
    }
}