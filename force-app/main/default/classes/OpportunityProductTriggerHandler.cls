public class OpportunityProductTriggerHandler extends TriggerHandler {

    public override void afterInsert() {        
        List<OpportunityLineItem> oppProdList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> prod = [SELECT Id, Name, PricebookEntry.Product2.Family 
                                          FROM OpportunityLineItem 
                                          WHERE Id IN :Trigger.new];
                                          
        for (OpportunityLineItem opps : prod) {
            if (prod.size() > 0) {
                opps.Product_Family__c = opps.PricebookEntry.Product2.Family;
                oppProdList.add(opps);
            }
        }
        update oppProdList;
    }
}