public class CaseTriggerHandler extends TriggerHandler {
    String title;
    String body;
    Set<String> recipientsIds;
    String targetId;
    String userId = UserInfo.getUserId();

    public override void afterInsert() {
        for (Case cs : (List<Case>) Trigger.new) {
            title = 'Queue member notification';
            List<Object> caseInfo = new List<Object> {cs.CaseNumber, cs.OwnerId, cs.Origin};
            body = String.format('New Case [{0}] is available. Direct link: [{1}]. Case inbox: [{2}].', caseInfo);
            recipientsIds = QueryUtils.existUserInQueueSet(userId);
            targetId = cs.OwnerId;
        }
        CustomNotification customNotification = new CustomNotification(body, title, recipientsIds, targetId);
        customNotification.buildNotify();
    }
}