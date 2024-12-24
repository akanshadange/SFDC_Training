/*
Purpose			: Schedule the LeadProcessor batch class to run daily at a specific time
Created Date	: 18-12-24
Created By		: Akansha Dange
*/

public class LeadProcessorScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        LeadProcessor leadProcessor = new LeadProcessor();
        Database.executeBatch(leadProcessor, 200);
    }
    public static void scheduleBatchJob() {
        String cronExpression = '0 0 2 * * ?';  
        System.schedule('Daily Lead Processor Batch', cronExpression, new LeadProcessorScheduler());
    }
}