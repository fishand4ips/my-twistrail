public with sharing class AccountProcessor {

    @future
    public static void countContacts(List<Id> recordIds) {
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :recordIds];
        List<Account> updateToAccounts = new List<Account>();
        for (Account account : accounts) {
            account.Number_of_Contacts__c = [SELECT count() FROM Contact WHERE AccountId = :account.Id];
            updateToAccounts.add(account);
        }
        update updateToAccounts;        
    }
}