public class CreateUpdateMetadataProduct2 {

    @future
    public static void buildMetadata(ID recordId) {
        Product2 current = [
            SELECT Name, Family, ProductCode
            FROM Product2 
            WHERE Id = :recordId
        ];
        
        String prefixName ='Product_Family_by_Code_Mapping'; 
        String label = current.Name;
        String labelModify = label.replace(' ', '_');
        String fullName = prefixName + '.' + labelModify;

        Map<String, Object> createMetadata = new Map<String, Object>();
        createMetadata.put('Product_Code__c', current.ProductCode);
        createMetadata.put('Product_Family__c', current.Family);

        try {
            CreateUpdateMetadataUtils.createUpdateMetadata(fullName, labelModify, createMetadata);
        } catch(DmlException ex) {
            System.debug(ex);
        }
    }
}