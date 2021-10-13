@IsTest
public class CreateUpdateMetadataUtilsTest {
    @IsTest
    public static void configSetupTest(){
        String fullName = 'Product_Family_by_Code_Mapping.Arduino';
        String label = 'SCORE_SETTINGS';
        String values = '{'+ ' "Email__c": "alekomegunov@gmail.com" ' +'}';
        Map<String, Object> deployedValue = (Map<String, Object>)JSON.deserializeUntyped(values);
        Test.startTest();
        CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, deployedValue);
        Test.stopTest();
    }

    @IsTest
    public static void CreateUpdateMetadataUtilsTest(){
        CreateUpdateMetadataUtils metadata = new CreateUpdateMetadataUtils();
        Test.startTest();
        metadata.handleResult(new Metadata.DeployResult(), new Metadata.DeployCallbackContext());
        Test.stopTest();
    }
    
}