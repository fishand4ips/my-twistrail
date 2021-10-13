public class ProductTriggerHandler extends TriggerHandler {

    private static final String ERROR_INFO_NOT_EXISTS_PRODUCT_CODE = 'Such product code is not allowed in the system. Please update the PFC mapping or contact administrator.';

    public override void afterInsert() {
        List<Product2> finalProd = new List<Product2>();
        List<Product2> products = [SELECT ProductCode, Family FROM Product2 WHERE Id IN :Trigger.new];

        for (Product2 product : products) {
            if (isExistsProductCode()) {
                selectorProductFamilyBoard(product);
                update product;
                CreateUpdateMetadataProduct2.buildMetadata(product.Id);
            } else {
                Trigger.new[0].addError(ERROR_INFO_NOT_EXISTS_PRODUCT_CODE);
                break;
            }
        }
    }

    public override void beforeUpdate() {
        for (Product2 product : (List<Product2>) Trigger.new) {  
            if (isExistsProductCode()) {
                selectorProductFamilyBoard(product);
            } else {
                product.addError(ERROR_INFO_NOT_EXISTS_PRODUCT_CODE);
            }
            CreateUpdateMetadataProduct2.buildMetadata(product.Id);
        }
    }

    public override void afterUpdate() {
        List<OpportunityLineItem> relatedOppProducts = [SELECT Id, Product_Family__c, Product2.Family 
                                                        FROM OpportunityLineItem 
                                                        WHERE Product2Id IN :Trigger.new];

        for (OpportunityLineItem oppProductItem : relatedOppProducts) {
            if (relatedOppProducts.size() > 0) {
                oppProductItem.Product_Family__c = oppProductItem.Product2.Family;
            }
            update oppProductItem;
        }
    }

    private Boolean isExistsProductCode() {
        Set<String> mdProductCodeSet = new Set<String>();

        for (Product_Family_by_Code_Mapping__mdt mdRecord : [SELECT Product_Code__c FROM Product_Family_by_Code_Mapping__mdt]) {
            mdProductCodeSet.add(mdRecord.Product_Code__c);
        }

        for (Product2 product : (List<Product2>) Trigger.new) {
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