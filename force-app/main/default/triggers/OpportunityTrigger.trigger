trigger OpportunityTrigger on Opportunity (before insert, before update) {
    new OpportunityTriggerHandler(Trigger.new, Trigger.oldMap).run();
}