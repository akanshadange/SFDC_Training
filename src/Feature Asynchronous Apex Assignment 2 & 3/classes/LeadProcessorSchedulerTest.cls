@isTest
//Test Method Of LeadProcessorScheduler
public class LeadProcessorSchedulerTest {
    @isTest
    static void testScheduleBatchJob() {
        Test.startTest();
        LeadProcessorScheduler.scheduleBatchJob();
        Test.stopTest();
        CronTrigger scheduledJob = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name = 'Daily Lead Processor Batch' LIMIT 1];
        Assert.areEqual('0 0 2 * * ?',scheduledJob.CronExpression,'The cron expression should be 0 0 2 * * ?');
    }
}