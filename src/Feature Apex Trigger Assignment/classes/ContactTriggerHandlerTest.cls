@isTest
public class ContactTriggerHandlerTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>{new Account(Name = 'Test Account 1', Domain__c = 'wipro.com'),
                                                   new Account(Name = 'Test Account 2', Domain__c = 'tcs.com')};
        insert accounts;
        List<Contact> contacts = new List<Contact>{new Contact(FirstName = 'Jivika', LastName = 'Rao', Email = 'jivika.rao@wipro.com',
                                                   AccountId = accounts[0].Id),
                                                   new Contact(FirstName = 'Jayesh', LastName = 'Kumar', Email = 'jayesh.kumar@tcs.com',
                                                   AccountId = accounts[1].Id)};
        insert contacts;
    }
    @isTest
    static void testContactEmailDomainValidation() {
        List<Account> accounts = [SELECT Id, Domain__c FROM Account WHERE Name IN ('Test Account 1', 'Test Account 2')];
        List<Contact> contacts = [SELECT Id, Email, AccountId FROM Contact WHERE LastName IN ('Rao', 'Kumar')];
        Assert.areEqual(contacts[0].Email,'jivika.rao@wipro.com','The email domain should match successfully.');
        contacts[1].Email = 'jayesh.kumar@wrongdomain.com';
        try {
            update contacts;
            Assert.areEqual('Expected exception due to email domain mismatch', false);
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Email domain must match the associated Account domain'), 'Expected domain mismatch error');
        }
        
    }
}