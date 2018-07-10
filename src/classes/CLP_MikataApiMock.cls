@isTest
global class CLP_MikataApiMock implements HttpCalloutMock {
    global String mockErrorMessage          {get; set;}
    global Integer statusCode               {get; set;}

    public CLP_MikataApiMock() {
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        String requestBody = req.getBody();
        CLP_BulkProductWrapper productWrapper = (CLP_BulkProductWrapper)JSON.deserializeStrict(requestBody, CLP_BulkProductWrapper.class);
        productWrapper.error_message = this.mockErrorMessage;
        for (CLP_BulkProductWrapper.Goods goodsElem : productWrapper.goods) {
            goodsElem.error_message = this.mockErrorMessage;    
        }
        String responseBody = JSON.serialize(productWrapper);

        res.setBody(responseBody);
        res.setStatusCode(this.statusCode);
        res.setStatus('Complete');
        res.setHeader('Content-type', 'application/json');
        return res;
    }
}