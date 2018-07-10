/*
* MF_TrafficFeeCC
* Add traffic receipt fee list
*/
global class MF_TrafficFeeCC extends MF_UserAuthentication {
    public Contact contact{get;set;}
    public String uiTheme{get;set;}
    public MF_TrafficFeeCC(){
        //check login
        if (MF_UserAuthentication.cookieContactId != null){
          contact = checkUsernameExist(MF_UserAuthentication.cookieContactId);
          //check device
          uiTheme = UserInfo.getUiThemeDisplayed();
        }
    }
    /*
    * checkUsernameExist
    * check to get contact of user logged
    */
    public static Contact checkUsernameExist(id idContact){
        List<Contact> checkList = [SELECT Id, name, Username__c, EmployeeNo__c  FROM Contact WHERE id  = :idContact];
        if(checkList.size() > 0){
            return checkList[0];
        }
        return null;
    }

    /*
    * @RemoteAction
    * getListVehicle
    * get list vehicle
    */
    @RemoteAction
    global static List<MF_Vehicle__c> getListVehicle()  {
        List<MF_Vehicle__c> vehicleList = [SELECT Id, Name FROM MF_Vehicle__c];
        return vehicleList;
    }

    /*
    * @RemoteAction
    * getListPlace
    * get list location for depart and arrive on traffic receipts
    */
    @RemoteAction
    global static List<MF_Place__c> getListPlace()  {
        List<MF_Place__c> placeList = [SELECT Id, Name FROM MF_Place__c];
        return placeList;
    }

    /*
    * @RemoteAction
    * getAllAccount
    * get list account
    */
    @RemoteAction
    global static List<Account> getAllAccount() {
        List<Account> accounts= [Select Name,Id from Account];
        return accounts;
    }
}