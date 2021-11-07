public class ProductTriggerHandler extends TriggerHandler {

    private List<Product2> newList = new List<Product2>();
    private List<Product2> oldList = new List<Product2>();
    private Map<Id, Product2> newMap = new Map<Id, Product2>();
    private Map<Id, Product2> oldMap = new Map<Id, Product2>();
    private static final String ERROR_INFO_NOT_EXISTS_PRODUCT_CODE = 'Such product code is not allowed in the system. Please update the PFC mapping or contact administrator.';

    public ProductTriggerHandler(List<Product2> newList, List<Product2> oldList, Map<Id, Product2> newMap, Map<Id, Product2> oldMap) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public override void afterInsert() {
        List<Product2> finalProd = new List<Product2>();
        List<Product2> products = [SELECT ProductCode, Family FROM Product2 WHERE Id IN :newList];

        for (Product2 product : products) {
            if (isExistsProductCode()) {
                selectorProductFamilyBoard(product);
                update product;
                CreateUpdateMetadataProduct2.buildMetadata(product.Id);
            } else {
                newList.get(0).addError(ERROR_INFO_NOT_EXISTS_PRODUCT_CODE);
                break;
            }
        }
    }

    public override void beforeUpdate() {
        for (Product2 product : newList) {  
            if (isExistsProductCode()) {
                selectorProductFamilyBoard(product);
            } else {
                product.addError(ERROR_INFO_NOT_EXISTS_PRODUCT_CODE);
            }
            CreateUpdateMetadataProduct2.buildMetadata(product.Id);
        }
    }

    public override void afterUpdate() {
        List<OpportunityLineItem> relatedOppProducts = [
            SELECT Id, Product_Family__c, Product2.Family 
            FROM OpportunityLineItem 
            WHERE Product2Id IN :newList
        ];

        for (OpportunityLineItem oppProductItem : relatedOppProducts) {
            if (relatedOppProducts.size() > 0) {
                oppProductItem.Product_Family__c = oppProductItem.Product2.Family;
            }
        }
        update relatedOppProducts;
    }

    private Boolean isExistsProductCode() {
        Set<String> mdProductCodeSet = new Set<String>();

        for (Product_Family_by_Code_Mapping__mdt mdRecord : [SELECT Product_Code__c FROM Product_Family_by_Code_Mapping__mdt]) {
            mdProductCodeSet.add(mdRecord.Product_Code__c);
        }

        for (Product2 product : newList) {
            if (!mdProductCodeSet.contains(product.ProductCode)) {
                return false;
            }
        }
        return true;
    }

    private void selectorProductFamilyBoard(Product2 product) {
        if (product.ProductCode == ProductCode.ONE || product.ProductCode == ProductCode.TWO || product.ProductCode == ProductCode.THREE) {
            product.Family = ProductFamily.ARDUINO;
        } else {
            product.Family = ProductFamily.OTHER;
        }
    }

}