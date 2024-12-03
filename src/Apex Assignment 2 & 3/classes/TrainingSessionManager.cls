/*
Purpose			: Managing the training session records, including CRED Operation and querying training sessions and their associated 
                  attendees with safe navigation, exception handling, debug logging, and custom labels.
Created Date	: 27-11-24
Created By		: Akansha Dange
*/
public class TrainingSessionManager {
    
    // create Training Session records
    public Static void createTrainingSessions(){
        List<Training_Session__c> trainingSessionList = new List<Training_Session__c>();
        for(Integer i = 6 ; i<10 ; i++){
            Training_Session__c sessions= new Training_Session__c(Name = 'Training Session'+i );
            trainingSessionList.add(Sessions);
        }
        try {
            insert trainingSessionList;
            System.debug('Training sessions inserted successfully.');
        } catch (DmlException e) {
            System.debug('Error inserting Training_Session__c records: ' + e.getMessage());
        }
    }
    
    // fetch training session records
    public static void readTrainingSession(Id trainingSessionId) {
        Training_Session__c displayTrainingSession = [SELECT Id, Name,Session_Date__c, Location__c, No_of_Attendee__c FROM Training_Session__c 
                                                      WHERE Id = :trainingSessionId LIMIT 1];
        System.debug(displayTrainingSession);
    }   
    
    // delete training session records
    public static void deleteTrainingSession(Id trainingSessionId) {
        try {
            Training_Session__c trainingSession = [SELECT Id FROM Training_Session__c WHERE Id = :trainingSessionId LIMIT 1];
            delete trainingSession;
            System.debug('Training session deleted successfully.');
        } catch (QueryException qe) {
            System.debug('Error querying Training_Session__c record: ' + qe.getMessage());
        }  
    }

    //Updates the Location__c field of a Training_Session__c record only if the location is currently null.
    public static void updateSessionLocation(Id trainingSessionId, String newLocation) {
        try{
            Training_Session__c trainingSession = [SELECT Id, Location__c FROM Training_Session__c 
                                                   WHERE Id = :trainingSessionId AND Location__c = NULL LIMIT 1];
            if (trainingSession != null) {
                trainingSession.Location__c = newLocation;
                update trainingSession;
                System.debug('Updated session location to: ' + newLocation);
            } else {
                System.debug('No training session found whose location is null.');
            }
        }
        catch (Exception e) {
            System.debug('Error Invalid Id: ' + e.getMessage());
        }
    }

    //This method adds an attendee to a training session, but ensures that each attendee is only added once.
    public static void addAttendee(Id trainingSessionId, String attendeeName) {     
        Training_Session__c trainingSession = [SELECT Id, (SELECT Id, Name FROM Attendees__r)FROM Training_Session__c 
                                                WHERE Id = :trainingSessionId LIMIT 1 ]; 
        Set<Id> existingAttendeeIds = new Set<Id>(); 
        for (Attendee__c attendee : trainingSession.Attendees__r) {         
            existingAttendeeIds.add(attendee.Id);     
        } 
        List<Attendee__c> existingAttendees = [SELECT Id FROM Attendee__c WHERE Name = :attendeeName 
                                               AND Training_Session__c = :trainingSessionId LIMIT 1]; 
        if (existingAttendees.isEmpty()) {         
            Attendee__c newAttendee = new Attendee__c(Training_Session__c = trainingSessionId, Name = attendeeName);         
            insert newAttendee;         
            System.debug('Attendee added: ' + attendeeName);     
        } else {         
            System.debug('Attendee already exists: ' + attendeeName);     
        } 
    }
    
    //This method creates a new training session and assigns it Session Type based on the enum.
    public enum SessionType {
        WEBINAR,
        WORKSHOP,
        SEMINAR
    }
    public static void createTrainingSession(String sessionName, SessionType sessionType) {
        Training_Session__c newTrainingSession = new Training_Session__c(Name=sessionName,Session_Type__c = sessionType.name());
        insert newTrainingSession;
        System.debug('Training Session Created: ' + newTrainingSession.Id);
    } 

    //fetching attendee record related with training session Using Safe Navigation
    public static void fetchAttendeesWithTrainingSessionsUsingSafeNavigation() {
        Map<String, List<Attendee__c>> mapOfTrainingSessionWithAttendees = new Map<String, List<Attendee__c>>();
        for (Attendee__c attendee : [SELECT Name, Phone__c, Email__c, Training_Session__c, Training_Session__r.Name FROM Attendee__c 
                                     WHERE Training_Session__c != null]) {
            String trainingSessionName = attendee.Training_Session__r?.Name; 
            if (trainingSessionName != null) {
                if (!mapOfTrainingSessionWithAttendees.containsKey(trainingSessionName)) {
                    mapOfTrainingSessionWithAttendees.put(trainingSessionName, new List<Attendee__c>());
                }
                mapOfTrainingSessionWithAttendees.get(attendee.Training_Session__r.Name).add(attendee);
            }
        }
        System.debug('Map data --> ' + mapOfTrainingSessionWithAttendees); 
    }

    //fetching attendee record related with training session
    public static void fetchAttendeesWithRelatedTrainingSession() {
        Map<String,List<Attendee__c>> mapOfTrainingSessionWithAttendees = new Map<String,List<Attendee__c>>();
        for (Attendee__c attendee : [SELECT Name,Phone__c,Email__c,Training_Session__c,Training_Session__r.Name FROM Attendee__c
                                     WHERE Training_Session__c != null]) {
            if(!mapOfTrainingSessionWithAttendees.containsKey(attendee.Training_Session__r.Name)) {
                mapOfTrainingSessionWithAttendees.put(attendee.Training_Session__r.Name,new List<Attendee__c>());
            }
            mapOfTrainingSessionWithAttendees.get(attendee.Training_Session__r.Name).add(attendee);
        }
        System.debug('map data -->'+mapOfTrainingSessionWithAttendees); 
    }
    
    // Method to fetch training session by ID and generate a custom message based on session type
    public static Void getTrainingMessageById(Id trainingSessionId) {
        Training_Session__c session = [SELECT Session_Type__c FROM Training_Session__c WHERE Id = :trainingSessionId LIMIT 1];
        System.debug(session.Session_Type__c);
        String message = '';
        if (session.Session_Type__c == 'Workshop') {
            message = Label.Training_Session_Workshop;
        } else if (session.Session_Type__c == 'Webinar') {
            message = Label.Training_Session_Webinar;
        } else if (session.Session_Type__c == 'Seminar') {
            message = Label.Training_Session_Seminar; 
        } else {
            message = 'Training Session type not found. Please check the session type.';
        }
        System.debug(message);
    }

    // SOQL query to fetch training session records Based on Specific Criteria(Date,type,attendeeCount)
    public static void getUpcomingTrainingSessions() {
        List<Training_Session__c> sessions = [SELECT Name,Session_Date__c, Session_Type__c, No_of_Attendee__c FROM Training_Session__c
                                              WHERE Session_Date__c > THIS_MONTH AND Session_Type__c IN ('WEBINAR', 'SEMINAR')
                                              AND No_of_Attendee__c > 1 ORDER BY Session_Date__c];
        System.debug('Upcoming Training Sessions: ' + sessions);
    }

    // Method of Bulk Insert using Databse.Insert Method
    public static void bulkDatabaseInsert(){
        List<Attendee__c> attendeeList = new List<Attendee__c>{new Attendee__c(Name='Sapna',Lastname__c='Gohil',Training_Session__c='a0HWU0000008Srx2AE'),
            new Attendee__c(Name='Sapna',Lastname__c='Gupta'), new Attendee__c()};
        Database.SaveResult[] srList = Database.insert(attendeeList,false);
        for(Database.SaveResult sr : srList){
            if(sr.isSuccess()) {
                System.debug('Successfully inserted attendee records. Attendee id : '+sr.getId());
            }else{
                for(Database.Error err : sr.getErrors()){
                    System.debug('The following error has occured');
                    System.debug(err.getStatusCode()+':'+err.getMessage());
                    System.debug('Attendee fields that affected this error : '+err.getFields());
                }
            }
        }
    }

    //Method  of Bulk Insert using Database.Update Method
    public static void bulkDatabaseUpdate() {
        List<Attendee__c> attendeeList = [SELECT Id, Name, Lastname__c, Training_Session__c FROM Attendee__c WHERE Phone__c = NULL];
        for (Attendee__c attendee : attendeeList) {
            attendee.Lastname__c = 'UpdatedLastname';
            attendee.Phone__c = '7829900'; 
        }
        if (!attendeeList.isEmpty()) {
            Database.SaveResult[] srList = Database.update(attendeeList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully updated attendee record. Attendee id: ' + sr.getId());
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error occurred during update');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields affected: ' + err.getFields());
                    }
                }
            }
        } else {
            System.debug('No records found to update');
        }
    }
    
    //Method  of Bulk Insert using Database.Update Method
    public static void bulkDatabaseDelete() {
        List<Attendee__c> attendeeList =[SELECT Id,Name FROM Attendee__c WHERE(Name ='Nimrut' OR Name ='Akshit')];
        Database.DeleteResult[] drList = Database.delete(attendeeList, false);
        for (Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                System.debug('Successfully deleted attendee record. Attendee id: ' + dr.getId());
            } else {
                for (Database.Error err : dr.getErrors()) {
                    System.debug('Error occurred during delete'+err.getMessage());
                }
            }
        }
    }
}