public with sharing class ProductController {

    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getProducts() {
        List<ProductWrapper> wProds = new List<ProductWrapper>();
        try {
            List<Product2> products = [
                SELECT Id, Name, ProductCode, Description, StockKeepingUnit, (
                    SELECT Id, UnitPrice, Pricebook2.IsStandard, Pricebook2.Name, Pricebook2.IsActive
                    FROM PricebookEntries
                )
                FROM Product2
                WITH SECURITY_ENFORCED
                LIMIT 20
            ];
            System.debug('products: ' + products);
            for (Product2 product : products) {
                if (product != null || product.PricebookEntries != null) {
                    for (PricebookEntry entry : product.PricebookEntries) {
                        wProds.add(new ProductWrapper(product, entry));
                    }
                }
            }
            System.debug('wrap: ' + wProds);
        } catch (Exception e) {
            throw new AuraHandledException('Failed fecth Products: ' + e.getMessage());
        }

        if (wProds.isEmpty()) {
            return new List<ProductWrapper>();
        }
        return wProds;
    }

    @AuraEnabled
    public static List<PricebookEntry> getPricebookEntry() {
        List<PricebookEntry> pricebook;
        try {
            pricebook = new List<PricebookEntry>([
                SELECT Id, Product2Id, UnitPrice, Product2.Description, Pricebook2.IsStandard, Pricebook2.Name
                FROM PricebookEntry
                WITH SECURITY_ENFORCED
            ]);
        } catch (Exception e) {
            throw new AuraHandledException('Failed fetch Price Book Entry: ' + e.getMessage());
        }
        return pricebook;
    }

    class ProductWrapper {

        @AuraEnabled
        public String productId;

        @AuraEnabled
        public String url;

        @AuraEnabled
        public String name;

        @AuraEnabled
        public String description;

        @AuraEnabled
        public String productCode;

        @AuraEnabled
        public String stockKeepingUnit;

        @AuraEnabled
        public String entryId;

        @AuraEnabled
        public Decimal unitPrice;

        @AuraEnabled
        public String pricebookName;

        @AuraEnabled
        public Boolean isStandard;

        @AuraEnabled
        public Boolean isActive;

        @AuraEnabled
        public String pricebookId;

        ProductWrapper(Product2 product, PricebookEntry entry) {
            this.productId = product.Id;
            this.url = formUrl(product.Id);
            this.name = product.Name;
            this.description = product.Description;
            this.productCode = product.ProductCode;
            this.stockKeepingUnit = product.StockKeepingUnit;
            this.entryId = fillIfNotBlank(entry.Id);
            this.unitPrice = entry.UnitPrice;
            this.pricebookName = fillIfNotBlank(entry.Pricebook2.Name);
            this.isStandard = entry.Pricebook2.IsStandard;
            this.isActive = entry.Pricebook2.IsActive;
            this.pricebookId = entry.Pricebook2.Id;
        }

        private String formUrl(Id productId) {
            return '/' + productId;
        }

        private String fillIfNotBlank(String value) {
            return String.isBlank(value) ? '' : value;
        }
    }
}