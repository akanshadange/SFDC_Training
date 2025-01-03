/*
Purpose			: Batch Class to Archive Data From a Specific Object Based On Metadata,Send an Email with CSV File & Delete Records
Created Date	: 1-1-24
Created By		: Akansha Dange
*/

public class ArchiveDataBatch implements Database.Batchable<SObject>, Database.Stateful {
    public String query;
    public String emailSubject;
    public String emailBody;
    public String developerName; 
    @testVisible static Integer emailsInvocations;
    public  List<String> archivedRecords = new List<String>();
    // Constructor to initialize query and email content based on metadata
    public ArchiveDataBatch(String developerName) {
        this.developerName = developerName;
        List<Archive_Config__mdt> archiveConfigs = [SELECT Developer_Name__c, Label, Duration__c, Filter__c FROM Archive_Config__mdt 
                                                    WHERE Developer_Name__c !=null AND Developer_Name__c = :developerName AND Duration__c !=null 
                                                    AND Label!=null ];
        Archive_Config__mdt config = archiveConfigs[0];
        query = 'SELECT Id, Name FROM ' + config.Developer_Name__c + ' WHERE ' + config.Filter__c;
        emailSubject = 'Archived Data Report for ' + config.Label;
        emailBody = 'Hello ' + getFirstName(UserInfo.getUserName()) + ',\n\n' +'The following data has been archived: \n\n';
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Set<String> idsToDelete = new Set<String>();
        for (SObject record : scope) {
            SObject sObjectRecord = (SObject) record;
            String recordId = (String) sObjectRecord.get('Id');
            String recordName = (String) sObjectRecord.get('Name');
            archivedRecords.add(recordId + ', ' + recordName);
            idsToDelete.add(recordId);
        }
        String deleteQuery = 'SELECT Id FROM ' + developerName + ' WHERE Id IN :idsToDelete';
        delete Database.query(deleteQuery);
    }
    public void finish(Database.BatchableContext bc) {
        sendEmailWithAttachment(archivedRecords);
        System.debug('Batch Process Completed.');
    }
    // Method to send email with attached CSV data
    private void sendEmailWithAttachment(List<String> archivedRecords) {
        String csvData = 'Record Id, Record Name\n' + String.join(archivedRecords, '\n');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(emailSubject);
        String emailBodyWithGreeting = emailBody + 'Please find the attached CSV file with the archived data below:\n\n' + csvData + '\n\nThank you!';
        mail.setPlainTextBody(emailBodyWithGreeting);
        mail.setToAddresses(new String[] { UserInfo.getUserEmail() });
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('ArchivedData.csv');
        attachment.setBody(Blob.valueOf(csvData));
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        emailsInvocations = Limits.getEmailInvocations();
    }
    // Helper method to extract the first name from the email address
    private String getFirstName(String userName) {
        String firstName = userName.split('@')[0];
        return firstName.substring(0, 1).toUpperCase() + firstName.substring(1);
    }
}