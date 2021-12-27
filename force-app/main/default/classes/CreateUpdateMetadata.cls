public class CreateUpdateMetadata {
    
    @future
    public static void buildMetadata(ID recordId) {
        Lead current = [SELECT Email, Number_of_Sets_Required__c, Number_of_Students__c, Title, Phone, Lead_Score__c, Name
                        FROM Lead 
                        WHERE Id = :recordId];
        String prefixName ='Lead_Scoring_Settings'; 
        String label = current.Name;
        String labelModify = label.replace(' ', '_');
        String fullName = prefixName + '.' + labelModify;

        Map<String, Object> createMetadata = new Map<String, Object>();
        createMetadata.put('Email__c', current.Email);
        createMetadata.put('Number_of_Sets_Required__c', current.Number_of_Sets_Required__c);
        createMetadata.put('Number_of_Students__c', current.Number_of_Students__c);
        createMetadata.put('Phone__c', current.Phone);
        createMetadata.put('Title__c', current.Title);
        createMetadata.put('Lead_Score__c', current.Lead_Score__c);

        try {
            CreateUpdateMetadataUtils.createUpdateMetadata(fullName, labelModify, createMetadata);
        } catch(DmlException ex) {
            System.debug('Failed sent metadata: ' + ex.getMessage());
        }
    }
}