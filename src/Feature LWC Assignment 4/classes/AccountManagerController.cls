public  class AccountManagerController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Industry, AnnualRevenue,Rating,Phone FROM Account LIMIT 50];
    }
}