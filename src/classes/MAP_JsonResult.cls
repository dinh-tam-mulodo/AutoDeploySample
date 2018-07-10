global with sharing class MAP_JsonResult {
	global MAP_JsonResult() {
	}
	global MAP_JsonResult(Boolean suc, Object res, String err) {
		success = suc;
		response = res;
		errorMessage = err;
	}

	global MAP_JsonResult(Boolean suc, Object res, String err, List<String> lstFail) {
		success = suc;
		response = res;
		errorMessage = err;
		listFail = lstFail;
	}

	global Boolean success {get;set;}
	global Object response {get;set;}
	global String errorMessage {get;set;}
	global List<String> listFail {get;set;}
}