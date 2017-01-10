/**
 * Description: This is a batch class that updates contact's lifecycle stage to 
 * "In Open Opportunity" when they are added to open opportunity. The batch should shedule to
 * run daily
 *
 *      Author          Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit      01/09/2017                   1.0      Initial Draft
 * Liquid Planner: /space/118974/projects/show/32737294
 * Copyright © Peruto Solutions Inc.
 **/
global class UpdateContactLifecycleStageBatch implements Database.Batchable<sObject>,
                                                                                Schedulable {
    public static final String STAGE_INOPENOPTY = 'In Open Opportunity';

    global Database.Querylocator start(Database.BatchableContext BC) {
        Integer maxRows = Test.isRunningTest() ? 10 : 50000000;
        return Database.getQueryLocator([SELECT ContactId,
                                                OpportunityId,
                                                Opportunity.IsClosed,
                                                CreatedDate
                                            FROM OpportunityContactRole
                                            WHERE (CreatedDate = YESTERDAY
                                            OR CreatedDate = TODAY)
                                            AND Contact.p2s_base1__LifecycleStage__c <> 
                                                :STAGE_INOPENOPTY
                                            LIMIT : maxRows]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Map<String, OpportunityContactRole> conOppIdObjMap = new Map<String, OpportunityContactRole> ();
        Set<String> conIdSet = new Set<String> (); // String contactIds which added on Open Oppty
        for (OpportunityContactRole conOppRole : (List<OpportunityContactRole>) scope) {
            conOppIdObjMap.put (conOppRole.ContactId, conOppRole);
            if (!conOppRole.Opportunity.IsClosed)
                conIdSet.add (conOppRole.ContactId);
        } // End for

        // Update contact's lifecycle stage to "In Open Opportunity"
        List<Contact> conListToUpdate = new List<Contact> ();
        for (Contact conInstance : [SELECT Id, p2s_base1__LifecycleStage__c
                                        FROM Contact
                                        WHERE Id IN: conIdSet]) {
            conInstance.p2s_base1__LifecycleStage__c = STAGE_INOPENOPTY;
            conListToUpdate.add (conInstance);
        } // End for
        if (conListToUpdate.size ()> 0)
            Database.update(conListToUpdate, false);
    }

    global void execute(SchedulableContext SC) {
        UpdateContactLifecycleStageBatch updateConLifecycleStage = new UpdateContactLifecycleStageBatch();
        Id batchprocessid = Database.executeBatch(updateConLifecycleStage, 200);
    }

    global void finish(Database.BatchableContext BC) {
    } 
}