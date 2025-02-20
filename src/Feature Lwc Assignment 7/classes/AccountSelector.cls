public with sharing class AccountSelector {
    public static List<Account> getAccounts(Id accId) {
        return [SELECT Id, Name, Owner.Name, Description, No_Of_Contacts__c FROM Account WHERE Id = :accId LIMIT 1];
    }
}