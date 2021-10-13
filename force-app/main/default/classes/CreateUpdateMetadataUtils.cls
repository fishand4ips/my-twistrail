public class CreateUpdateMetadataUtils implements Metadata.DeployCallback {
  
  public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
      if (result.status == Metadata.DeployStatus.Succeeded) {
        System.debug(' success : '+ result);            
      } else {
        System.debug(' fail : '+ result);
      }
    }

    public static void createUpdateMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap){
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = fullName;
        customMetadata.label = label;
        Id jobId;
        
        for (String key : fieldWithValuesMap.keySet()){
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key); 
            customMetadata.values.add(customField);
        }
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        CreateUpdateMetadataUtils callback = new CreateUpdateMetadataUtils();
        if (!Test.isRunningTest()) {
            jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
        System.debug('Container>> ' + mdContainer);
        System.debug('Id>> ' + jobId);
    }
}