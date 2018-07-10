public class Map_Object {
	public class ProfileUserPermission{
		public String name{get;set;}
		public List<Boolean> isChecked{get;set;}	
	}
	public class ObjectPermission
	{	
		public String objectName{get;set;}
		public Boolean isCustom{get;set;}
		public List<String> permissions {get;set;}
	}
}