public with sharing class ContactSelector {
    public static List<Contact> getContactsByAccountId(Id accountId) {
        return [SELECT Id, Name, Email, Phone FROM Contact  WHERE AccountId = :accountId];
    }
}