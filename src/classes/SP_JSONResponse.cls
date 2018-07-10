global with sharing class SP_JSONResponse {
	global SP_JSONResponse() {
	}

	global SP_JSONResponse(String erCode, String err) {
		message = err;
        code = erCode;		
	}

	global String code    {get;set;}
	global String message {get;set;}
}