({
  doInit: function (component, event, helper) {
    helper.setColumns(component);
    helper.getTransactions(component);
  }
});