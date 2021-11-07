public class OpportunityTriggerHandler extends TriggerHandler {

    private static final String GROUP_SALE_RECORD_TYPE = 'DIY_Group_Sale';
    private static final String CAMPUS_SALE_RECORD_TYPE = 'DIY_Campus_Sale';
    private static final String OPPORTUNITY = 'Opportunity';
    private static final String OPP_STAGE_CLOSED_WON = 'Closed Won';
    private static final String ERROR_INFO_FOR_NUMBER_OF_STUDENTS = 'The Number of Students field must be positive.';

    public override void beforeInsert() {   
        for (Opportunity opp : (List<Opportunity>) Trigger.new) {     
            this.changerRecordTypeOpp(opp);
        }
    }

    public override void beforeUpdate() {
        List<Account_Interest__c> accInterest = new List<Account_Interest__c>();
        for (Opportunity opp : (List<Opportunity>) Trigger.new) {
            this.changerRecordTypeOpp(opp);
            this.generateAccountInterest(opp, accInterest);
            this.removeAccountInterest(opp);
        }
    }

    private void generateAccountInterest(Opportunity opp, List<Account_Interest__c> accInterest) {
        List<OpportunityLineItem> relatedProdInfo = [
            SELECT Product2id, Product2.ProductCode, Product2.Name, Opportunity.Name 
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :Trigger.new
        ];

        for (OpportunityLineItem oppProd : relatedProdInfo) {
            List<Object> parameters = new List<Object> {
                oppProd.Opportunity.Name, 
                oppProd.Product2.ProductCode, 
                oppProd.Product2.Name
            };

            String accInterestName = String.format('Opportunity: "{0}" with product code: "{1}" and name: "{2}"', parameters);
            if (opp.StageName == OPP_STAGE_CLOSED_WON) {
                accInterest.add(new Account_Interest__c(
                    Name = accInterestName,
                    Deal_Link__c = opp.id, 
                    Product_lookup__c = oppProd.Product2id,
                    Account_lookup__c = opp.AccountId
                ));
            }
        }
        insert accInterest;
    }

    private void removeAccountInterest(Opportunity opp) {
        List<Account_Interest__c> accInterestList = [
            SELECT Id
            FROM Account_Interest__c 
            WHERE Deal_link__c IN :Trigger.new
        ];

        if (((Opportunity)Trigger.oldMap.get(opp.Id)).StageName == OPP_STAGE_CLOSED_WON) {
            delete accInterestList;
        }
    }

    private void changerRecordTypeOpp(Opportunity opp) {
        if (opp != null) {
            if (opp.Number_of_Students__c > 50) {
                opp.RecordTypeID = recordTypeOpportunity().get(CAMPUS_SALE_RECORD_TYPE);
            } else if (opp.Number_of_Students__c >= 0 && opp.Number_of_Students__c <= 50) {
                opp.RecordTypeID = recordTypeOpportunity().get(GROUP_SALE_RECORD_TYPE);
            } else {
                opp.addError(ERROR_INFO_FOR_NUMBER_OF_STUDENTS);
            }
        }
    }

    private Map<String, Id> recordTypeOpportunity() {
        Map<String, Id> opportunityRecordTypes = new Map<String, Id>();
        for (RecordType rt : [SELECT DeveloperName, Id FROM RecordType WHERE sObjectType = :OPPORTUNITY]) {
            opportunityRecordTypes.put(rt.DeveloperName, rt.Id);
        }
        return opportunityRecordTypes;
    }
}