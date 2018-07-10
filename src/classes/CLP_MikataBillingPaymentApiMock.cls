@isTest
global class CLP_MikataBillingPaymentApiMock implements HttpCalloutMock {
    global String body          {get; set;}

    public CLP_MikataBillingPaymentApiMock(String jsonBody){
        this.body = jsonBody;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(this.body);
        res.setStatusCode(200);
        res.setStatus('Complete');
        res.setHeader('Content-type', 'application/json');
        return res;
    }

}