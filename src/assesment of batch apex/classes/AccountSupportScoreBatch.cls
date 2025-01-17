public class AccountSupportScoreBatch implements Database.Batchable<sObject>,Database.stateful {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, AccountId, Priority, CreatedDate FROM Case WHERE Status !='Closed']);
    }
    public void execute(Database.BatchableContext BC, List<Case> cases) {
        Map<Id, Decimal> accountScoreMap = new Map<Id, Decimal>();
        for (Case c : cases) {
            
            if (c.AccountId == null)continue;
            Decimal score = calculateCaseScore(c);
            if (accountScoreMap.containsKey(c.AccountId)) {
                accountScoreMap.put(c.AccountId, accountScoreMap.get(c.AccountId) + score);
            } else {
                accountScoreMap.put(c.AccountId,score);
            }
        }
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountScoreMap.keySet()) {
            Account acc = new Account(Id = accountId);
            acc.Support_Score__c = accountScoreMap.get(accountId);
            accountsToUpdate.add(acc);
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
            System.debug('Updated accounts: ' + accountsToUpdate.size());
        }
    }
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch job execution is completed');
    }
    
    private Decimal calculateCaseScore(Case c) {
        Decimal supportScore;
        if (c.Priority == 'High') {
            supportScore = 3;
        } else if (c.Priority == 'Medium') {
            supportScore = 2;
        } else if (c.Priority == 'Low') {
            supportScore = 1;
        }
        //Integer caseInDays = Date.today().daysBetween();
        Integer caseInDays;
        if (caseInDays <= 30) {
            supportScore += 1;
        } else if (caseInDays > 60) {
            supportscore -= 1;
        }
        if (supportscore < 0) {
            supportscore = 0;
        }
        return supportscore;
    }
}