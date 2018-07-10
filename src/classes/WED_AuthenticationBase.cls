public with sharing virtual class WED_AuthenticationBase {
	public String currentUser{get;set;}
	public String ipAddress{get;set;}
	public Boolean isAuthenticated{get;set;}

	public WED_AuthenticationBase() {
		CheckAuthentication();
	}

    public void CheckAuthentication(){
        Cookie usernameCookie = ApexPages.currentPage().getCookies().get('Wed_Username');
        Cookie passwordCookie = ApexPages.currentPage().getCookies().get('Wed_Password');

        system.debug('Wed_AuthenBase - usernameCookie: ' + usernameCookie);
        if(usernameCookie != null){
            currentUser = usernameCookie.getValue();
            system.debug('currentUser: ' + currentUser);
            isAuthenticated = true;
        } else {
            isAuthenticated = false;
        }
    }



	public void removeCookie(){
        Cookie usernameCookie = new Cookie('Wed_Username', '', null, 0, false);
        Cookie ipAdressCookie = new Cookie('Wed_IpAddress', '', null, 0, false);
        Cookie passwordCookie = new Cookie('Wed_Password', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie, passwordCookie, ipAdressCookie});
    }

    public PageReference logout() {
        removeCookie();
        PageReference loginPage = Page.WED_LoginPage;
        loginPage.setRedirect(true);
        return loginPage;
    }
}