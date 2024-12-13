/*
Description  : Manage All Events Related To Contacts.
Created By 	 : Akansha Dange
Created Date : 5-12-2024
*/
public virtual class ContactTriggerHandler extends TriggerHandler {

    // Implement the beforeInsert method
    public override void beforeInsert() {
       List<Contact> newConList=(List<Contact>)Trigger.New;
       Map<Id, Contact> oldConMap =(Map<Id, Contact>)Trigger.oldMap;
       checkContactEmailDomain(newConList, null);
    }

    // Implement the beforeUpdate method
    public override void beforeUpdate() {
    	List<Contact> newConList=(List<Contact>)Trigger.New;
        Map<Id, Contact> oldConMap =(Map<Id, Contact>)Trigger.oldMap;  
        checkContactEmailDomain(newConList,oldConMap);
    }

    // Use the checkContactEmailDomain logic from the original code
    public static void checkContactEmailDomain(List<Contact> newConList, Map<Id, Contact> oldConMap) {
        if (!newConList.isEmpty()) {
            Set<Id> setOfAccountIds = new Set<Id>();
            for (Contact con : newConList) {
                if (con.AccountId != null && con.Email != null && (oldConMap == null || (con.Email != oldConMap.get(con.Id).Email) ||
                        con.AccountId != oldConMap.get(con.Id).AccountId)) {
                    setOfAccountIds.add(con.AccountId);
                }
            }

            if (!setOfAccountIds.isEmpty()) {
                Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Domain__c FROM Account WHERE Id IN :setOfAccountIds]);
                for (Contact con : newConList) {
                    if (con.AccountId != null && con.Email != null && accountMap.keySet().contains(con.AccountId)) {
                        Account acc = accountMap.get(con.AccountId);
                        if (acc != null && acc.Domain__c != null) {
                            String domain = acc.Domain__c.toLowerCase();
                            if (!con.Email.endsWith('@' + domain)) {
                                con.addError('Email domain must match the associated Account domain: ' + domain);
                            }
                        }
                    }
                }
            }
        }
    }
    /*
    //method to update status field on Contact object based on Parent or grandparent field
    public static void assignStatusToContacts(List<Contact> newContacts) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact contact : newContacts) {
            if (contact.AccountId != null) {
                accountIds.add(contact.AccountId);
            }
        }
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Status__c, Property__r.Status__c FROM Account WHERE Id IN :accountIds]);
        for (Contact contact : newContacts) {
            if (contact.Status__c == null) {
                Account account = accounts.get(contact.AccountId);
                if (account != null && account.Status__c != null) {
                    contact.Status__c = account.Status__c;           
                } 
                else if (account != null && account.Property__r != null && account.Property__r.Status__c != null) {
                    contact.Status__c = account.Property__r.Status__c;
                }
            }
        }
    }*/
}