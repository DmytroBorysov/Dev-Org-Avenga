({
  getTransactions: function (component) {
    let action = component.get("c.getMostProfitableTransactions");
    action.setCallback(this, function (response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        let transactions = response.getReturnValue();
        component.set("v.transactions", transactions);
      } else if (state === "ERROR") {
        let errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message)
            console.log(`Error message: ${errors[0].message}`);
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  setColumns: function (component) {
    component.set("v.columns", [
      { label: "Transaction Number", fieldName: "Name", type: "text" },
      { label: "Created Date", fieldName: "CreatedDate", type: "date" },
      { label: "Status", fieldName: "Status__c", type: "text" },
      { label: "Payment Type", fieldName: "Payment_Type__c", type: "text" },
      { label: "Amount", fieldName: "Total_Amount__c", type: "currency" }
    ]);
  }
});