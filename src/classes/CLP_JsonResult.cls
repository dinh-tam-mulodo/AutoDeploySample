/**
 * CLP_JsonResult.
 * @author Mulodo Inc.
 * @version 1.0
 * @Description: return json result
 */
global with sharing class CLP_JsonResult {
	global CLP_JsonResult() {
	}
	global CLP_JsonResult(Boolean suc, Object res, String err) {
		success = suc;
		response = res;
		errorMessage = err;
	}
	global Boolean success {get;set;}
	global Object response {get;set;}
	global String errorMessage {get;set;}
}