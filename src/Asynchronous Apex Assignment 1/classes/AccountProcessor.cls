/*
Description  : Asynchronous class to update the Number of Contacts field on Account using future methods
Created By 	 : Akansha Dange
Created Date : 14-12-2024
*/
public class AccountProcessor {
    @future
    public static void countContacts(Set<Id> accountIds){
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN: accountIds];
        for(Account account : accounts){
           account.No_Of_Contacts__c = [SELECT Count() FROM Contact WHERE AccountId =: account.Id];
        }
        update accounts;
    }
}