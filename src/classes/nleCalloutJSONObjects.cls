public with sharing class nleCalloutJSONObjects {
	public boolean hasError;
	public String status;
	public String error;
    public String error_description;

	public List<JSONObjects> sobjects;

	public class JSONObjects {
		public String label;
		public String name;
		public Urls urls;
	}

	public class Urls {
		public String jobject;//sobject;
	}
}