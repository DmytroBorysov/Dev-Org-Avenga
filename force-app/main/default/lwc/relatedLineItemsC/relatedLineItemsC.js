import { LightningElement, api, wire } from "lwc";
import getRelatedLineItems from "@salesforce/apex/RelatedLineItemsController.getRelatedLineItems";

export default class RelatedLineItemsC extends LightningElement {
  @api recordId;
  columns = [
    { label: "Line Item No.", fieldName: "Name", type: "text" },
    { label: "Product", fieldName: "Product_Name_With_Code__c", type: "text" },
    { label: "Quantity", fieldName: "Quantity__c", type: "number" },
    { label: "Amount", fieldName: "Amount__c", type: "currency" }
  ];
  @wire(getRelatedLineItems, { transactionId: "$recordId" })
  lineItems;
}