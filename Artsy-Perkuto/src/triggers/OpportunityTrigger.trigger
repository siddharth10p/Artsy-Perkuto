/**
 * Description: This is a trigger calls handler class to update Recycle Reason field on Contact
 *
 *      Author          Created Date(mm-dd-yyyy)     version   Changelog
 * Siddharth Pandit      01/10/2017                   1.0      Initial Draft
 * Liquid Planner: /space/118974/projects/show/32737294
 * Copyright © Peruto Solutions Inc.
 **/
trigger OpportunityTrigger on Opportunity (before update) {
    // Update contact's recycled reason field
    if (Trigger.isUpdate && Trigger.isBefore)
        PopulateRecycledReasonHandler.updateRecycledStageReason (Trigger.newMap);
}