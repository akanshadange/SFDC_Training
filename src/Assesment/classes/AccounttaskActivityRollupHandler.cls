public class AccounttaskActivityRollupHandler {
    public static void updateActivityCounts(List<Task> newRecords, Map<Id, Task> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        if (!newRecords.isEmpty()) {
            for (Task newTask : newRecords) {
                if (newTask.WhatId != null) {
                    accountIds.add(newTask.WhatId);
                }
                if (oldMap != null && oldMap.containsKey(newTask.Id)) {
                    Task oldTask = oldMap.get(newTask.Id);
                    if (oldTask.WhatId != null && oldTask.WhatId != newTask.WhatId) {
                        accountIds.add(oldTask.WhatId);
                    }
                }
            }
        }
        if (!accountIds.isEmpty()) {
            List<AggregateResult> totalActivityResults = [SELECT WhatId, COUNT(Id) totalActivities
                                                          FROM Task
                                                          WHERE WhatId IN :accountIds
                                                          GROUP BY WhatId];
            List<AggregateResult> openActivityResults = [SELECT WhatId, COUNT(Id) totalOpenActivities
                                                         FROM Task
                                                         WHERE WhatId IN :accountIds AND Status != 'Completed'
                                                         GROUP BY WhatId];
            List<AggregateResult> closedActivityResults = [SELECT WhatId, COUNT(Id) totalClosedActivities
                                                           FROM Task
                                                           WHERE WhatId IN :accountIds AND Status = 'Completed'
                                                           GROUP BY WhatId];
            Map<Id, Account> accountUpdates = new Map<Id, Account>();
            for (Id ids : accountIds) {
                Account acc = new Account();
                acc.Id = ids;
                acc.Total_Activities__c = 0;
                acc.Total_Open_Activities__c = 0;
                acc.Total_Closed_Activities__c = 0;
                accountUpdates.put(acc.Id, acc);
            }
            for (AggregateResult ar : totalActivityResults) {
                Account acc = accountUpdates.get((Id) ar.get('WhatId'));
                acc.Total_Activities__c = (Integer) ar.get('totalActivities');
            }
            for (AggregateResult ar : openActivityResults) {
                Account acc = accountUpdates.get((Id) ar.get('WhatId'));
                acc.Total_Open_Activities__c = (Integer) ar.get('totalOpenActivities');
            }
            
            for (AggregateResult ar : closedActivityResults) {
                Account acc = accountUpdates.get((Id) ar.get('WhatId'));
                acc.Total_Closed_Activities__c = (Integer) ar.get('totalClosedActivities');
            }
            if (!accountUpdates.isEmpty()) {
                update accountUpdates.values();
            }
        }
    }
}