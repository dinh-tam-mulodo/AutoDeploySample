global with sharing class TG_TargetLogCC {
	@RemoteAction
	global static Map<String, Map<String, List<DataWrap>>> init(){
		Map<String, Map<String, List<DataWrap>>> myMap = new Map<String, Map<String, List<DataWrap>>>();
        List<Contact> lstContact = [ Select CreatedDate 	
                                     From Contact
                                    ORDER BY CreatedDate DESC
                                    LIMIT 1000];
        String year = '';
        String currentYear = '';
        String month = '';
        String currentMonth = '';

        DataWrap rapData;
		List<DataWrap> lstDataMonth = new List<DataWrap>();
        Map<String, List<DataWrap>> mapMonth = new Map<String, List<DataWrap>>();
        
        for(Contact cont : lstContact){
            currentYear = '' + cont.CreatedDate.year();
            System.debug('Current Year: ' + currentYear);
            if(year == '')  {
               year = currentYear;
            }
            if(year != currentYear) {
                mapMonth.put(month, lstDataMonth);
                myMap.put(year, mapMonth);
                
                // Change setting date
                year = currentYear;
                month = '';
                
                // Initializing new data.
                mapMonth = new Map<String, List<DataWrap>>();
                lstDataMonth = new List<DataWrap>();
            }
        	
            // Setting data for each month in this year
            currentMonth = '' + cont.CreatedDate.month();
            if(month =='') month = currentMonth;
            if(month != currentMonth){
                mapMonth.put(month, lstDataMonth);
                lstDataMonth = new List<DataWrap>();
                month = currentMonth;
            }
            
            // Create each record for showing.
            rapData = new DataWrap();
            rapData.dayOfMonth = cont.CreatedDate + '';
            rapData.numberOfRecord = 'month' + month;
            lstDataMonth.add(rapData);
        }

        mapMonth.put(month, lstDataMonth);
        myMap.put(year, mapMonth);

        return myMap;
	}
    
    private DataWrap createDataWrap(DateTime createdDate){
        DataWrap wrapData = new DataWrap();
        
        
        return wrapData;
    }

    public class DataWrap{
        String dayOfMonth;
        String numberOfRecord;
	}
}