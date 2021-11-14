public without sharing class OpportunityProductTriggerHandler extends TriggerHandler {
    private List<OpportunityLineItem> newList;

    public OpportunityProductTriggerHandler(List<OpportunityLineItem> newList) {
        this.newList = newList;
    }

    public override void afterInsert() {        
        List<OpportunityLineItem> oppProdList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> relatedProducts = [
            SELECT Id, Name, PricebookEntry.Product2.Family 
            FROM OpportunityLineItem 
            WHERE Id IN :newList
            WITH SECURITY_ENFORCED
        ];
           
        if (!relatedProducts.isEmpty()) {
            for (OpportunityLineItem item : relatedProducts) {
                item.Product_Family__c = item.PricebookEntry.Product2.Family;
                oppProdList.add(item);
            }
            if (Schema.sObjectType.OpportunityLineItem.fields.Product_Family__c.isUpdateable()) {
                update oppProdList;
            }
        }
    }
}