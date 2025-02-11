public with sharing class AccountService {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Id accId) {
        return AccountSelector.getAccounts(accId);
    }
}