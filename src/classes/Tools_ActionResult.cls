global with sharing class Tools_ActionResult {
	// return success or failed from controller
	public Boolean isSuccess {get;set;}
	// data to return on visualforce page
	public Object data {get;set;}
	// custom message to raise into UI
	public String[] errorMessage {get;set;}

	global Tools_ActionResult(Boolean success, Object obj, String[] msg) {
		this.isSuccess = success;
		this.data = obj;
		this.errorMessage = msg;
	}
}