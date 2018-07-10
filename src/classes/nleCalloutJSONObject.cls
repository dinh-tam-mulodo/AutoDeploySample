public class nleCalloutJSONObject {
    public String error;
    public String error_description;
    public String name {get;set;}
    public String sheetname {get;set;}
    public List<Fields> fields {get;set;} 
    public List<Tools_ValidationRuleDetail> validationRules{get;set;} 
    
    public class Fields {
        public String name {get;set;} 
        public String label {get;set;}
        public String type {get;set;} // in json: type
        //public Integer byteLength {get;set;}
        public Boolean custom {get;set;} 
        public Integer length {get;set;} 
        public String defaultValue {get;set;}  
        // lookup field
        public List<String> referenceTo {get;set;} 
        //public String relationshipName {get;set;}
        // required or not
        public Boolean nillable {get;set;}
        //public Boolean aggregatable {get;set;} 
        //public Boolean autoNumber {get;set;} 
        
        public Boolean calculated {get;set;} 
        public String calculatedFormula {get;set;} 
        public Boolean cascadeDelete {get;set;} 
        //public Boolean caseSensitive {get;set;} 
        ////public Object controllerName {get;set;} 
        //public Boolean createable {get;set;} 
        ////public Boolean custom {get;set;} 
        
        //public Object defaultValueFormula {get;set;} 
        //public Boolean defaultedOnCreate {get;set;} 
        //public Boolean dependentPicklist {get;set;} 
        //public Boolean deprecatedAndHidden {get;set;} 
        //public Integer digits {get;set;} 
        //public Boolean displayLocationInDecimal {get;set;} 
        //public Boolean encrypted {get;set;} 
        public Boolean externalId {get;set;} 
        //public String extraTypeInfo {get;set;} 
        //public Boolean filterable {get;set;} 
        ////public Object filteredLookupInfo {get;set;} 
        //public Boolean groupable {get;set;} 
        //public Boolean highScaleNumber {get;set;} 
        //public Boolean htmlFormatted {get;set;} 
        //public Boolean idLookup {get;set;} 
        ////public Object inlineHelpText {get;set;} 
        
        
        ////public Object mask {get;set;} 
        ////public Object maskType {get;set;} 
        //public Boolean nameField {get;set;} 
        
        //public Boolean namePointing {get;set;} 
        //public Boolean nillable {get;set;} 
        //public Boolean permissionable {get;set;} 
        public List<PicklistValues> picklistValues {get;set;} 
        //public Integer precision {get;set;} 
        //public Boolean queryByDistance {get;set;} 
        ////public Object referenceTargetField {get;set;} 
        ////public List<String> referenceTo {get;set;} 
        ////public String relationshipName {get;set;} 
        ////public Object relationshipOrder {get;set;} 
        //public Boolean restrictedDelete {get;set;} 
        //public Boolean restrictedPicklist {get;set;} 
        //public Integer scale {get;set;} 
        //public String soapType {get;set;} 
        //public Boolean sortable {get;set;} 
        //public String type_Z {get;set;} // in json: type
        public Boolean unique {get;set;} 
        //public Boolean updateable {get;set;} 
        //public Boolean writeRequiresMasterRead {get;set;} 
        
    }
    
    
    public Boolean activateable {get;set;} 
    public List<ChildRelationships> childRelationships {get;set;} 
    public Boolean compactLayoutable {get;set;} 
    public Boolean createable {get;set;} 
    public Boolean custom {get;set;} 
    public Boolean customSetting {get;set;} 
    public Boolean deletable {get;set;} 
    public Boolean deprecatedAndHidden {get;set;} 
    public Boolean feedEnabled {get;set;} 
    
    public String keyPrefix {get;set;} 
    public String label {get;set;} 
    public String labelPlural {get;set;} 
    public Boolean layoutable {get;set;} 
    //public Object listviewable {get;set;} 
    //public Object lookupLayoutable {get;set;} 
    public Boolean mergeable {get;set;} 
    public Boolean mruEnabled {get;set;} 
    
    //public Object networkScopeFieldName {get;set;} 
    public Boolean queryable {get;set;} 
    public List<RecordTypeInfos> recordTypeInfos {get;set;} 
    public Boolean replicateable {get;set;} 
    public Boolean retrieveable {get;set;} 
    public Boolean searchLayoutable {get;set;} 
    public List<SupportedScopes> supportedScopes {get;set;} 
    public Boolean triggerable {get;set;} 
    public Boolean undeletable {get;set;} 
    public Boolean updateable {get;set;} 
    
    public class SupportedScopes {
        public String label {get;set;} 
        public String name {get;set;}
    }
    
    public class PicklistValues {
        public Boolean active {get;set;} 
        public Boolean defaultValue {get;set;} 
        public String label {get;set;} 
        public String validFor {get;set;} 
        public String value {get;set;}
    }
    
    public class RecordTypeInfos {
        public Boolean available {get;set;} 
        public Boolean defaultRecordTypeMapping {get;set;} 
        public Boolean master {get;set;} 
        public String name {get;set;} 
        public String recordTypeId {get;set;} 
    }
    
    public class ChildRelationships {
        public Boolean cascadeDelete {get;set;} 
        public String childSObject {get;set;} 
        public Boolean deprecatedAndHidden {get;set;} 
        public String field {get;set;} 
        public String relationshipName {get;set;} 
        public Boolean restrictedDelete {get;set;}
    }
}