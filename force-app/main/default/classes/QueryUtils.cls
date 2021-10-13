public with sharing class QueryUtils {

    private static List<GroupMember> existUserInQueue(String userId) {
        return [SELECT Group.Id 
                FROM GroupMember 
                WHERE GroupId In (SELECT Id FROM Group WHERE type = 'Queue')
                AND UserOrGroupId = :userId];
    }

    public static List<Id> existUserInQueueList(String userId) {
        List<GroupMember> queues = existUserInQueue(userId);
        List<Id> queueList = new List<Id>();
        for (GroupMember memberQueue: queues) {
            queueList.add(memberQueue.GroupId);
        }
        return queueList;
    }

    public static Set<String> existUserInQueueSet(String userId) {
        List<GroupMember> queues = existUserInQueue(userId);
        Set<String> queueSet = new Set<String>();
        for (GroupMember memberQueue : queues) {
            queueSet.add(memberQueue.GroupId);
        }
        return queueSet;
    }

}
