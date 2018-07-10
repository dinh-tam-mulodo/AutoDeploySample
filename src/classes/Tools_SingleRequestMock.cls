@isTest
global class Tools_SingleRequestMock  implements HttpCalloutMock {
    global HttpResponse response {get;set;}
	global string calloutMethod {get;set;}
    global String jsonBody {get;set;}
    	public Tools_SingleRequestMock(){}
		global HTTPResponse respond(HTTPRequest req) {
	        response = new HttpResponse();
            response.setHeader('Content-type', 'application/json');
			response.setStatusCode(200);
            response.setBody(jsonBody);           
			return response;
	    }
}