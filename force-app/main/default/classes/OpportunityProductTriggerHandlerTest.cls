@isTest
private class OpportunityProductTriggerHandlerTest {
  @isTest
  static void afterInsertTest() {
    Id pricebookId = Test.getStandardPricebookId();
    System.debug('id: ' + pricebookId);
    String fake = TestUtility.getFakeId(Account.sObjectType);
    System.debug('fake: ' + fake);
  }
}
