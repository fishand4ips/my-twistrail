trigger Lead_SourceZip on i360__Lead_Source__c (before insert, before update) {
    if (i360.TriggerBypass.AllTriggers) {
        return;
    }
    
    ZipCodeTriggerUtilities.updateLeadSourcesWithZipCodeMarketSegment(Trigger.New);
}