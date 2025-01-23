public class AccountSupportScoreBatchScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        AccountSupportScoreBatch accountSupportscore = new AccountSupportScoreBatch();
        Database.executeBatch(accountSupportscore);
    }
    public static void scheduleBatchJob() {
        String cronExpression = '0 0 5 * * ?';  
        System.schedule('Daily AccountSupportScoreBatchScheduler Batch running', cronExpression, new AccountSupportScoreBatchScheduler());
    }
}
//AccountSupportScoreBatchScheduler.scheduleBatchJob();