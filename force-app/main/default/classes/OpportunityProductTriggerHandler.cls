public without sharing class OpportunityProductTriggerHandler extends TriggerHandler {
    private List<OpportunityLineItem> newList;

    public OpportunityProductTriggerHandler(List<OpportunityLineItem> newList) {
        this.newList = newList;
    }

    public override void afterInsert() {        
        List<OpportunityLineItem> oppProdList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> relatedProducts = [
            SELECT Id, Name, PricebookEntry.Product2.Family, Product2.Family
            FROM OpportunityLineItem 
            WHERE Id IN :newList
            WITH SECURITY_ENFORCED
        ];
           
        if (!relatedProducts.isEmpty()) {
            for (OpportunityLineItem item : relatedProducts) {
                item.Product_Family__c = item.PricebookEntry.Product2.Family;
                oppProdList.add(item);
                System.debug('1::: ' + item.Product2.Family);
                System.debug('2::: ' + item.PricebookEntry.Product2.Family);
            }
            if (Schema.sObjectType.OpportunityLineItem.fields.Product_Family__c.isUpdateable()) {
                update oppProdList;
            }
        }
    }
}