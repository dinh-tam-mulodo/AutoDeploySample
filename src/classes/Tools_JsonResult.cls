global class Tools_JsonResult {
	public Tools_JsonResult() {		
	}
	public Tools_JsonResult(Boolean isErr,String errMsg, List<JObject> objs, List<JProfile> pros, List<JPermissionSet> pers) {
		isError = isErr;
		errorMessage = errMsg;
		objects = objs;
		profiles = pros;
		permissionSets = pers;
	}	
	public Boolean isError{get;set;}
	public String errorMessage{get;set;}
	public List<JObject> objects{get;set;}
	public List<JProfile> profiles{get;set;}
	public List<JPermissionSet> permissionSets{get;set;}
}