public with sharing class ContactsServices {
    
    @AuraEnabled
    public static void createContact(String firstName, String lastName, String email) {
        Contact newContact = new Contact(FirstName = firstName, LastName = lastName, Email = email);
        insert newContact;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccountId(Id accountId) {
        return [SELECT Id, Name, Email, Phone FROM Contact WHERE AccountId = :accountId];
    }
}