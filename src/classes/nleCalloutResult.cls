public with sharing class nleCalloutResult {
	public boolean hasError;
	public String error_message;
	public String status;
	public Object data;

	public nleCalloutResult(String status) {
		this.status = status;
		this.hasError = false;
		this.error_message = '';
	}
}