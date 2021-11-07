@isTest
public class AccountProcessorTest {

    @testSetup
    public static void init() {
        Account account = new Account(
            Name = 'Google'
        );
        insert account;
        
        Contact contact = new Contact(
            FirstName = 'Alex',
            LastName =  'Kome',
            AccountId = account.Id
        );

        Contact contact2 = new Contact(
            FirstName = 'Felix',
            LastName = 'Emok',
            AccountId = account.Id
        );
    }
    
    @isTest
    public static void countContactsTest() {
        List<Id> accountId = new List<Id>(new Map<Id, Account>([SELECT Id FROM Account]).keySet());
        Test.startTest();
        AccountProcessor.countContacts(accountId);
        Test.stopTest();
    }
    
}