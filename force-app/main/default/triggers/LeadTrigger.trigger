trigger LeadTrigger on Lead (before update, after insert) {
  new LeadTriggerHandler().run();
}