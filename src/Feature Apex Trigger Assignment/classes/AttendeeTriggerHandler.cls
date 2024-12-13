/*
Description  : Manage All Events Related To Attendee.
Created By 	 : Akansha Dange
Created Date : 5-12-2024
*/
public virtual class AttendeeTriggerHandler extends TriggerHandler {
    // Implement the afterInsert method
    public override void afterInsert() {
        List<Attendee__c> newList=(List<Attendee__c>)Trigger.New;
        List<Attendee__c> oldList=(List<Attendee__c>)Trigger.Old;
        updateTotalTrainingSessions(newList, null);
    }

    // Implement the afterUpdate method
    public override void afterUpdate() {
        List<Attendee__c> newList=(List<Attendee__c>)Trigger.New;
        List<Attendee__c> oldList=(List<Attendee__c>)Trigger.Old;
        updateTotalTrainingSessions(newList,oldList);
    }

    // Implement the afterDelete method
    public override void afterDelete() {
        List<Attendee__c> newList=(List<Attendee__c>)Trigger.New;
        List<Attendee__c> oldList=(List<Attendee__c>)Trigger.Old;
        updateTotalTrainingSessions(null, oldList);
    }

    //update Total Training Sessions on the Contact record
    public static void updateTotalTrainingSessions(List<Attendee__c> newList, List<Attendee__c> oldList) {
        Set<Id> contactIdsToUpdate = new Set<Id>();
        if (newList != null) {
            for (Attendee__c attendee : newList) {
                if (attendee.Contact__c != null && attendee.Training_Session__c != null) {
                    contactIdsToUpdate.add(attendee.Contact__c);
                }
            }
        }
        if (oldList != null) {
            for (Attendee__c attendee : oldList) {
                if (attendee.Contact__c != null && attendee.Training_Session__c != null) {
                    contactIdsToUpdate.add(attendee.Contact__c);
                }
            }
        }
        if (contactIdsToUpdate.isEmpty()) {
            return;
        }
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Total_Training_Session_Attended__c FROM Contact 
                                                             WHERE Id IN :contactIdsToUpdate]);
        List<AggregateResult> aggregateResults = [SELECT Contact__c, COUNT_DISTINCT(Training_Session__c) sessionCount 
                                                  FROM Attendee__c WHERE Contact__c IN :contactIdsToUpdate 
                                                  GROUP BY Contact__c];
        Map<Id, Integer> contactSessionCounts = new Map<Id, Integer>();
        for (AggregateResult result : aggregateResults) {
            Id contactId = (Id) result.get('Contact__c');
            Integer sessionCount = (Integer) result.get('sessionCount');
            contactSessionCounts.put(contactId, sessionCount);
        }
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id contactId : contactIdsToUpdate) {
            Contact contact = contactsMap.get(contactId);
            Integer sessionCount = contactSessionCounts.get(contactId);
            if (sessionCount != null) {
                contact.Total_Training_Session_Attended__c = sessionCount;
                contactsToUpdate.add(contact);
            }
        }
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
}