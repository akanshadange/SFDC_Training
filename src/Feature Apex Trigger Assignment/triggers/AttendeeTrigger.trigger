trigger AttendeeTrigger on Attendee__c (after insert, after update, after delete) {
	new AttendeeTriggerHandler().run();
}