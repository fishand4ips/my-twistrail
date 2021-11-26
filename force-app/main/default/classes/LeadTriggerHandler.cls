public class LeadTriggerHandler extends TriggerHandler {
    private static final String DEFAULT_SETTINGS = 'Default_Lead_Score_Settings';
    private List<Lead> newList;
    private Map<Id, Lead> oldMap;

    public LeadTriggerHandler(List<Lead> newList, Map<Id, Lead> oldMap) {
        this.newList = newList;
        this.oldMap = oldMap;
    }

    public override void beforeUpdate() {
        for (Lead leadItem : newList) {
            computeLeadScore(leadItem, getDefaultLeadScoringMetadata(DEFAULT_SETTINGS));
        }
    }

    public override void afterInsert() {
        for (Lead leadItem : newList) {
            computeLeadScore(leadItem, getDefaultLeadScoringMetadata(DEFAULT_SETTINGS));
        }
    }
    
    public enum LeadScoringAttributes {
        EMAIL,
        PHONE,
        TITLE,
        NUMBER_OF_STUDENTS,
        NUMBER_OF_SETS_REQUIRED,
        LEAD_SCORE
    }

    private void computeLeadScore(Lead currentLead, Lead_Scoring_Settings__mdt instanceMd) {
        Map<String, Object> createMetadata = new Map<String, Object>();
        currentLead.Lead_Score__c = 0;
        final String BLANK_VALUE = 'blank';
        //Lead_Scoring_Settings__mdt instanceMd = (Trigger.isAfter && Trigger.isInsert) ? getDefaultLeadScoringMetadata() : getLeadScoringMetadata(currentLead.Id);

        if (String.isBlank(currentLead.Phone)) {
            currentLead.Lead_Score__c += instanceMd.Blank_Value__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.PHONE), BLANK_VALUE);
        } else {
            currentLead.Lead_Score__c += instanceMd.Phone_Value__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.PHONE), '+' + instanceMd.Phone_Value__c);
        }

        if (String.isBlank(currentLead.Email)) {
            currentLead.Lead_Score__c += instanceMd.Blank_Value__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.EMAIL), BLANK_VALUE);
        } else {
            currentLead.Lead_Score__c += instanceMd.Email_Value__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.EMAIL), '+' + instanceMd.Email_Value__c);
        }

        if (String.isBlank(currentLead.Title)) {
            currentLead.Lead_Score__c += instanceMd.Blank_Value__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.TITLE), BLANK_VALUE);
        } else {
            currentLead.Lead_Score__c += instanceMd.Title_Value__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.TITLE), '+' + instanceMd.Title_Value__c);
        }

        if (currentLead.Number_of_Students__c >= instanceMd.Students_Limit_Bottom__c && currentLead.Number_of_Students__c <= instanceMd.Students_Limit_Medium__c) {
            currentLead.Lead_Score__c += instanceMd.Students_Value_1__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.NUMBER_OF_STUDENTS), 'More or equal ' + instanceMd.Students_Limit_Bottom__c + ' and less or equal ' + instanceMd.Students_Limit_Medium__c);
        } else if (currentLead.Number_of_Students__c >= instanceMd.Students_Limit_Top__c) {
            currentLead.Lead_Score__c += instanceMd.Students_Value_2__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.NUMBER_OF_STUDENTS), 'More or equal ' + instanceMd.Students_Limit_Top__c);
        } else {
            currentLead.Lead_Score__c += instanceMd.Blank_Value__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.NUMBER_OF_STUDENTS), BLANK_VALUE);
        } 
            
        if (currentLead.Number_of_Sets_Required__c >= instanceMd.Sets_Limit_Bottom__c && currentLead.Number_of_Sets_Required__c <= instanceMd.Sets_Limit_Medium__c) {
            currentLead.Lead_Score__c += instanceMd.Sets_Value_1__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.NUMBER_OF_SETS_REQUIRED), 'More or equal ' + instanceMd.Sets_Limit_Bottom__c + ' and less or equal ' + instanceMd.Sets_Limit_Medium__c);
        } else if (currentLead.Number_of_Sets_Required__c >= instanceMd.Sets_Limit_Top__c) {
            currentLead.Lead_Score__c += instanceMd.Sets_Value_2__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.NUMBER_OF_SETS_REQUIRED), 'More or equal ' + instanceMd.Sets_Limit_Top__c);
        } else {
            currentLead.Lead_Score__c += instanceMd.Blank_Value__c;
            createMetadata.put(setAttributes(LeadScoringAttributes.NUMBER_OF_SETS_REQUIRED), BLANK_VALUE);
        }    
        
        createMetadata.put(setAttributes(LeadScoringAttributes.LEAD_SCORE), currentLead.Lead_Score__c);
        putLeadScoringMetadata(currentLead.Id, JSON.serialize(createMetadata));
    }

    @future
    private static void putLeadScoringMetadata(ID recordId, String serializedMd) {
        Map<String, String> createMetadata = (Map<String, String>)JSON.deserialize(serializedMd, Map<String, String>.class);
        String label = getLabel(recordId);
        String prefixName = 'Lead_Scoring_Settings'; 
        String fullName = prefixName + '.' + label;
        CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, createMetadata); 
    }

    private Lead_Scoring_Settings__mdt getLeadScoringMetadata(ID recordId) {
        return Lead_Scoring_Settings__mdt.getInstance(getLabel(recordId));
    }

    private Lead_Scoring_Settings__mdt getDefaultLeadScoringMetadata(String developerName) {
        return Lead_Scoring_Settings__mdt.getInstance('Default_Lead_Score_Settings');
    }

    private static String getLabel(ID recordId) {
        Lead current = [
            SELECT Name
            FROM Lead 
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
        ];
        return current.Name.replace(' ', '_');
    }

    private String setAttributes(LeadScoringAttributes attributes) {
        if (attributes == LeadScoringAttributes.PHONE) {
            return 'Phone__c'; 
        } else if (attributes == LeadScoringAttributes.EMAIL){
            return 'Email__c';
        } else if (attributes == LeadScoringAttributes.TITLE){
            return 'Title__c';
        } else if (attributes == LeadScoringAttributes.NUMBER_OF_STUDENTS){
            return 'Number_of_Students__c';
        } else if (attributes == LeadScoringAttributes.NUMBER_OF_SETS_REQUIRED){
            return 'Number_of_Sets_Required__c';
        } else if (attributes == LeadScoringAttributes.LEAD_SCORE){
            return 'Lead_Score__c';
        } else {
            throw new IllegalArgumentException('Not found attributes');
        }
    }
}