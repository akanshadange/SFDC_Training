@isTest
public class TrainingSessionManagerTest {
    @testSetup
    static void setupTestData() {
        List<Training_Session__c> sessions = new List<Training_Session__c>{new Training_Session__c(Name='Training Session 1',Session_Date__c=Date.today().addDays(5),
                                                                                                   Session_Type__c='Webinar'),
            new Training_Session__c(Name = 'Training Session 2',Session_Date__c=Date.today().addDays(10),Session_Type__c='Seminar'),
            new Training_Session__c(Name = 'Training Session 3',Session_Date__c=Date.today().addDays(2),Session_Type__c='Workshop'),
            new Training_Session__c(Name = 'Training Session 4',Session_Date__c=Date.today().addDays(-5),Session_Type__c='Webinar')};
            insert sessions;
        List<Attendee__c> attendees = new List<Attendee__c>{new Attendee__c(Name='Attendee 1',Training_Session__c=sessions[0].Id,Phone__c=null),
            new Attendee__c(Name = 'Attendee 2', Training_Session__c=sessions[0].Id, Phone__c = null),
            new Attendee__c(Name = 'Attendee 3', Training_Session__c=sessions[1].Id, Phone__c = '12345'),
            new Attendee__c(Name = 'Attendee 4', Training_Session__c=sessions[2].Id, Phone__c = '67890'),
            new Attendee__c(Name = 'Attendee 5', Training_Session__c=sessions[3].Id, Phone__c = '11223'),
            new Attendee__c(Name = 'Attendee 6', Training_Session__c=sessions[3].Id, Phone__c = null),
            new Attendee__c(Name = 'Test Attendee 1', Phone__c=null,  Training_Session__c = sessions[1].Id),
            new Attendee__c(Name = 'Test Attendee 2', Phone__c=null, Training_Session__c = sessions[2].Id)};
            insert attendees;
    }
    
    // Test method for createTrainingSessions method
    @isTest
    static void testCreateTrainingSessions() {
        Test.startTest();
        TrainingSessionManager.createTrainingSessions();
        Test.stopTest();
        List<Training_Session__c> sessions = [SELECT Id, Name FROM Training_Session__c];
        Assert.areEqual(sessions.size(), 8,'There should be 4 training sessions created');
        Assert.isTrue(sessions[0].Name.startsWith('Training Session'), 'Session name should start with "Training Session"');
    }
    
    // Test method for readTrainingSession method
    @isTest
    static void testReadTrainingSession() {
        Training_Session__c session = new Training_Session__c(Name = 'Test Session');
        insert session;
        Test.startTest();
        TrainingSessionManager.readTrainingSession(session.Id);
        Test.stopTest();
        Training_Session__c fetchedSession = [SELECT Id, Name FROM Training_Session__c WHERE Id = :session.Id LIMIT 1];
        Assert.areEqual(session.Id,fetchedSession.Id);
        Assert.areEqual('Test Session',fetchedSession.Name);
    }
    
    // Test method for deleteTrainingSession method
    @isTest
    static void testDeleteTrainingSession() {
        Training_Session__c session = new Training_Session__c(Name = 'Session to be deleted');
        insert session;
        Test.startTest();
        TrainingSessionManager.deleteTrainingSession(session.Id);
        Test.stopTest();
        Integer count = [SELECT count() FROM Training_Session__c WHERE Id = :session.Id];
        Assert.areEqual(0,count,'The session should be deleted');
    }
    
    // Test method for updateSessionLocation method
    @isTest
    static void testUpdateSessionLocation() {
        Training_Session__c session = new Training_Session__c(Name = 'Test Session for Location');
        insert session;
        Test.startTest();
        TrainingSessionManager.updateSessionLocation(session.Id, 'New Location');
        Test.stopTest();
        Training_Session__c updatedSession = [SELECT Location__c FROM Training_Session__c WHERE Id = :session.Id];
        Assert.areEqual(updatedSession.Location__c, 'New Location', 'The session location should be updated');
    }
    
    // Test method for addAttendee method
    @isTest
    static void testAddAttendee() {
        Training_Session__c session = new Training_Session__c(Name = 'Session with Attendees');
        insert session;
        Test.startTest();
        TrainingSessionManager.addAttendee(session.Id, 'Mrunal Dighe');
        Test.stopTest();
        List<Attendee__c> attendees = [SELECT Id, Name FROM Attendee__c WHERE Training_Session__c = :session.Id];
        Assert.areEqual(1, attendees.size(), 'There should be one attendee added');
        Assert.areEqual(attendees[0].Name, 'Mrunal Dighe', 'The attendee name should be "John Doe"');
    }
    
    // Test method for createTrainingSession with session type
    @isTest
    static void testCreateTrainingSessionWithSessionType() {
        Test.startTest();
        TrainingSessionManager.createTrainingSession('Webinar Session', TrainingSessionManager.SessionType.WEBINAR);
        Test.stopTest();
        Training_Session__c createdSession = [SELECT Name, Session_Type__c FROM Training_Session__c WHERE Name = 'Webinar Session' LIMIT 1];
        Assert.areEqual(createdSession.Session_Type__c, 'WEBINAR', 'The session type should be "WEBINAR"');
    }
    
    // Test method for fetching attendees with training sessions using safe navigation
    @isTest
    static void testFetchAttendeesWithTrainingSessionsUsingSafeNavigation() {
        List<Training_Session__c> sessions=[SELECT Id, Name, Session_Date__c, Session_Type__c,(SELECT Id, Name, Phone__c FROM Attendees__r) FROM Training_Session__c];
        Test.startTest();
        TrainingSessionManager.FetchAttendeesWithTrainingSessionsUsingSafeNavigation();
        Test.stopTest();
        Assert.areEqual(4, sessions.size(), 'Expected 4 training sessions');
    }
    
    // Test method for fetching attendees with related training session
    @isTest
    static void testFetchAttendeesWithRelatedTrainingSession() {
        List<Training_Session__c> sessions=[SELECT Id, Name, Session_Date__c, Session_Type__c,(SELECT Id, Name, Phone__c FROM Attendees__r) FROM Training_Session__c];
        Test.startTest();
        TrainingSessionManager.fetchAttendeesWithRelatedTrainingSession();
        Test.stopTest();
        Assert.areEqual(4, sessions.size(), 'Expected 4 training sessions');
        
    }
    // Test method for getTrainingMessageById method
    @isTest
    static void testGetTrainingMessageById() {
        Training_Session__c sessions = [SELECT Id, Session_Type__c FROM Training_Session__c WHERE Name = 'Training Session 2'];
        Test.startTest();
        TrainingSessionManager.getTrainingMessageById(sessions.Id);
        Test.stopTest();
        String Message = Label.Training_Session_Workshop;
        Assert.areEqual(Message,'"Welcome to the Workshop! Get ready to engage in hands-on learning and interactive discussions."');
        
    }
    
    // Test method for getUpcomingTrainingSessions method
    @isTest
    static void testGetUpcomingTrainingSessions() {
        List<Training_Session__c> trainingSessionList = [SELECT Id,Name,Session_Date__c,Session_Type__c FROM Training_Session__c LIMIT 3];
        Test.startTest();
        TrainingSessionManager.getUpcomingTrainingSessions();
        Test.stopTest();
        Assert.areEqual(3, trainingSessionList.size(), 'There should be 3 upcoming training sessions.');
        Assert.areEqual('Training Session 1', trainingSessionList[0].Name, 'First session should be Webinar Session 1');
        Assert.areEqual('Training Session 2', trainingSessionList[1].Name, 'Second session should be Seminar Session 1');
        Assert.areEqual('Training Session 3', trainingSessionList[2].Name, 'Third session should be Webinar Session 2');
    }
    
    // Test method for bulkDatabaseInsert method
    @isTest
    static void testBulkDatabaseInsert() {
        Test.startTest();
        TrainingSessionManager.bulkDatabaseInsert();
        List<Attendee__c> attendees = [SELECT Id, Name FROM Attendee__c WHERE Name IN ('Sapna')];
        Test.stopTest();
        Assert.isTrue(attendees.size() > 0, 'Bulk insert of attendees should have succeeded');
    }
    
    // Test method for bulkDatabaseUpdate method
    @isTest
    static void testBulkDatabaseUpdate() {
        List<Attendee__c> attendeesWithNullPhone = [SELECT Id, Phone__c FROM Attendee__c WHERE Phone__c = NULL];
        TrainingSessionManager.bulkDatabaseUpdate();
        List<Attendee__c> updatedAttendees = [SELECT Id, Name, Phone__c FROM Attendee__c WHERE Phone__c = '7829900'];
        Assert.areEqual(5, updatedAttendees.size(), 'There should be 4 attendees whose Phone__c is updated to 7829900.');
    }
    
    // Test method for bulkDatabaseDelete method
    @isTest
    static void testBulkDatabaseDelete() {
        Test.startTest();
        TrainingSessionManager.bulkDatabaseDelete();
        List<Attendee__c> attendees = [SELECT Id, Name FROM Attendee__c WHERE Name IN ('Nimrut', 'Akshit')];
        Test.stopTest();
        Assert.areEqual(attendees.size(),0,'Attendees Nimrut and Akshit should be deleted');
    }
}