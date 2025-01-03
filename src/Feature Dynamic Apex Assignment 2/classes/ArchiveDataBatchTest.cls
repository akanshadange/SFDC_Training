@isTest(SeeAllData=true)
//Test Method Of ArchieveDataBatch
private class ArchiveDataBatchTest {
    @isTest
    static void testArchiveDataBatch() {
        List<Archive_Config__mdt> archiveConfigs=[SELECT Developer_Name__c, Label, Duration__c, Filter__c
                                                  FROM Archive_Config__mdt WHERE Developer_Name__c = 'Account' LIMIT 1];
        ArchiveDataBatch archiveBatch = new ArchiveDataBatch(archiveConfigs[0].Developer_Name__c);
        Test.startTest();
        Database.executeBatch(archiveBatch); 
        Test.stopTest();
        Assert.isTrue(ArchiveDataBatch.emailsInvocations > 0, 'At least one email should have been sent.');
        Assert.areEqual(1, ArchiveDataBatch.emailsInvocations, 'Exactly one email should have been sent.');
        List<Account> accRecords = [SELECT Id FROM Account WHERE Name ='Xoriant'];
        Assert.areEqual(0, accRecords.size(), 'The records should be deleted after the batch runs.');
    }
}