public without sharing class AccountCasesPdfCtrl {
    public static List<Case> getAccountCasesPrevWeek() {
        return [SELECT Account.Name, Owner.Name, CaseNumber, Status, Priority, Origin 
                FROM Case
                WHERE CreatedDate > LAST_WEEK
                ORDER BY Account.Name, CreatedDate];
    }
}