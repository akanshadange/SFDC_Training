@isTest
public class ContactTriggerHandlerTest {
    
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1', Domain__c = 'wipro.com'),
            new Account(Name = 'Test Account 2', Domain__c = 'tcs.com')
        };
        insert accounts;
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'Jivika', LastName = 'Rao', Email = 'jivika.rao@wipro.com', AccountId = accounts[0].Id, RecordId__c = '0012X00000N9zVqQXX'),
            new Contact(FirstName = 'Jayesh', LastName = 'Kumar', Email = 'jayesh.kumar@tcs.com', AccountId = accounts[1].Id, RecordId__c = '003WU00000BC89xYAD'),
                 new Contact(FirstName = 'Test', LastName = 'Picklist', Email = 'test.picklist@wipro.com', RecordId__c = '001WU00000YgRgAYAV'),
            new Contact(FirstName = 'Test', LastName = 'Picklist2', Email = 'test2.picklist@tcs.com', RecordId__c = '001WU00000YgRgAYAV')
        };
        insert contacts;
    }
    
    @isTest
    static void testContactEmailDomainValidation() {
        List<Account> accounts = [SELECT Id, Domain__c FROM Account WHERE Name IN ('Test Account 1', 'Test Account 2')];
        List<Contact> contacts = [SELECT Id, Email, AccountId FROM Contact WHERE LastName IN ('Rao', 'Kumar')];
        Assert.areEqual(contacts[0].Email, 'jivika.rao@wipro.com', 'The email domain should match successfully.');
        contacts[1].Email = 'jayesh.kumar@wrongdomain.com';
        try {
            update contacts;
            Assert.areEqual(false, true, 'Expected exception due to email domain mismatch');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Email domain must match the associated Account domain'), 'Expected domain mismatch error');
        }
    }
    
    @isTest
    static void testProcessContactRecordsWithValidRecordId() {
        List<Contact> contacts = [SELECT Id, FirstName, LastName, RecordId__c, Object_Name__c, Picklist_Field__c FROM Contact WHERE LastName IN ('Rao', 'Kumar')];
        Test.startTest();
        ContactTriggerHandler.processContactRecords(contacts);
        Test.stopTest();
        for (Contact contact : contacts) {
            if (contact.RecordId__c == '0012X00000N9zVqQXX') {
                Assert.areEqual(contact.Object_Name__c, 'Account', 'Object_Name__c should be Account based on RecordId__c');
                Assert.areNotEqual(contact.Picklist_Field__c, '', 'Picklist_Field__c should not be empty');
            } else if (contact.RecordId__c == '0032X00000N9zVqQYY') {
                Assert.areEqual(contact.Object_Name__c, 'Contact', 'Object_Name__c should be Contact based on RecordId__c');
                Assert.areNotEqual(contact.Picklist_Field__c, '', 'Picklist_Field__c should not be empty');
            }
        }
    }

    @isTest
    static void testProcessContactRecordsWithPicklistValues() {
        List<Contact> contacts = [SELECT Id, FirstName, LastName, RecordId__c, Object_Name__c, Picklist_Field__c FROM Contact WHERE LastName IN ('Picklist', 'Picklist2')];
        Test.startTest();
        ContactTriggerHandler.processContactRecords(contacts);
        Test.stopTest();
        for (Contact contact : contacts) {
            Assert.areNotEqual(contact.Object_Name__c, null, 'Object_Name__c should be populated.');
            Assert.areNotEqual(contact.Picklist_Field__c, null, 'Picklist_Field__c should be populated.');
            Assert.areEqual(contact.RecordId__c, '001WU00000YgRgAYAV', 'RecordId__c should match the setup record ID.');
        }
    }
}