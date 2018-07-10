global class CLP_LoggerDeleteScheduler implements Schedulable {
	private static final String NEW_LINE_HEX_CODE = '0D0A';
	private List<String> errors = new List<String>();

	global void execute(SchedulableContext sc) {
		//Get from custom setting
		//Decimal recordsSettingValue = setting.LogRollupRecord__c;
		Integer cumstomLogDeleteNum = 2000;//recordsSettingValue.intValue();		
		// Integer cumstomLogDeleteNum = 1;
		List<Logger__c> deleteList = 
			[select Name, Operation__c, Content__c, Origin__c,CreatedDate,CreatedBy.Name 
				from Logger__c order by CreatedDate LIMIT :cumstomLogDeleteNum ];
		if(deleteList!=null && deleteList.size()>0){
			createCsv(deleteList);
			deleteRecord(deleteList);	
		}				
	}
	private  String convertToHex(Integer num) {
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
	/**
	 *	 utf-8の文字列をwindows-31J対応の16進数文字列に変換する
	 *	定数 NON_ENCODE_STRINGS: EncodingUtil#urlEncodeでエンコードされない文字群
	 **/
	private  final List<String> hexTable = new List<String>{'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}; 
	private  final String NON_ENCODE_STRINGS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .-_*';
	public  final String CHARACTER_CODE_WIN31J = 'windows-31J';
	private String encodeWin31JHex(String value) {
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
	private  String paddingZero(Integer val, Integer length) {
		return paddingZero(String.valueOf(val), length);
	}
	private  String paddingZero(String val, Integer length) {
		String ret = val;
		if (ret != null) {
			for (Integer i = val.length(); i < length; i++) {
				ret = '0' + ret;
			}
		}
		return ret;
	}
	
	private void createCsv(List<Logger__c> records) {
		String coverText = '"';
		String seperateText = '","';
		List<String> rows = new List<String>();
		
		try {
			rows.add('"ログ", "オペレーション", "メッセージ", "発生箇所","作成日","作成者"');
			for (Logger__c record: records) {
				List<String> row = new List<String>();
				row.add(record.Name);
				row.add(record.Operation__c);
				row.add(record.Content__c);
				row.add(record.Origin__c);
				row.add(String.valueOf(record.CreatedDate) );
				row.add(record.CreatedBy.Name );
				rows.add(coverText + String.join(row, seperateText) + coverText);
			}
		} catch (Exception e) {
			errors.add('csv変換エラー: ' + e.getMessage());
		}

		if (rows.size() > 1) {
			Document doc = new Document();
			
			List<Folder> foloderList = [select Id from Folder where DeveloperName = 'FolderCustomLog'];
        	doc.FolderId = foloderList.get(0).Id;

			doc.Name = 'log' + Datetime.now().format('yyyyMMddHHmmss') + '.csv';

			String csvText = '';
			for (String row: rows) {
				if (String.isNotBlank(csvText)) {
					csvText += NEW_LINE_HEX_CODE;
				}
				csvText += encodeWin31JHex(row);
			}
			doc.Body = EncodingUtil.convertFromHex(csvText);
			
			try {
				insert doc;
			} catch(Exception e) {
				errors.add('csvの作成に失敗しました。\r\n' + e.getMessage());
			}
		} else {
			errors.add('受注情報に明細が存在しないためcsvに変換できませんでした。');
		}
	}
	
	private void deleteRecord(List<Logger__c> records) {
		delete records;
	}
}