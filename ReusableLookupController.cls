/**
 * @description: A controller class for the reusableLookup LWC.
 * This class is called imperatively. It builds a dynamic SOQL query from parameters passed in to the LWC using its properties.
 * It returns the queried records and their corresponding fields back to the JS file of the LWC. 
 * @author: Amborse Akpoyomare
 * @date: 09/05/2024
 */
/*----------------------------------------------------------------------
 * ===================================================================================
 * Version              Date                    Author                  Modification
 * ===================================================================================
 * 1.0                  09/05/2024, 07:18       Ambrose Akpoyomare      Created

*/

public with sharing class ReusableLookupController {

/**
* @description    Method for querying relevant records from the database
* @param inputWrapper:  An input object from the JS file of the LWC cast to the custom SearchWrapper class
* @return returnWrapperList:   List of records returned from the SOQL query 
*/
    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {

        List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
// Check if inputWrapper is null and return an empty list
   //     if (isSearchWrapperEmpty(inputWrapper)) {
   //         return returnWrapperList;
   //     }
        try {
            //Build a dynamic query if the inputWrapper object is not empty
            if(inputWrapper != null){
                String fieldsToQuery = 'SELECT Id, ';
                if(string.isNotBlank(inputWrapper.fieldApiName)){
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                }
                if(string.isNotBlank(inputWrapper.otherFieldApiName)){
                    fieldsToQuery = fieldsToQuery + ', ' + inputWrapper.otherFieldApiName;
                }
                String query = fieldsToQuery + ' FROM '+ inputWrapper.objectApiName;
                String filterCriteria = inputWrapper.fieldApiName + ' LIKE ' + '\'' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\' LIMIT 50';
                //Filter the SOQL query if a specified primary record has been selected
                if(String.isNotBlank(inputWrapper.selectedRecordId)) {
                    query += ' WHERE Id = \''+ inputWrapper.selectedRecordId + '\'';
                }else if(String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)){
                    query += ' WHERE '+ inputWrapper.parentFieldApiName+ ' = \''+ inputWrapper.parentRecordId + '\'';
                //Handle closed opportunity records based on @includeClosedOpportunities boolean.     
                    If(inputWrapper.objectApiName.equalsIgnoreCase('Opportunity') && !inputWrapper.includeClosedOpportunities){

                     query += ' AND ' + 'IsClosed = ' + inputWrapper.includeClosedOpportunities;
                    }
                    query += ' AND ' + filterCriteria;

                } 
                else {
                    query += ' WHERE '+ filterCriteria;

                }

                 //Perform a SOQL query for the records and iterate over the results. Store the results in the @returnWrapperList variable 
                for(SObject s : Database.query(query)) {
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.mainField = (String)s.get(inputWrapper.fieldApiName);
                    wrap.subField = String.isNotBlank(inputWrapper.otherFieldApiName)? (String)s.get(inputWrapper.otherFieldApiName) : null;
                    wrap.id = (String)s.get('id');
                    returnWrapperList.add(wrap);
                }

            }
        // Handle exception
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }

        return returnWrapperList;
    }

// Utility method to check if all properties of the inputWrapper are null or blank
/*     private static Boolean isSearchWrapperEmpty(SearchWrapper inputWrapper) {
        return String.isBlank(inputWrapper.objectApiName) &&
               String.isBlank(inputWrapper.fieldApiName) &&
               String.isBlank(inputWrapper.otherFieldApiName) &&
               String.isBlank(inputWrapper.searchString) &&
               String.isBlank(inputWrapper.selectedRecordId) &&
               String.isBlank(inputWrapper.parentRecordId) &&
               String.isBlank(inputWrapper.parentFieldApiName) &&
               inputWrapper.includeClosedOpportunities == null;
    } */

/**
* @description:  Wrapper class for return results
*/
    public class ResultWrapper{
        @AuraEnabled public String mainField{get;set;}
        @AuraEnabled public String subField{get;set;}
        @AuraEnabled public String id{get;set;}
    }
/**
* @description:  Wrapper class for input object from LWC
*/
    public class SearchWrapper {
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String otherFieldApiName{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}
        @AuraEnabled public String parentRecordId{get;set;}
        @AuraEnabled public String parentFieldApiName{get;set;}
        @AuraEnabled public Boolean includeClosedOpportunities{get;set;}
    }
}