@RestResource(urlMapping='/myAccountServices/*')
global with sharing class MyAccountServicesIntegration {
    @HttpGet
    global static String getAccountInfo() {
        String accountId = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/')+1);
        String response = '';
        try {
            List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
            if (accounts.isEmpty()) {
                response = '{"error": "Account not found for ID: ' + accountId + '"}';
            } else {
                Account account = accounts[0];
                response = '{"accountId": "' + account.Id + '", "accountName": "' + account.Name + '"}';
            }
        }catch (Exception e) {
            response = '{"error": "An unexpected error occurred: ' + e.getMessage() + '"}';
        }
        return response;
    }
    @HttpPost
    global static String createAccountAndContact(String accountName, String firstName, String lastName, String email) {
        String response = '';
        try {
            List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name = :accountName LIMIT 1];
            Account account;
            if (existingAccounts.isEmpty()) {
                account = new Account(Name = accountName);
                insert account;
            } else {
                account = existingAccounts[0];
            }
            List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE AccountId = :account.Id AND Email = :email LIMIT 1];
            if (!existingContacts.isEmpty()) {
                response = '{"error": "A contact with this email already exists for the Account ' + account.Name + '"}';
            } else {
                Contact newContact = new Contact(FirstName = firstName, LastName = lastName, Email = email, AccountId = account.Id);
                insert newContact;
                response = '{"success": "Contact created successfully", "accountId": "' + account.Id + '", "contactId": "' + newContact.Id + '"}';
            }
        } catch (Exception e) {
            response = '{"error": "An error occurred: ' + e.getMessage() + '"}';
        }
        return response;
    }
}