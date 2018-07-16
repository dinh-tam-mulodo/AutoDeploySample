// tam test
public class API_Wrapper{
	public List<Members> members {get; set;}
	public String list_id {get; set;}
	public Integer total_items {get; set;}

	public API_Wrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'members') {
						members = arrayOfMembers(parser);
					} else if (text == 'list_id') {
						list_id = parser.getText();
					} else if (text == 'total_items') {
						total_items = parser.getIntegerValue();
					} else {
						System.debug(LoggingLevel.WARN, 'API_Wrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					} 
				}
			}
		}
	}

	public class Members{
		public String id_i {get; set;}
		public String email_address {get; set;}
		public String unique_email_id {get; set;}
		public String email_type {get; set;}
		public String status {get; set;}
		public Merge_fields merge_fields {get; set;}
		public Interests interests {get; set;}
		public Stats stats {get; set;}
		public String ip_signup {get; set;}
		public String timestamp_signup {get; set;}
		public String ip_opt {get; set;}
		public String timestamp_opt {get; set;}
		public Integer member_rating {get; set;}
		public String last_changed {get; set;}
		public String language {get; set;}
		public Boolean vip {get; set;}
		public String email_client {get; set;}
		public Location location {get; set;}
		public String list_id {get; set;}
		public List<Links> x_links {get; set;}

		public Members(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id_i = parser.getText();
						} else if (text == 'email_address') {
							email_address = parser.getText();
						} else if (text == 'unique_email_id') {
							unique_email_id = parser.getText();
						} else if (text == 'email_type') {
							email_type = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'merge_fields') {
							merge_fields = new Merge_fields(parser);
						} else if (text == 'interests') {
							interests = new Interests(parser);
						} else if (text == 'stats') {
							stats = new Stats(parser);
						} else if (text == 'ip_signup') {
							ip_signup = parser.getText();
						} else if (text == 'timestamp_signup') {
							timestamp_signup = parser.getText();
						} else if (text == 'ip_opt') {
							ip_opt = parser.getText();
						} else if (text == 'timestamp_opt') {
							timestamp_opt = parser.getText();
						} else if (text == 'member_rating') {
							member_rating = parser.getIntegerValue();
						} else if (text == 'last_changed') {
							last_changed = parser.getText();
						} else if (text == 'language') {
							language = parser.getText();
						} else if (text == 'vip') {
							vip = parser.getBooleanValue();
						} else if (text == 'email_client') {
							email_client = parser.getText();
						} else if (text == 'location') {
							location = new Location(parser);
						} else if (text == 'list_id') {
							list_id = parser.getText();
						} else if (text == '_links') {
							x_links = arrayOfLinks(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Members consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	private static List<Members> arrayOfMembers(System.JSONParser p) {
		List<Members> res = new List<Members>();
		if (p.getCurrentToken() == null) p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new Members(p));
		}
		return res;
	}

	public class Merge_fields{
		public String FBLINK {get; set;}
		public String AGE {get; set;}
		public String CPUNSUB {get; set;}
		public String STOLASTRAN {get; set;}
		public String STOCKSTT {get; set;}
		public String BONDSCF {get; set;}
		public String FUNDLASBUY {get; set;}
		public String BONDLASBUY {get; set;}
		public String BOND1STBUY {get; set;}
		public String FLELASCAOU {get; set;}
		public String FLELASCAIN {get; set;}
		public String CLASS_Z {get; set;}
		public String BONDSTT {get; set;}
		public String FUNDSTT {get; set;}
		public String FUND105STT {get; set;}
		public String INDSEGMENT {get; set;}
		public String VSD105STT {get; set;}
		public String AGENTRM {get; set;}
		public String BONDCUSTYP {get; set;}
		public String GENDER {get; set;}
		public String CRMID {get; set;}
		public String TCBSID {get; set;}
		public String FUNDPRFM {get; set;}
		public String SOUSEG {get; set;}
		public String DOB {get; set;}
		public String EXITDATE {get; set;}
		public String TODAY {get; set;}
		public String CPATTENDIN {get; set;}
		public String LNAME {get; set;}
		public String FNAME {get; set;}

		public Merge_fields(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'FBLINK') {
							FBLINK = parser.getText();
						} else if (text == 'AGE') {
							AGE = parser.getText();
						} else if (text == 'CPUNSUB') {
							CPUNSUB = parser.getText();
						} else if (text == 'STOLASTRAN') {
							STOLASTRAN = parser.getText();
						} else if (text == 'STOCKSTT') {
							STOCKSTT = parser.getText();
						} else if (text == 'BONDSCF') {
							BONDSCF = parser.getText();
						} else if (text == 'FUNDLASBUY') {
							FUNDLASBUY = parser.getText();
						} else if (text == 'BONDLASBUY') {
							BONDLASBUY = parser.getText();
						} else if (text == 'BOND1STBUY') {
							BOND1STBUY = parser.getText();
						} else if (text == 'FLELASCAOU') {
							FLELASCAOU = parser.getText();
						} else if (text == 'FLELASCAIN') {
							FLELASCAIN = parser.getText();
						} else if (text == 'CLASS') {
							CLASS_Z = parser.getText();
						} else if (text == 'BONDSTT') {
							BONDSTT = parser.getText();
						} else if (text == 'FUNDSTT') {
							FUNDSTT = parser.getText();
						} else if (text == 'FUND105STT') {
							FUND105STT = parser.getText();
						} else if (text == 'INDSEGMENT') {
							INDSEGMENT = parser.getText();
						} else if (text == 'VSD105STT') {
							VSD105STT = parser.getText();
						} else if (text == 'AGENTRM') {
							AGENTRM = parser.getText();
						} else if (text == 'BONDCUSTYP') {
							BONDCUSTYP = parser.getText();
						} else if (text == 'GENDER') {
							GENDER = parser.getText();
						} else if (text == 'CRMID') {
							CRMID = parser.getText();
						} else if (text == 'TCBSID') {
							TCBSID = parser.getText();
						} else if (text == 'FUNDPRFM') {
							FUNDPRFM = parser.getText();
						} else if (text == 'SOUSEG') {
							SOUSEG = parser.getText();
						} else if (text == 'DOB') {
							DOB = parser.getText();
						} else if (text == 'EXITDATE') {
							EXITDATE = parser.getText();
						} else if (text == 'TODAY') {
							TODAY = parser.getText();
						} else if (text == 'CPATTENDIN') {
							CPATTENDIN = parser.getText();
						} else if (text == 'LNAME') {
							LNAME = parser.getText();
						} else if (text == 'FNAME') {
							FNAME = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Merge_fields consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Interests{
		public Boolean n_455d65a703 {get; set;}
		public Boolean n_798c34ce92 {get; set;}
		public Boolean n_58854222e3 {get; set;}
		public Boolean n_9abda1e5f6 {get; set;}

		public Interests(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == '455d65a703') {
							n_455d65a703 = parser.getBooleanValue();
						} else if (text == '798c34ce92') {
							n_798c34ce92 = parser.getBooleanValue();
						} else if (text == '58854222e3') {
							n_58854222e3 = parser.getBooleanValue();
						} else if (text == '9abda1e5f6') {
							n_9abda1e5f6 = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Interests consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Stats{
		public Integer avg_click_rate {get; set;}
		public Decimal avg_open_rate {get; set;}

		public Stats(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'avg_click_rate') {
							avg_click_rate = parser.getIntegerValue();
						} else if (text == 'avg_open_rate') {
							avg_open_rate = parser.getDecimalValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Stats consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Location{
		public String timezone {get; set;}
		public String country_code {get; set;}
		public Integer dstoff {get; set;}
		public Integer gmtoff {get; set;}
		public Decimal longitude {get; set;}
		public Decimal latitude {get; set;}

		public Location(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'timezone') {
							timezone = parser.getText();
						} else if (text == 'country_code') {
							country_code = parser.getText();
						} else if (text == 'dstoff') {
							dstoff = parser.getIntegerValue();
						} else if (text == 'gmtoff') {
							gmtoff = parser.getIntegerValue();
						} else if (text == 'longitude') {
							longitude = parser.getDecimalValue();
						} else if (text == 'latitude') {
							latitude = parser.getDecimalValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Location consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Links{
		public String rel {get; set;}
		public String href {get; set;}
		public String method {get; set;}
		public String targetSchema {get; set;}
		public String schema {get; set;}

		public Links(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'rel') {
							rel = parser.getText();
						} else if (text == 'href') {
							href = parser.getText();
						} else if (text == 'method') {
							method = parser.getText();
						} else if (text == 'targetSchema') {
							targetSchema = parser.getText();
						} else if (text == 'schema') {
							schema = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Links consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	private static List<Links> arrayOfLinks(System.JSONParser p) {
		List<Links> res = new List<Links>();
		if (p.getCurrentToken() == null) p.nextToken();
		while (p.nextToken() != System.JSONToken.END_ARRAY) {
			res.add(new Links(p));
		}
		return res;
	}

	public static API_Wrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new API_Wrapper(parser);
	}
	
public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT ||
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
}