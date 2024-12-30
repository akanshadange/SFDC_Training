/*
Purpose			: Update all Lead records LeadSource field to 'Dreamforce' using the Database.Batchable interface.
Created Date	: 19-12-24
Created By		: Akansha Dange
*/

public class LeadProcessor implements Database.Batchable<sObject> { 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select LeadSource From Lead ]);
    }
    public void execute(Database.BatchableContext bc, List<Lead> leads){
        for (Lead Lead : leads) {
            lead.LeadSource = 'Dreamforce';
        }
        update leads;
    }    
    public void finish(Database.BatchableContext bc){
    }
}