global with sharing class MF_ListSObject {
	global Integer total;
    global List<SObject> externalList;

    public MF_ListSObject()
    {
    	total = 0;
    	externalList = new List<SObject>();
    }
}