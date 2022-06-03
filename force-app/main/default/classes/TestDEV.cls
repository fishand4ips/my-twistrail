public with sharing class TestDEV implements Dispatcher {
  public void dispatch(String what) {
    System.debug('dispatch');
  }

  public static Account aQuery() {
    Account theAccount;
    try {
      System.debug('Querying Accounts.');
      theAccount = [
        SELECT Id
        FROM Account
        WHERE CreatedDate > TODAY
        WITH SECURITY_ENFORCED
      ];
    } catch (CustomException ex) {
      System.debug('Custom Exception.');
    } catch (QueryException ex) {
      System.debug('Query Exception.');
    } finally {
      System.debug('Done.');
    }
    return theAccount;
  }

  public static void question68() {
    List<Account> aList = [SELECT Id FROM Account LIMIT 5];
    for (Account a : aList) {
      List<Contact> cList = [SELECT id FROM contact WHERE AccountId = :a.Id];
    }
    System.debug('complete');
  }

  public static void question69() {
    List<List<sObject>> searchList = [
      FIND '*Ronaldo*'
      IN ALL FIELDS
      RETURNING Contact, Lead
    ];
    System.debug('SOSL >>> ' + searchList);
  }

  public static void question82() {
    Account a = new Account(Name = 'a');
    try {
      Database.insert(a, false);
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
  }

  public static void question118() {
    for (List<Lead> theseLeads : [
      SELECT LastName, Company, Email
      FROM Lead
      LIMIT 20000
    ]) {
      System.debug(theseLeads);
    }
  }

  public void question125() {
    Boolean isOK;
    Integer x;
    String theString = 'Hello';
    if (isOK == false && theString == 'Hello') {
      x = 1;
    } else if (isOK == true && theString == 'Hello') {
      x = 2;
    } else if (isOK != null && theString == 'Hello') {
      x = 3;
    } else {
      x = 4;
    }
    System.debug('isOK::: ' + isOK); // 1
    System.debug('x::: ' + x); // 2
    System.debug('theString::: ' + theString); // 3
  }

  public static void question9from65() {
    Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
    String parentId = nonAlphanumeric.matcher(
        ApexPages.currentPage().getParameters().get('Id')
      )
      .replaceAll('')
      .escapeHtml4();
    System.debug('test::: ' + parentId);
  }

  public static void question15from65() {
    List<Case> casesToUpdate = new List<Case>();
    for (Case thisCase : [SELECT Id, Status FROM Case LIMIT 50000]) {
      thisCase.Status = 'Working';
      casesToUpdate.add(thisCase);
    }
    try {
      Database.update(casesToUpdate, false);
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
  }

  public static void generateAccounts(Integer quantity) {
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < quantity; i++) {
      Account newAccount = new Account(
        Name = 'Tik Tok ' + i,
        BillingCity = 'San Francisco',
        BillingCountry = 'California'
      );
      accounts.add(newAccount);
    }
    Database.insert(accounts, false);
  }

  public static void question48from62() {
    for (Account thisAcc : [SELECT Id, Industry FROM Account LIMIT 150]) {
      if (thisAcc.Industry == 'Test') {
        thisAcc.IsPartner = true;
      }
      update thisAcc;
    }
  }
  abstract class CustomException extends Exception {
  }
  class NewCustomException extends CustomException {
  }

  public abstract class Calculator {
    Integer y;
    public virtual void calculate(Integer x) {
      Integer result = Math.abs(x);
    }
  }

  public class ShippingCalculator extends Calculator {
    public override void calculate(Integer x) {
      Integer result = Math.abs(x + 5);
    }
  }

  public class SnippetCalculator extends Calculator {
  }

  public interface PurchaseOrder {
    Double discount();
  }

  public class CustomerPurchaseOrder implements PurchaseOrder {
    public Double discount() {
      return .05;
    }
  }

  public class EmployeePurchaseOrder implements PurchaseOrder {
    public Double discount() {
      return .10;
    }
  }
}
