@isTest
public class MyAccountServicesIntegrationTest {
    @isTest
    static void testGetAccountInfo_Success() {
        Account testAccount = new Account(Name = 'Microsoft');
        insert testAccount;
        RestRequest req = new RestRequest();
        req.requestURI = '/myAccountServices/' + testAccount.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        String response = MyAccountServicesIntegration.getAccountInfo();
        Test.stopTest();
        System.assert(response.contains(testAccount.Id));
        System.assert(response.contains(testAccount.Name));
    }
    @isTest
    static void testGetAccountInfo_AccountNotFound() {
        RestRequest req = new RestRequest();
        req.requestURI = '/myAccountServices/001xxxxxxxxxxxx';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        String response = MyAccountServicesIntegration.getAccountInfo();
        Test.stopTest();
        System.assert(response.contains('"error": "Account not found for ID: 001xxxxxxxxxxxx"'));
    }
    @isTest
    static void testCreateAccountAndContact_Success() {
        String accountName = 'TIAA';
        String firstName = 'Sonali';
        String lastName = 'Sharma';
        String email = 'sonali.sharma@example.com';
        RestRequest req = new RestRequest();
        req.requestURI = '/myAccountServices/';
        req.httpMethod = 'POST';
        req.addParameter('accountName', accountName);
        req.addParameter('firstName', firstName);
        req.addParameter('lastName', lastName);
        req.addParameter('email', email);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        String response = MyAccountServicesIntegration.createAccountAndContact(accountName, firstName, lastName, email);
        Test.stopTest();
        System.assert(response.contains('"success": "Contact created successfully"'));
    }
    @isTest
    static void testCreateAccountAndContact_ContactExists() {
        Account existingAccount = new Account(Name = 'Existing Account');
        insert existingAccount;
        Contact existingContact = new Contact(FirstName = 'Sonali', LastName = 'Sharma', Email = 'sonali.sharma@example.com', AccountId = existingAccount.Id);
        insert existingContact;
        RestRequest req = new RestRequest();
        req.requestURI = '/myAccountServices/';
        req.httpMethod = 'POST';
        req.addParameter('accountName', 'Existing Account');
        req.addParameter('firstName', 'Sonali');
        req.addParameter('lastName', 'Sharma');
        req.addParameter('email', 'sonali.sharma@example.com');
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        String response = MyAccountServicesIntegration.createAccountAndContact('Existing Account', 'Sonali', 'Sharma', 'sonali.sharma@example.com');
        Test.stopTest();
        System.assert(response.contains('"error": "A contact with this email already exists for the Account'));
    }
}