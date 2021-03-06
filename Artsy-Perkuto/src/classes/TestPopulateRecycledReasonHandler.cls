/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPopulateRecycledReasonHandler {

    static testMethod void coverOpptyTrigger () {
        // Create test data
        Account acc = new Account (Name= 'Test');
        insert acc;
        Contact con = new Contact (LastName = 'Test con', Email= 'sid+test@perkuto.com',
                                    AccountId = acc.Id);
        insert con;
        Opportunity oppty = new Opportunity (Name = 'Test oppty', CloseDate = Date.today(),
                                            AccountId = acc.Id, StageName = 'Prospecting');
        insert oppty;
        OpportunityContactRole opptyConRole = new OpportunityContactRole (ContactId = con.Id,
                                                    OpportunityId = oppty.Id);
        insert opptyConRole;
        oppty.StageName = 'Closed Won';
        update oppty;

        Test.startTest ();
            con = [SELECT Recycled_Reason__c FROM Contact WHERE Id = :con.Id];
            System.assertEquals (PopulateRecycledReasonHandler.STR_LLC_REASON,
                                    con.Recycled_Reason__c);
        Test.stopTest ();
    }
}