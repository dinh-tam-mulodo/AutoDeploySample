public with sharing class WED_CommonUtil {
    public static final String ENV_PREFIX = getPrefix();
    
    public static String getPrefix(){
		String nameSpacePrefix = '';
		try{
			ApexClass cs =[SELECT NamespacePrefix FROM ApexClass WHERE Name =:'WED_CommonUtil'];
	        if(!String.isEmpty(cs.NamespacePrefix)) {
	            nameSpacePrefix = cs.NamespacePrefix + '__';
	        }
		}catch(Exception ex){
			return '';
		}
        return nameSpacePrefix;
    }
	
    // Check permision CRUD
	public enum FLSType {CREATE_OBJECT, UPDATE_OBJECT}
    public static Boolean checkFLS(String[] listUpdatedFields, FLSType type, String objectName)
    {       
        objectName = objectName.contains('__c') ? ENV_PREFIX + objectName : objectName;
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> m = objType.getDescribe().fields.getMap(); 

        if(type == FLSType.CREATE_OBJECT){
            for(String field : listUpdatedFields){                
                if(field.contains('__')){ //custom field
                    if(!m.get(ENV_PREFIX + field).getDescribe().isCreateable()){
                        return false;
                    }   
                } else { //standard field
                    if(!m.get(field).getDescribe().isCreateable()){
                        return false;
                    }
                }
            }   
        }

        if(type == FLSType.UPDATE_OBJECT){
            for(String field : listUpdatedFields){
                if(field.contains('__')){ //custom field
                    if(!m.get(ENV_PREFIX + field).getDescribe().isUpdateable()){
                        return false;
                    }   
                } else { // standard field
                    if(!m.get(field).getDescribe().isUpdateable()){
                        return false;
                    }
                }   
            }   
        }
        
        return true;
    }

    /* 
    Created Date: 01/11/17
    Create By: Minh Tuan
    Description: Count record
    */
    public static Integer countRecord(String objectName, string whereStatement){
        try{
            String query =  'SELECT count() FROM ' + String.escapeSingleQuotes(objectName) + whereStatement;
            return Database.countQuery(query);  
        }catch(Exception ex){
            return 0;
        }
    }

    /* 
    Created Date: 16/11/17
    Create By: Minh Tuan
    Description: Format header
    */
    public static String formatHeader(String format, String name){
        try{
            List<String> arguments = new List<String>();

            arguments.add(name);

            String result = String.format(format, arguments);
            return result;
        } catch (Exception ex){
            return '';
        }   
        
    }


    public static Map<String, String> settingPicklistToMap(String strPick) {
        Map<String, String> mapReturn = new Map<String, String>();

        if(!String.isEmpty(strPick)){
            List<String> lstValue = strPick.split(';');

            Integer i = 0;
            for(String item : lstValue) {           
                mapReturn.put(String.valueOf(i), item);
                i++;
            }
        }

        return mapReturn;
    }

    // Setting map to string for saving data in picklist
    public static String settingMapTopickList(Map<String, String> mapOption){
        List<String> listValue = new List<String>();
        for(String key : mapOption.keySet()) {
            //listValue.add(key + ':' + mapOption.get(key));
            listValue.add(mapOption.get(key));
        }

        return String.join(listValue, ';');
    }

    /* 
    Created Date: 1/12/17
    Create By: Minh Tuan
    Description: Get Picklist Option
    */
    public enum KeyType {ITEM, PARENT, CHILD, VALUE, INDEX, HYBRID}
    public static Map<String, String> getPicklistField(String objectName, String fieldName, KeyType typ){
        Map<String, String> result = new Map<String, String>();

        // Get object type
        objectName = objectName.contains('__c') ? ENV_PREFIX + objectName : objectName;
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        // Get object fields
        Map<String,Schema.SObjectField> m = objType.getDescribe().fields.getMap(); 
        Schema.DescribeFieldResult fieldDescription = m.get(ENV_PREFIX + fieldName).getDescribe();

        // Format picklist value
        Integer i = 0;
        for (Schema.Picklistentry picklistEntry : fieldDescription.getPicklistValues()){
            String key = getStringByKeyType(typ, i);

            String value = key + ':' + pickListEntry.getLabel();    
            result.put(String.valueOf(i), value);
            i++;
        }

        return result;
    }

    /* 
    Created Date: 1/12/17
    Create By: Minh Tuan
    Description: Get Picklist Option for Image
    */
    /*public static Map<String, String> getPicklistFieldForHybridType(String objectName, String fieldName, KeyType typ){
        Map<String, String> result = new Map<String, String>();

        objectName = objectName.contains('__c') ? ENV_PREFIX + objectName : objectName;
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Map<String,Schema.SObjectField> m = objType.getDescribe().fields.getMap(); 
        Schema.DescribeFieldResult fieldDescription = m.get(ENV_PREFIX + fieldName).getDescribe();
  
        Integer i = 0;
        Integer checkBoxIndex = 0;

        // List Image from document
        List<String> imageIndex = getImageList();
        // Total image number
        Integer maxSize = imageIndex.size();

        for (Schema.Picklistentry picklistEntry : fieldDescription.getPicklistValues()){
            String key = '';

            String label = pickListEntry.getLabel();

            Boolean isCheckbox = isCheckBoxType(label);
            // If value is checkbox type
            if (isCheckbox){
                key = getStringByKeyType(KeyType.ITEM, checkBoxIndex);
                checkBoxIndex++;

            // If value is image type    
            } else {
                Integer index = getIndexFromList(imageIndex, label);
                index = index < 0 ? maxSize++ : index;
                
                key = getStringByKeyType(KeyType.INDEX, index);
            }

            String value = key + ':' + label;   

            result.put(String.valueOf(i), value);
            i++;
        }

        return result;
    }*/

    /* 
    Created Date: 5/12/17
    Create By: Minh Tuan
    Description: Check if value is check box type
    */
    public static Boolean isCheckBoxType(String label){
        if (label.equals(WED_Constants.ANS20_ITEM1) ||
            label.equals(WED_Constants.ANS20_ITEM2) ||
            label.equals(WED_Constants.ANS20_ITEM3) ||
            label.equals(WED_Constants.ANS20_ITEM4) ||
            label.equals(WED_Constants.ANS20_ITEM5)) {
            return true;
        } else {
            return false;
        }
    }

    /* 
    Created Date: 5/12/17
    Create By: Minh Tuan
    Description: Get item index by value
    */
    public static Integer getIndexFromList(List<String> container, String value){
        Integer index = 0;
        for (String s : container){
            if (s.equals(value)){
                return index;
            }
            index ++;
        }

        return -1;
    }

    /* 
    Created Date: 5/12/17
    Create By: Minh Tuan
    Description: Get List Image from specific folder
    */
    public static List<String> getImageList(){
        List<String> result = new List<String>();

        String folderName = Label.WED_Label_FolderName;
        List<Document> currentPictures = [SELECT Id, Name FROM Document 
                                          WHERE Folder.Name =: folderName Limit 2000];

        for(Document document: currentPictures){
            result.add(document.Name);
        }       
        return result;                           
    }

    /* 
    Created Date: 4/12/17
    Create By: Minh Tuan
    Description: Create key by type
    */
    public static String getStringByKeyType(KeyType typ, Integer index){
        if (typ == KeyType.PARENT){
            return 'parent';
        } else if (typ == KeyType.CHILD){
            return 'child';
        } else if (typ == KeyType.VALUE){
            return 'value';
        } else if (typ == KeyType.INDEX){
            return String.valueOf(index);    
        } else {
            return 'item' + String.valueOf(index + 1);
        }
    }

    /* 
    Created Date: 4/12/17
    Create By: Minh Tuan
    Description: Format picklist map
    */
    public static Map<String, String> formatPicklistMap(Map<String, String> pickListMap, Map<String,String> answerMap){
        try {
            Map<String, String> formattedMap = new Map<String, String>(); 

            List<String> lstSubval = new List<String>();
            List<String> pickListValues = pickListMap.values();
            List<String> answerValues = answerMap.values();

            for(String value : answerValues){
                String formattedValue = getFormatString(pickListValues, value);

                if (String.isNotEmpty(formattedValue)){
                    if(formattedValue.contains(':')){
                        lstSubval = formattedValue.split(':');
                        formattedMap.put(lstSubval[0] , lstSubval[1]); 
                    }                   
                }
            }

            return formattedMap;
        }catch (Exception ex){
            return new Map<String, String>();
        }
    }

    /* 
    Created Date: 4/12/17
    Create By: Minh Tuan
    Description: Return formatted string if from unformatted string
    */
    public static String getFormatString(List<String> values, String rawString){
        String result ='';

        for (String s : values){
            if(s.contains(':')){
                String value = s.split(':')[1];
                if(value.equals(rawString))
              		return s;        
            }                   
        }

        return result;
    }
}