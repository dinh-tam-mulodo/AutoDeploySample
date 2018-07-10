public with sharing class REC_MainPageCC extends REC_AuthenBase{
	public PageReference authen() {
		system.debug('into authen');
		if(IsAuthen) {
			system.debug('authen - already authen');
			return null;
		} else {
			system.debug('authen - not authen yet');
			PageReference loginPage = Page.REC_LoginPage;
			loginPage.setRedirect(true);
			return loginPage;
		}
	}
}