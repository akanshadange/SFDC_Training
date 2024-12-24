@isTest
public class LeadProcessorTest {
    @isTest
    //Test method of LeadProcessor
    static void testLeadProcessor() {
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            testLeads.add(new Lead(FirstName = 'Test',LastName = 'Lead' + i,Company = 'Test Company',LeadSource = 'Web'));
        }
        insert testLeads;  
        Test.startTest();
        LeadProcessor leadProcessor = new LeadProcessor();
        Database.executeBatch(leadProcessor, 200); 
        Test.stopTest(); 
        List<Lead> updatedLeads = [SELECT LeadSource FROM Lead WHERE Id IN :testLeads];
        for (Lead lead : updatedLeads) {
            Assert.areEqual('Dreamforce',lead.LeadSource,'LeadSource should be updated to Dreamforce');
        }
    }
}