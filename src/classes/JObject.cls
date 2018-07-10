public  class JObject {
        public Boolean selected{get; set;}
        public String objectNameAPI{get; set;}
        public String objectLabel{get; set;}
        
        public JObject(nleCalloutJSONObjects.JSONObjects obj, String currentSelectedObjects) {
            objectNameAPI = obj.name;
            objectLabel = obj.label + ' (' + obj.name + ')';
            Set<String> selectObjects = new Set<String>();
            //system.debug(currentSelectedObjects);
            if(currentSelectedObjects!=null){
                for(String str : currentSelectedObjects.split(';')){
                    selectObjects.add(str);
                }                 
            }
            if (selectObjects != null && selectObjects.contains(obj.name)) {
                selected = true;
            } else {
                selected = false;
            }
        }
}