/*
Purpose			: The AddPrimaryContact class asynchronously clones and associates a contact with accounts of a specified billing state Using the
                  Queueable interface.
Created Date	: 19-12-24
Created By		: Akansha Dange
*/

public class AddPrimaryContact implements Queueable {
    public Contact contact;
    public String stateAbbrivation;
    public AddPrimaryContact(Contact con,String stateAbbrivation){
        this.contact = con;
        this.stateAbbrivation = stateAbbrivation;
    }
    public void execute(QueueableContext qc){
        List<Account> accList = [SELECT Id,Name FROM Account WHERE BillingState =:stateAbbrivation];
        List<Contact> conList = new List<Contact>();
        for(Account a: accList){
            Contact clonedConRec = contact.clone();
            clonedConRec.AccountId = a.Id;
            conList.add(clonedConRec);
        }
        insert conList; 
    }
}