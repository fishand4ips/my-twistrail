trigger OpportunityProductTrigger on OpportunityLineItem (before insert, before update, after insert, after update) {
    new OpportunityProductTriggerHandler(Trigger.new).run();
}