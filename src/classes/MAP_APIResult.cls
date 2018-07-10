global with sharing class MAP_APIResult {
	public Boolean isSuccess;
    public Response response;
    public String errorMessage;
    public Integer countNewCompany;

	public class Response {
	    public Integer numFound;
	    public Integer start;
	    public Decimal maxScore;
        public List<Doc> docs {get; set;}
	}

	public class Doc {
		// custom field
		public Boolean isExist;
		public String accountId;
		// Sorl field
	    public String id;
	    public String pageurl;
	    public String pageurlnor;
	    public String pageitem;
	    public String[] pagecat;
	    public String title;
	    public String[] tel;
	    public String[] fax;
	    //public Datetime pagedate;
	    //public String update_Z;
	    public String orgid;
	    public String[] shogo;
	    public String[] shogonor;
	    public String gyoshu{get; set;}
	    public String[] gyoshu_facet;
	    public String shihon{get; set;}
	    public String emp{get; set;}
	    public String revenue;
	    public String pub;
	    public String ceo;
	    public String seturitu;
	    public String[] pref;
	    public String[] bumon;
	    public String[] add;
	    public String[] addnor;
	    public String[] citycode;
	    public String[] zip;
	    public String hpurl;
	    public String hpurlnor;
	    public String compno;
	    public String[] pagetext;
	    public String gpageurl;
	    public String[] gpagetext;
	    public String mail;
	}    
}