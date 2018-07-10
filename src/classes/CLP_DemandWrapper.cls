/**
 * CLP_DemandWrapper.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: CLP_DemandWrapper to show visualforce　demand detail page
 */
global with sharing class CLP_DemandWrapper {
	global Boolean success;
	global String errorMessage;
	global Integer total;	
    global List<SObject> demandList;   
    public CLP_DemandWrapper()
    {
    	total = 0;
    	demandList = new List<SObject>();
    }
}