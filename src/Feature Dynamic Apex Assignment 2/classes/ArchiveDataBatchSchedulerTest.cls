@isTest
//Test Method Of ArchieveDataBatchScheduler
public class ArchiveDataBatchSchedulerTest {
    @isTest
    static void testScheduleBatchJob() {
        Test.startTest();
        ArchiveDataBatchScheduler.scheduleBatchJob();
        Test.stopTest();
        CronTrigger scheduledJob = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'Monthly Archive Data Batch' LIMIT 1];
        Assert.areEqual('0 0 1 * * ?',scheduledJob.CronExpression,'The cron expression should be 0 0 1 * * ?');
    }
}