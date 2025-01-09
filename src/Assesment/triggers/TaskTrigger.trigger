trigger TaskTrigger on Task (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)) {
        AccounttaskActivityRollupHandler.updateActivityCounts(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isDelete) {
        AccounttaskActivityRollupHandler.updateActivityCounts(Trigger.old, null);
    }
}