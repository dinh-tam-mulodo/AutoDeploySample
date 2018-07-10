@isTest
global with sharing class CLP_MikataDemandMock implements HttpCalloutMock {
	global String body;
	global CLP_MikataDemandMock(){
		body = '';
		system.assert(String.IsBlank(body));
	}
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(body);
        res.setStatusCode(200);
        system.assert(res.getStatusCode()==200);
        return res;
    }
}