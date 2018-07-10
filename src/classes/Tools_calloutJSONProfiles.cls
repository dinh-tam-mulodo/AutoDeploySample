public class Tools_calloutJSONProfiles {
	public boolean hasError;
	public String status;
	public String error;
    public String error_description;
    Attributes attribute{get;set;}
	public List<JSONProfile> records;

	public class JSONProfile {
		public String id{get;set;}
		public String name{get;set;}
		public String description{get;set;}
	}

	public class Attributes {
		public String type_Z {get;set;} // in json: type
		public String url {get;set;}
	}
}