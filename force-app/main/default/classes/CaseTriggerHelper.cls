public with sharing class CaseTriggerHelper {

    private final static String NEW_INCOMING_CASE_TYPE = 'New_Incoming_Case';
    private final static String GROUP_TYPE_QUEUE = 'Queue';
    private final static String QUEUE_INCOMING_CASES = 'Incoming_Cases';
    
    public static void publishPlatformEvent(List<Case> cases){	
        List<RefreshDataTable__e> refreshDataTableEvents = new List<RefreshDataTable__e>();
        for (Case triggCase : cases) {
            refreshDataTableEvents.add(new RefreshDataTable__e(
                RecordId__c = triggCase.Id
            ));
        }
        EventBus.publish(refreshDataTableEvents);
    }

    public static void sendBellNotification(List<Case> triggeredCases) {
        List<Group> queue = [
            SELECT Id 
            FROM Group 
            WHERE Type = :GROUP_TYPE_QUEUE AND DeveloperName = :QUEUE_INCOMING_CASES
        ];
        List<Case> casesFromQueue = new List<Case>();

        for(Case triggeredCase : triggeredCases){
            if(triggeredCase.OwnerId == queue[0].Id){
                casesFromQueue.add(triggeredCase);
            }
        }

        if(!casesFromQueue.isEmpty()){
            CustomNotificationType notificationType = [
                SELECT Id, DeveloperName 
                FROM CustomNotificationType 
                WHERE DeveloperName = :NEW_INCOMING_CASE_TYPE
            ];

            for (Case caseFromQueue : casesFromQueue){
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('New Case in queue');
                notification.setBody('New Case' + caseFromQueue.CaseNumber + 'is available.');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(caseFromQueue.Id);
                try {
                    notification.send(new Set<String>{queue[0].Id});
                }
                catch (Exception e) {
                    System.debug('Problem sending notification: ' + e.getMessage());
                }
            }
        } 
    }
}
