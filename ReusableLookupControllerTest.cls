/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ReusableLookupControllerTest {

@testSetup
    static void setup() {

        User u = [select Id from User where id =:UserInfo.getUserId()];
        ruk_TestTeams.GenerateTestTeams(u);

        // Create test Accounts
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{acc1, acc2};

        // Create test Opportunities
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity 1',StageName = 'Qualification', CloseDate = Date.today(), AccountId = acc1.Id, LeadType__c = 'Apprenticeship');
        Opportunity opp2 = new Opportunity(Name = 'Test Opportunity 2', StageName = 'Closed Won', CloseDate = Date.today(), AccountId = acc1.Id, LeadType__c = 'Apprenticeship',ApprovalStatus__c= 'Approved');
        insert new List<Opportunity>{opp1, opp2};
    }

    @isTest
    static void test_fetchRecords_withSelectedRecordId() {
        ReusableLookupController.SearchWrapper searchWrapper = new ReusableLookupController.SearchWrapper();
        searchWrapper.objectApiName = 'Account';
        searchWrapper.fieldApiName = 'Name';
        searchWrapper.searchString = 'Test';
        searchWrapper.selectedRecordId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
 //       List<Account> accts = [SELECT Id FROM Account];

        List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(searchWrapper);
        Test.stopTest();

        System.assertNotEquals(null,results, 'Results should not be null.');
        System.assertEquals(1, results.size(), 'The number of account records created should be the same as the number retrieved.');
    }

    @isTest
    static void test_fetchRecords_withParentRecordId() {
        ReusableLookupController.SearchWrapper searchWrapper = new ReusableLookupController.SearchWrapper();
        searchWrapper.objectApiName = 'Opportunity';
        searchWrapper.fieldApiName = 'Name';
        searchWrapper.otherFieldApiName='StageName';
        searchWrapper.searchString = 'Test';
        searchWrapper.parentFieldApiName = 'AccountId';
        searchWrapper.parentRecordId = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1].Id;
        searchWrapper.includeClosedOpportunities = false;

        Test.startTest();
        List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(searchWrapper);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Results should contain exactly one opportunity record');
    }

    @isTest
    static void test_fetchRecords_withoutFilters() {
        ReusableLookupController.SearchWrapper searchWrapper = new ReusableLookupController.SearchWrapper();
        searchWrapper.objectApiName = 'Account';
        searchWrapper.fieldApiName = 'Name';
        searchWrapper.searchString = 'Test';

        Test.startTest();
        List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(searchWrapper);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(2, results.size(), 'Results should contain exactly two records');
    }

    @isTest
    static void test_fetchRecords_withClosedOpportunities() {
        ReusableLookupController.SearchWrapper searchWrapper = new ReusableLookupController.SearchWrapper();
        searchWrapper.objectApiName = 'Opportunity';
        searchWrapper.fieldApiName = 'Name';
        searchWrapper.searchString = 'Test';
        searchWrapper.includeClosedOpportunities = true;

        Test.startTest();
        List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(searchWrapper);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(2, results.size(), 'Results should contain exactly two records');
    }

    @isTest
    static void test_fetchRecords_withException() {
        AuraHandledException expectedException;
        ReusableLookupController.SearchWrapper searchWrapper = new ReusableLookupController.SearchWrapper();
        searchWrapper.objectApiName = 'NonExistentObject';
        searchWrapper.fieldApiName = 'NonExistentField';
        searchWrapper.searchString = 'Test';

        Test.startTest();
        try {
            ReusableLookupController.fetchRecords(searchWrapper);
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {

            expectedException = e;
            
        }
        Test.stopTest();
        System.assertNotEquals(null, expectedException, 'Exception message should be present');
    }


    
    @isTest
    static void test_fetchRecords_withNullInput() {
        AuraHandledException expectedException;
        ReusableLookupController.SearchWrapper searchWrapper = new ReusableLookupController.SearchWrapper();
        //searchWrapper.objectApiName = 'NonExistentObject';
       // searchWrapper.fieldApiName = 'NonExistentField';
        //searchWrapper.searchString = 'Test';

        Test.startTest();
        try {
            ReusableLookupController.fetchRecords(searchWrapper);
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {

            expectedException = e;
            
        }
        Test.stopTest();
        System.assertNotEquals(null, expectedException, 'Exception message should be present');
    }
}