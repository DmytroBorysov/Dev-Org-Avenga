trigger LineItemTrigger on Line_Item__c (after insert, after update, after delete, after undelete) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            LineItemTriggerHandler.onAfterInsert(Trigger.new);
        }
        when AFTER_UPDATE {
            LineItemTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        when AFTER_DELETE {
            LineItemTriggerHandler.onAfterDelete(Trigger.old);
        }
        when AFTER_UNDELETE {
            LineItemTriggerHandler.onAfterInsert(Trigger.new);
        }
    }
}