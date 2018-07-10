public class MF_CookieUtil {
    public static String COOKIE_PREFIX = 'mf_';
 	public static String COOKIE_CONTACT_ID = 'mf_contactId';
    public static String COOKIE_PATH = '/';
    public static String COOKIE_TRAFFIC_RECEIPT_LIST = 'mf_cookie_traffic_receipts';
    
    public static String getCookieValue(String cookieName){
        Cookie cookie = ApexPages.currentPage().getCookies().get(cookieName);
        if(cookie != null){
            return cookie.getValue();
        }
        return null;
    }
    public static Cookie setCookieValue(String cookieName, String value, String path, Boolean isSecure){
        Cookie newCookie = new Cookie(cookieName, value ,path,-1, isSecure);
        ApexPages.currentPage().setCookies(new Cookie[]{newCookie});
        System.debug(ApexPages.currentPage());
        return newCookie;
    }
    
    public static void clearCookies(){
        Map<String, Cookie> siteCookies = ApexPages.currentPage().getCookies();
		List<Cookie> cookies = new List<Cookie>();
        for(String key: siteCookies.keySet()){
            Cookie ck = siteCookies.get(key);
            if(ck.getName().contains(COOKIE_PREFIX)){
                cookies.add(new Cookie(ck.getName(), ck.getValue() ,ck.getPath(),0, ck.isSecure()));
            }
        }
        ApexPages.currentPage().setCookies(cookies);
    }
}