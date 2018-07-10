global with sharing class MAP_CompanyUpload {
    
    //Load Data from file csv
    @RemoteAction
    global static String loadData(String jsonString) {
        List<CsvObject> lstCsv = (List<CsvObject>)JSON.deserialize(jsonString, List<CsvObject>.class);
        for(CsvObject record : lstCsv){
            system.debug(record);
        }
        return JSON.serialize(lstCsv);
        //
    }

    // parse search condition
	public class CsvObject{
        public String name;
        public String accountName;
        public String closeDate;
        public String stage;
    }
}