import { LightningElement, wire } from "lwc";
import getLineItems from "@salesforce/apex/LineItemsFromExternalAppController.getLineItems";

export default class GetLineItemsFromExternalApp extends LightningElement {
  columns = [
    { label: "Transaction No.", fieldName: "transactionNumber", type: "text" },
    { label: "Product code", fieldName: "productCode", type: "text" },
    { label: "Product name", fieldName: "productName", type: "text" },
    { label: "Quantity", fieldName: "quantity", type: "number" },
    { label: "Amount", fieldName: "amount", type: "currency" }
  ];
  lineItems;
  errorMessage;
  @wire(getLineItems)
  setLineItems({ error, data }) {
    if (error) {
      // UI API read operations return an array of objects
      if (Array.isArray(error.body)) {
        this.errorMessage = error.body.map((e) => e.message).join(", ");
      }
      // UI API write operations, Apex read and write operations
      // and network errors return a single object
      else if (typeof error.body.message === "string") {
        this.errorMessage = error.body.message;
      }
    } else if (data) {
      this.lineItems = data;
    }
  }
}