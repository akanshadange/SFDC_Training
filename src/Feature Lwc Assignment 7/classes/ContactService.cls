public  class ContactService {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccountId(Id accountId) 
    {
        return ContactSelector.getContactsByAccountId(accountId);
    }
    @AuraEnabled
    public static void createContact(Id accountId, String firstName, String lastName, String email) {
        Contact newContact = new Contact(AccountId = accountId,FirstName = firstName,LastName = lastName,Email = email);
        try {
            insert newContact;
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while creating the contact: ' + e.getMessage());
        }
    }
}