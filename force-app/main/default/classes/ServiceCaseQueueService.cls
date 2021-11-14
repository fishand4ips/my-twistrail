public inherited sharing class ServiceCaseQueueService {
    @AuraEnabled(cacheable=true)
    public static List<Case> getUserCases() {
        String userId = UserInfo.getUserId();
        List<Id> queueId = QueryUtils.existUserInQueueList(userId);
        return [
            SELECT Owner.Name, Origin, OwnerId, Id, CaseNumber, AccountId,
            Account.Name, ContactId, Contact.Name, Status, Priority,
            Service_Flow_Completed__c
            FROM Case
            WHERE OwnerId IN :queueId
            OR OwnerId = :userId
            WITH SECURITY_ENFORCED 
            ORDER BY Priority_Range__c, CreatedDate DESC
            LIMIT 25
        ];
    }

    @AuraEnabled
    public static String updateCase(Object data) {
        List<Case> caseForUpdate = (List<Case>) JSON.deserialize(
            JSON.serialize(data),
            List<Case>.class
        );
        if (Schema.sObjectType.Case.isUpdateable()) {
            try {
                update caseForUpdate;
                return 'Success: Case updated successfully';
            }
            catch (Exception e) {
                return 'The following exception has occurred: ' + e.getMessage();
            }
        } else {
            return 'You do not access for update Case';
        }
    }
}