trigger ProductTrigger on Product2 (before update, after insert, after update) {
    new ProductTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap).run();
}