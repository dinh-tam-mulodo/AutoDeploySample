public with sharing virtual class REC_AuthenBase {
	public String currentUser{get;set;}
	public String ipAddress{get;set;}
	public Boolean isAuthen{get;set;}

	public REC_AuthenBase() {
		system.debug('into REC_AuthenBase');
        Cookie usernameCookie = ApexPages.currentPage().getCookies().get('Rec_Username');
        Cookie passwordCookie = ApexPages.currentPage().getCookies().get('Rec_Password');

        system.debug('REC_AuthenBase - usernameCookie: ' + usernameCookie);
        if(usernameCookie != null){
            currentUser = usernameCookie.getValue();
            system.debug('currentUser: ' + currentUser);
            isAuthen = true;
        } else {
        	isAuthen = false;
        }
	}

    public void removeCookie(){
        Cookie usernameCookie = new Cookie('Rec_Username', '', null, 0, false);
        Cookie ipAdressCookie = new Cookie('Rec_IpAddress', '', null, 0, false);
        Cookie passwordCookie = new Cookie('Rec_Password', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{usernameCookie, passwordCookie, ipAdressCookie});
    }

    public PageReference logout() {
        removeCookie();
        PageReference loginPage = Page.REC_LoginPage;
        loginPage.setRedirect(true);
        return loginPage;
    }
}