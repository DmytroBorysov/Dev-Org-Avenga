import { LightningElement, api, wire } from "lwc";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";

import LINE_ITEM_ID_FIELD from "@salesforce/schema/Line_Item__c.Id";
import LINE_ITEM_NAME_FIELD from "@salesforce/schema/Line_Item__c.Name";
import LINE_ITEM_PRODUCT_FIELD from "@salesforce/schema/Line_Item__c.Product_Name_With_Code__c";
import LINE_ITEM_QUANTITY_FIELD from "@salesforce/schema/Line_Item__c.Quantity__c";
import LINE_ITEM_AMOUNT_FIELD from "@salesforce/schema/Line_Item__c.Amount__c";

const LINE_ITEM_FIELDS = [
  LINE_ITEM_ID_FIELD,
  LINE_ITEM_NAME_FIELD,
  LINE_ITEM_PRODUCT_FIELD,
  LINE_ITEM_QUANTITY_FIELD,
  LINE_ITEM_AMOUNT_FIELD
];

const LINE_ITEM_COLUMNS = [
  {
    label: "Line Item No.",
    fieldName: LINE_ITEM_NAME_FIELD.fieldApiName,
    type: "text"
  },
  {
    label: "Product",
    fieldName: LINE_ITEM_PRODUCT_FIELD.fieldApiName,
    type: "text"
  },
  {
    label: "Quantity",
    fieldName: LINE_ITEM_QUANTITY_FIELD.fieldApiName,
    type: "number"
  },
  {
    label: "Amount",
    fieldName: LINE_ITEM_AMOUNT_FIELD.fieldApiName,
    type: "currency"
  }
];

export default class RelatedLineItems extends LightningElement {
  @api recordId;
  columns = LINE_ITEM_COLUMNS;
  lineItems;

  @wire(getRelatedListRecords, {
    parentRecordId: "$recordId",
    relatedListId: "Line_Items__r",
    fields: LINE_ITEM_FIELDS.map(
      (field) => `${field.objectApiName}.${field.fieldApiName}`
    )
  })
  getLineItems({ error, data }) {
    if (data) {
      this.lineItems = data.records.map((record) =>
        Object.fromEntries(
          new Map(
            Object.keys(record.fields).map((field) => [
              field,
              record.fields[field].value
            ])
          )
        )
      );
    } else if (error) {
      console.log(JSON.stringify(error));
    }
  }
}
