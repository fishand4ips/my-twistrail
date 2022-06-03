public with sharing class InsertData {
  public static List<Account> createAcc() {
    List<Account> accounts = new List<Account>();
    accounts.add(
      new Account(Name = 'Test1', Description = 'Test', external = 123)
    );
    accounts.add(
      new Account(Name = 'Test2', Description = 'Test', external = 123)
    );
    accounts.add(
      new Account(Name = 'Test', Description = 'Test', external = 123)
    );
    accounts.add(
      new Account(Name = 'Test', Description = 'Test', external = 123)
    );
    accounts.add(
      new Account(Name = 'Test', Description = 'Test', external = 123)
    );
    accounts.add(
      new Account(Name = 'Test', Description = 'Test', external = 123)
    );
    insert accounts;
    delete accounts;
    return accounts;
  }

  public static Id createContact() {
    List<Contact> contacts = new List<contact>();
    contacts.add(
      new contact(Name = 'Test1', Description = 'Test', external = 123)
    );
    contacts.add(
      new contact(Name = 'Test2', Description = 'Test', external = 123)
    );
    contacts.add(
      new contact(Name = 'Test', Description = 'Test', external = 123)
    );
    contacts.add(
      new contact(Name = 'Test', Description = 'Test', external = 123)
    );
    contacts.add(
      new contact(Name = 'Test', Description = 'Test', external = 123)
    );
    contacts.add(
      new contact(Name = 'Test', Description = 'Test', external = 123)
    );
    insert contact;
    List<Account> allAcc = createAcc();
    List<String> extIds = new List<String>();
    for (Account acc : allAcc) {
      extIds.add(acc.external);
    }
  }
}
