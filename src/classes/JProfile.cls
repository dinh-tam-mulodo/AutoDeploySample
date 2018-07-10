public with sharing class JProfile {
	public Boolean selected{get; set;}
		public String id {get;set;}
        public String name{get; set;}
        public String description{get; set;}        
       
        public JProfile(Tools_calloutJSONProfiles.JSONProfile obj, String selectedProfiles) {
        	id = obj.Id;
            name = obj.name;
            description = obj.description;
            Set<String> profiles = new Set<String>();
            //system.debug(currentSelectedObjects);
            if(selectedProfiles!=null){
                for(String str : selectedProfiles.split(';')){
                    profiles.add(str);
                }                 
            }
            if (profiles != null && profiles.contains(obj.id)) {
                selected = true;
            } else {
                selected = false;
            }
        }
}