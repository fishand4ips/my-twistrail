public with sharing class LeadTriggerHelper {

    @TestVisible public enum LeadScoringAttributes {
        Phone_Exists,
        Email_Exists,
        Title_Exists,
        Students_More_Than,
        Students_Less_Than,
        Sets_More_Than,
        Sets_Less_Than,
        Students_Check_Value,
        Sets_Check_Value
    }
    
    public static void calculatingLeadScore(List<Lead> leads){
        Map<String, Lead_Scoring_Settings__mdt> scoreSettings = Lead_Scoring_Settings__mdt.getAll();
        
        for(Lead lead : leads){
            Boolean isStudentsMore = lead.Number_of_Students__c >= scoreSettings.get(LeadScoringAttributes.Students_Check_Value.name()).Score__c;
            Boolean isSetsMore = lead.Number_of_Sets__c >= scoreSettings.get(LeadScoringAttributes.Sets_Check_Value.name()).Score__c;
            Decimal phoneScore = (lead.Phone != null) 
                ? scoreSettings.get(LeadScoringAttributes.Phone_Exists.name()).Score__c
                : 0;
            Decimal emailScore = (lead.Email != null)
                ? scoreSettings.get(LeadScoringAttributes.Email_Exists.name()).Score__c
                : 0;
            Decimal titleScore = (lead.Title != null)
                ? scoreSettings.get(LeadScoringAttributes.Title_Exists.name()).Score__c
                : 0;
            Decimal studentsScore = (lead.Number_of_Students__c != null && lead.Number_of_Students__c != 0)
                ? isStudentsMore 
                    ? scoreSettings.get(LeadScoringAttributes.Students_More_Than.name()).Score__c 
                    : scoreSettings.get(LeadScoringAttributes.Students_Less_Than.name()).Score__c
                : 0;
            Decimal setsScore = (lead.Number_of_Sets__c != null && lead.Number_of_Sets__c != 0)
                ? isSetsMore 
                    ? scoreSettings.get(LeadScoringAttributes.Sets_More_Than.name()).Score__c 
                    : scoreSettings.get(LeadScoringAttributes.Sets_Less_Than.name()).Score__c
                : 0;
            lead.Lead_Score__c = phoneScore + emailScore + titleScore + studentsScore + setsScore;
        }
    }
}
