@isTest
//Test method of AddPrimaryContact
public class AddPrimaryContactTest {
    @testSetup
    static void setup(){
        List<Account> accList = new List<Account>();
        for(integer i=0;i<50;i++) {
            Account acc = new Account(Name='Test'+i,BillingState='NY');
            accList.add(acc);
        }
        for(integer i=0;i<50;i++) {
            Account acc = new Account(Name='TestAcc'+i,BillingState='CA');
            accList.add(acc);
        }
        insert accList;
    }
    @isTest
    public static void addPrimary_Test(){
        Contact con =new Contact(LastName ='Tested Clone');
        test.startTest();
        AddPrimaryContact apc = new AddPrimaryContact(con,'CA');
        System.enqueueJob(apc);
        test.stopTest();
        Assert.areEqual(50,[Select Id from Contact WHERE Account.BillingState='CA'].size());
    }
}