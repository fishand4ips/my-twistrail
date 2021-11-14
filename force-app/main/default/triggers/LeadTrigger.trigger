trigger LeadTrigger on Lead (before update, after insert) {
  new LeadTriggerHandler(Trigger.new, Trigger.oldMap).run();
}