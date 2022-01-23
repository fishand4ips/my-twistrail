public class OpportunityTriggerHandler extends TriggerHandler {

    private List<Opportunity> newList = new List<Opportunity>();
    private Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();

    private static final String GROUP_SALE_RECORD_TYPE = 'DIY_Group_Sale';
    private static final String CAMPUS_SALE_RECORD_TYPE = 'DIY_Campus_Sale';
    private static final String OPPORTUNITY = 'Opportunity';
    private static final String OPP_STAGE_CLOSED_WON = 'Closed Won';
    private static final String ERROR_INFO_FOR_NUMBER_OF_STUDENTS = 'The Number of Students field must be positive.';

    public OpportunityTriggerHandler(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        this.newList = newList;
        this.oldMap = oldMap;
    }

    public override void beforeInsert() {   
        this.changerRecordTypeOpp(newList);
    }

    public override void beforeUpdate() {
        List<Account_Interest__c> accInterest = new List<Account_Interest__c>();
        this.changerRecordTypeOpp(newList);
        this.removeAccountInterest(newList);
        for (Opportunity opportunity : newList) {
            this.generateAccountInterest(opportunity, accInterest);
        }
    }

    private void generateAccountInterest(Opportunity opp, List<Account_Interest__c> accInterest) {
        List<OpportunityLineItem> relatedProdInfo = [
            SELECT Product2id, Product2.ProductCode, Product2.Name, Opportunity.Name 
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :newList
        ];

        for (OpportunityLineItem oppProd : relatedProdInfo) {
            List<Object> parameters = new List<Object> {
                oppProd.Opportunity.Name, 
                oppProd.Product2.ProductCode, 
                oppProd.Product2.Name
            };

            String accInterestName = String.format('Opportunity: "{0}" with product code: "{1}" and name: "{2}"', parameters);
            if (opp.StageName == OPP_STAGE_CLOSED_WON) {
                System.debug(opp);
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

    private void removeAccountInterest(List<Opportunity> opportunities) {
        List<Account_Interest__c> accInterestList = [
            SELECT Id
            FROM Account_Interest__c 
            WHERE Deal_link__c IN :opportunities
        ];

        for (Opportunity opportunity : opportunities) {
            if ((oldMap.get(opportunity.Id)).StageName == OPP_STAGE_CLOSED_WON) {
                delete accInterestList;
            }
        }
    }

    private void changerRecordTypeOpp(List<Opportunity> opportunities) {
        for (Opportunity opportunity : opportunities) {
            if (opportunity != null) {
                if (opportunity.Number_of_Students__c > 50) {
                    opportunity.RecordTypeID = getRecordTypesOpportunity().get(CAMPUS_SALE_RECORD_TYPE);
                } else if (opportunity.Number_of_Students__c >= 0 && opportunity.Number_of_Students__c <= 50) {
                    opportunity.RecordTypeID = getRecordTypesOpportunity().get(GROUP_SALE_RECORD_TYPE);
                } else {
                    opportunity.addError(ERROR_INFO_FOR_NUMBER_OF_STUDENTS);
                }
            }
        }
    }

    private Map<String, Id> getRecordTypesOpportunity() {
        Map<String, Id> opportunityRecordTypes = new Map<String, Id>();
        for (RecordType rt : [SELECT DeveloperName, Id FROM RecordType WHERE sObjectType = :OPPORTUNITY]) {
            opportunityRecordTypes.put(rt.DeveloperName, rt.Id);
        }
        return opportunityRecordTypes;
    }
}