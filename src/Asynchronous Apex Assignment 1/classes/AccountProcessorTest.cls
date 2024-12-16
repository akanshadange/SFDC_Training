@isTest
public class AccountProcessorTest {
    @TestSetup
    public static void setupTestData() {
        Account a = new Account(Name = 'Test Account');
        insert a;
        List<Contact> contacts=new List<Contact>{new Contact(FirstName='Bob',LastName='Willie',AccountId=a.Id),
                                                 new Contact(FirstName='Tom',LastName='Cruise',AccountId=a.Id)};
        insert contacts;
    }
    @isTest
    //Test method to verify the count of Contacts associated with an Account is correctly updated using the future method.
    public static void testNoOfContacts() {
        List<Account> accountList = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId =: accountList[0].Id];
        Set<Id> acctIds = new Set<Id>{accountList[0].Id};
        Test.startTest();
        AccountProcessor.countContacts(acctIds);
        Test.stopTest();
        Assert.areEqual(2,contactList.size());
    }
}