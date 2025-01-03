/*
Purpose			: Scheduler Class to run the ArchieveDatabatch class on the 1st Day of every month at Midnight.
Created Date	: 1-1-24
Created By		: Akansha Dange
*/

public class ArchiveDataBatchScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        ArchiveDataBatch archiveBatch = new ArchiveDataBatch('Account');
        Database.executeBatch(archiveBatch); 
    }
    public static void scheduleBatchJob() {
        String cronExpression = '0 0 0 1 * ?';
        System.schedule('Monthly Archive Data Batch', cronExpression, new ArchiveDataBatchScheduler());
    }
}