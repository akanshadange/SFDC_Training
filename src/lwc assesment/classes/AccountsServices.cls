public with sharing class AccountsServices {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Phone, Rating FROM Account];
    }

    @AuraEnabled
    public static void createAccount(String name, String phone, String rating) {
        Account newAccount = new Account(Name = name, Phone = phone, Rating = rating);
        insert newAccount;
    }
}