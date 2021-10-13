trigger EventCaseTrigger on CaseChangeEvent (after insert) {
    List<CaseChangeEvent> changes = Trigger.new;
    List<Case_Changer__e> notifications = new List<Case_Changer__e>();
    String tmpField;
    for (CaseChangeEvent event : changes) {
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        for (String field : header.changedFields) {
            if (null == event.get(field)) {
                tmpField = field;
            } else {
                tmpField =  JSON.serialize(event.get(field));
            }
        }
        notifications.add(new Case_Changer__e(
            Header__c = JSON.serialize(event),
            Case_Number__c = event.CaseNumber,
            Origin__c = event.Origin,
            Owner_Name__c = tmpField,
            Priority__c = event.Priority,
            Status__c = event.Status
        ));
    }

    List<Database.SaveResult> results = EventBus.publish(notifications);
    for (Database.SaveResult result : results) {
        if (!result.isSuccess()) {
            for (Database.Error error : result.getErrors()) {
                System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
            }
        }
    }
}