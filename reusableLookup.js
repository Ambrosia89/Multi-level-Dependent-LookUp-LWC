/**
 * @description: A controller class for the reusableLookup LWC.
 * This script calls an Apex controller imparatively to fetch records. It uses the data set in the methodInput() getter method.
 * @author: Amborse Akpoyomare
 * @date: 09/05/2024
 */

import { LightningElement, api } from "lwc";
import fetchRecords from "@salesforce/apex/ReusableLookupController.fetchRecords";
/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 500;

export default class ReusableLookup extends LightningElement {
  @api helpText = "Start your search using some text input";
  @api label = "Parent Account";
  @api isRequired;
  @api selectedIconName = "standard:account";
  @api objectLabel = "Account";

  recordsList = [];
  selectedRecordName;

  @api objectApiName = "Account";
  @api fieldApiName = "Name";
  @api otherFieldApiName = "Industry";
  @api searchString = "";
  @api selectedRecordId = "";
  @api parentRecordId;
  @api parentFieldApiName;
  @api includeClosedOpportunities = false;

  preventClosingOfSearchPanel = false;

  //Getter method to set the text string for the search
  get placeholder() {
    if (this.objectApiName.toUpperCase() === "OPPORTUNITY") {
      return "Search Opportunities...";
    }

    return (
      "Search " +
      this.objectApiName.charAt(0).toUpperCase() +
      this.objectApiName.slice(1) +
      "s..."
    );
  }

  // Getter method used to build object to pass as parameter to the Apex method
  get methodInput() {
    return {
      objectApiName: this.objectApiName.toLowerCase(),
      fieldApiName: this.fieldApiName,
      otherFieldApiName: this.otherFieldApiName,
      searchString: this.searchString,
      selectedRecordId: this.selectedRecordId,
      parentRecordId: this.parentRecordId,
      parentFieldApiName: this.parentFieldApiName,
      includeClosedOpportunities: this.includeClosedOpportunities
    };
  }

  get showRecentRecords() {
    if (!this.recordsList) {
      return false;
    }
    return this.recordsList.length > 0;
  }

  //getting the default selected record
  connectedCallback() {
    if (this.selectedRecordId) {
      this.fetchSobjectRecords(true);
    }

    console.log("Is this required " + this.isRequired);
    console.log("Type of required " + typeof this.isRequired);
    console.log("Convert string to boolean"+`${this.isRequired === "true"}`);
  }

  //call the apex method
  fetchSobjectRecords(loadEvent) {
    fetchRecords({
      inputWrapper: this.methodInput
    })
      .then((result) => {
        if (loadEvent && result) {
          this.selectedRecordName = result[0].mainField;
        } else if (result) {
          this.recordsList = JSON.parse(JSON.stringify(result));
        } else {
          this.recordsList = [];
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  get isValueSelected() {
    return this.selectedRecordId;
  }

  //handler for calling apex method when the user changes the search string the the search panel
  handleChange(event) {
    this.searchString = event.target.value;
    this.handleSearchDebounce();
    // this.fetchSobjectRecords(false);
  }
  //handler for debouncing typing events in the search panel by the user. This will prevent multiple APEX calls in quick succession
  handleSearchDebounce() {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout);
    }

    this.debounceTimeout = setTimeout(() => {
      this.fetchSobjectRecords(false);
    }, DELAY);
  }

  //handler for clicking outside the selection panel
  handleBlur() {
    this.recordsList = [];
    this.preventClosingOfSearchPanel = false;
  }

  //handle the click inside the search panel to prevent it getting closed
  handleDivClick() {
    this.preventClosingOfSearchPanel = true;
  }

  //handler for deselection of the selected item
  handleCommit() {
    this.selectedRecordId = "";
    this.selectedRecordName = "";
  }

  //handler for selection of records from lookup result list
  handleSelect(event) {
    let selectedRecord = {
      mainField: event.currentTarget.dataset.mainfield,
      subField: event.currentTarget.dataset.subfield,
      id: event.currentTarget.dataset.id
    };
    this.selectedRecordId = selectedRecord.id;
    this.selectedRecordName = selectedRecord.mainField;
    this.recordsList = [];
    // Creates the event
    const selectedEvent = new CustomEvent("valueselected", {
      detail: selectedRecord
    });
    //dispatching the custom event
    this.dispatchEvent(selectedEvent);
  }

  //to close the search panel when clicked outside of search input
  handleInputBlur(event) {
    // Debouncing this method: Do not actually invoke the Apex call as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    window.clearTimeout(this.delayTimeout);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.delayTimeout = setTimeout(() => {
      if (!this.preventClosingOfSearchPanel) {
        this.recordsList = [];
      }
      this.preventClosingOfSearchPanel = false;
    }, DELAY);
  }
}