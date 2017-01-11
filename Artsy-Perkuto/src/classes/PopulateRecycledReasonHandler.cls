/**
 * Description: This is a trigger handler class that will update related contact's recycle
 * reason when opportunity is closed.
 *
 *      Author          Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit      01/10/2017                   1.0      Initial Draft
 * Liquid Planner: /space/118974/projects/show/32737294
 * Copyright © Peruto Solutions Inc.
 **/
public with sharing class PopulateRecycledReasonHandler {
    public static final String STR_LLC_REASON = 'Opportunity Closed';
    public static void updateRecycledStageReason (Map<Id, Opportunity> pOpptyIdObjMap) {
        Map<Id, String> opptyIdReasonMap = new Map<Id, String> ();
        for (Opportunity oppty : pOpptyIdObjMap.values()) {
            if (oppty.IsClosed)
                opptyIdReasonMap.put (oppty.Id, STR_LLC_REASON);
        }

        Map<String, String> conIdOppIdMap = new Map<String, String> ();
        for (OpportunityContactRole opptyConRole : [SELECT Id, ContactId, OpportunityId
                                                    FROM OpportunityContactRole
                                                    WHERE OpportunityId IN 
                                                            :opptyIdReasonMap.keySet ()]) {
            conIdOppIdMap.put (opptyConRole.ContactId, opptyConRole.OpportunityId);
        } // End for

        List<Contact> conListToUpdate = new List<Contact> ();
        for (Contact conInstance : [SELECT Id, Recycled_Reason__c
                                    FROM Contact
                                    WHERE Id IN: conIdOppIdMap.keySet ()]) {
            conInstance.Recycled_Reason__c =
                                    opptyIdReasonMap.get (conIdOppIdMap.get (conInstance.Id));
            conListToUpdate.add (conInstance);
        } // End for

        if (!conListToUpdate.isEmpty ())
            update conListToUpdate;
    } // End method
}