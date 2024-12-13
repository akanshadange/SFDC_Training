@isTest
public class AttendeeTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
      List<Contact> contacts=new List<Contact>{new Contact(FirstName='Jesica',LastName='Kumar'),new Contact(FirstName='Jay',LastName='Singh')};
      insert contacts;
      List<Training_Session__c>TrainingSessions=new List<Training_Session__c>{new Training_Session__c(Name = 'Session1'),new Training_Session__c(Name = 'Session2'),
                                                                              new Training_Session__c(Name = 'Session3')};
      insert TrainingSessions;
      List<Attendee__c>attendees=new List<Attendee__c>{new Attendee__c(Contact__c = contacts[0].Id, Training_Session__c = TrainingSessions[0].Id),
                                                       new Attendee__c(Contact__c = contacts[0].Id, Training_Session__c = TrainingSessions[1].Id),
                                                       new Attendee__c(Contact__c = contacts[0].Id, Training_Session__c = TrainingSessions[2].Id),
                                                       new Attendee__c(Contact__c = contacts[1].Id, Training_Session__c = TrainingSessions[0].Id),
                                                       new Attendee__c(Contact__c = contacts[1].Id, Training_Session__c = TrainingSessions[1].Id)};
      insert attendees;
    }
    @isTest
    static void testUpdateTotalTrainingSessions() {
        List<Contact> contacts = [SELECT Id, Total_Training_Session_Attended__c FROM Contact WHERE LastName IN ('Kumar', 'Singh')];
        Test.startTest();
        List<Attendee__c> newAttendees = [SELECT Id, Contact__c FROM Attendee__c WHERE Contact__c IN :new List<Id>{contacts[0].Id, contacts[1].Id}];
        Test.stopTest();
        Assert.areEqual(contacts[0].Total_Training_Session_Attended__c, 3, 'Contact1 should have attended 3 sessions.');
        Assert.areEqual(contacts[1].Total_Training_Session_Attended__c, 2, 'Contact2 should have attended 2 sessions.');
    }
    
    @isTest
    static void testUpdateWhenAttendeeIsRemoved() {
        List<Contact> contacts = [SELECT Id, Total_Training_Session_Attended__c FROM Contact WHERE LastName = 'Kumar' LIMIT 1];
        List<Training_Session__c> TrainingSessions = [SELECT Id FROM Training_Session__c WHERE Name = 'Session3' LIMIT 1];
        List<Attendee__c> attendeesToRemove = [SELECT Id FROM Attendee__c WHERE Contact__c=:contacts[0].Id AND Training_Session__c=:TrainingSessions[0].Id];
        delete attendeesToRemove;
        Test.startTest();
        List<Attendee__c> updatedAttendees = [SELECT Id, Contact__c, Training_Session__c FROM Attendee__c WHERE Contact__c = :contacts[0].Id];
        Test.stopTest();
        contacts = [SELECT Id, Total_Training_Session_Attended__c FROM Contact WHERE Id = :contacts[0].Id];
        Assert.areEqual(contacts[0].Total_Training_Session_Attended__c, 2, 'Contact1 should have attended 2 sessions after one was removed.');
    }
    
    @isTest
    static void testUpdateContactFieldThroughAttendee() {
        List<Contact> contacts = [SELECT Id, Total_Training_Session_Attended__c FROM Contact WHERE LastName IN ('Kumar', 'Singh')];
        List<Attendee__c> attendeesToUpdate=[SELECT Id, Contact__c, Training_Session__c FROM Attendee__c WHERE Contact__c IN:new List<Id>{contacts[0].Id, contacts[1].Id}];
        attendeesToUpdate[0].Contact__c = contacts[1].Id;
        update attendeesToUpdate;
        Test.startTest();
        contacts = [SELECT Id, Total_Training_Session_Attended__c FROM Contact WHERE LastName IN ('Kumar', 'Singh')];
        Test.stopTest();
        Assert.areEqual(contacts[0].Total_Training_Session_Attended__c, 2, 'Contact1 should have attended 2 sessions after moving an attendee.');
    }
}