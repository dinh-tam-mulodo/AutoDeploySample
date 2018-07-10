// return json result
global with sharing class JsonResult {
	global JsonResult() {		
	}
	global JsonResult(Boolean suc, Object res,String err) {
		success = suc;
		response = res;
		errorMessage = err;		
	}
	global Boolean success{get;set;}
	global Object response{get;set;}
	global String errorMessage {get;set;}
}