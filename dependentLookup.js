import { LightningElement, api } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
export default class DependentLookup extends LightningElement {
  @api parentAccountSelectedRecord;
  selectedChildRecord;
  @api mainFieldApiName;
  @api otherFieldApiName;
  @api objectLabel;
  @api selectedRecordId;
  @api includeClosedOpportunities;
  @api isRequired;

  get displayTextName() {
    return (
      "Select " +
      this.objectLabel.charAt(0).toUpperCase() +
      this.objectLabel.slice(1)
    );
  }

  get iconName() {
    return "standard:" + this.objectLabel.toLowerCase();
  }

  handleValueSelectedOnAccount(event) {
    this.parentAccountSelectedRecord = event.detail;
  }

  handleValueSelectedOnChild(event) {
    this.selectedChildRecord = event.detail;
    this.selectedRecordId = event.detail.id;
    //    this.parentContactSelectedRecordId = event.detail.id;
    this.dispatchEvent(
      new FlowAttributeChangeEvent("selectedRecordId", this.selectedRecordId)
    );
  }
}