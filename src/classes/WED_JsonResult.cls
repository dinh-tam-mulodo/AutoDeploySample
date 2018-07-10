global with sharing class WED_JsonResult {
	global WED_JsonResult() {
	}

	global WED_JsonResult(Boolean suc, Object res, String err) {
		success = suc;
		response = res;
		errorMessage = err;
	}

	global Boolean success {get;set;}
	global Object response {get;set;}
	global String errorMessage {get;set;}
}