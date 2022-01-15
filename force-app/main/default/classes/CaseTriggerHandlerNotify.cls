public with sharing class CaseTriggerHandlerNotify {
    public override void afterInsert(){
        CaseTriggerHelper.publishPlatformEvent(Trigger.new);
        CaseTriggerHelper.sendBellNotification(Trigger.new);
    }

    public override void afterUpdate(){
        CaseTriggerHelper.publishPlatformEvent(Trigger.new);
        CaseTriggerHelper.sendBellNotification(Trigger.new);
    }
}
