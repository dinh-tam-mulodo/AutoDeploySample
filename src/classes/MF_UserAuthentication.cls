public virtual class MF_UserAuthentication {

    public static String cookieContactId{
        get{
           return MF_CookieUtil.getCookieValue(MF_CookieUtil.COOKIE_CONTACT_ID);
        }
        set;
    }
    
    public pagereference userAuthentication(){
        system.debug(cookieContactId);
        if(cookieContactId == null || cookieContactId == ''){
            return logout();
        }
        return null;
    }
    
    public static pagereference logout(){
        System.debug('Entering logout in userAuthentication');
        MF_CookieUtil.clearCookies();
        //return new PageReference( '/secur/logout.jsp');
        PageReference loginPage = new PageReference('/apex/MF_Login');
        loginPage.setRedirect(true);
        return loginPage;
    }
}