public class ContactQuery {
	public List<Contact> cs{get; set;}
    public ContactQuery()
    {
    cs = new List<Contact>();
       for (Contact c : [Select id, Name from Contact])
       {       
           cs.add(c);
       }
    }
}