trigger TransactionTrigger on Transaction__c (after update) {
    TransactionTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
}