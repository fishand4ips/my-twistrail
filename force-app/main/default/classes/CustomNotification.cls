public without sharing class CustomNotification {

    private String title {get; set;}
    private String body {get; set;}
    private Set<String> recipientsIds {get; set;}
    private String targetId {get; set;}

    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    CustomNotificationType notificationType = [
        SELECT Id, DeveloperName
        FROM CustomNotificationType 
        WHERE DeveloperName = 'New_or_Assigned_Back_Case'
    ];

    public CustomNotification(String body, String title, Set<String> recipientsIds, String targetId) {
        this.body = body;
        this.title = title;
        this.recipientsIds = recipientsIds;
        this.targetId = targetId;
    }

    public void buildNotify() {
        notification.setTitle(title);
        notification.setBody(body);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}