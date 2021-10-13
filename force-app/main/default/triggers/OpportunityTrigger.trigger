trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    new OpportunityTriggerHandler().run();
}