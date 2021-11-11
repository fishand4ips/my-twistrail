public with sharing class RelatedContactsController {

    @AuraEnabled
    public static List<Contact> getRelatedList(Id recordId) {
        return [
            SELECT Id, FirstName, LastName, Title, Email, AccountId
            FROM Contact 
            WHERE AccountId = :recordId 
        ];
    }
}