public with sharing class GroceryServices {
  public static List<Transaction__c> filterValidTransactions(
    List<Transaction__c> transactions
  ) {
    List<Transaction__c> resultTransactions = new List<Transaction__c>();
    for (Transaction__c curTransaction : transactions) {
      if (
        curTransaction.Status__c == 'Active' ||
        curTransaction.Status__c == 'Closed'
      ) {
        resultTransactions.add(curTransaction);
      }
    }
    return resultTransactions;
  }

  public static Integer calculateTotalAmount(List<Line_Item__c> lineItems) {
    Integer amount = 0;
    for (Line_Item__c lineItem : lineItems) {
      amount += (Integer) lineItem.Amount__c;
    }
    return amount;
  }

  public static Database.SaveResult createTransaction(String paymentType) {
    return Database.insert(
      new Transaction__c(Payment_Type__c = paymentType, Status__c = 'Active'),
      false
    );
  }

  public static Database.SaveResult createTransaction(
    String paymentType,
    List<LineItemDTO> itemList
  ) {
    Database.SaveResult result = Database.insert(
      new Transaction__c(Payment_Type__c = paymentType, Status__c = 'Active'),
      false
    );
    if (result.isSuccess()) {
      Id transactionId = result.getId();
      List<Line_Item__c> newItems = new List<Line_Item__c>();
      for (LineItemDTO item : itemList) {
        newItems.add(
          new Line_Item__c(
            Transaction__c = transactionId,
            Product__c = item.productId,
            Quantity__c = item.quantity,
            Amount__c = item.amount
          )
        );
      }
      insert newItems;
    }
    return result;
  }

  public static Database.SaveResult createLineItem(
    Id transactionId,
    Id productId,
    Integer amount
  ) {
    return Database.insert(
      new Line_Item__c(
        Transaction__c = transactionId,
        Product__c = productId,
        Amount__c = amount,
        Quantity__c = 1
      ),
      false
    );
  }

  public static void cancelTransaction(Id transactionId) {
    update new Transaction__c(Id = transactionId, Status__c = 'Cancelled');
  }

  public static void deleteLineItem(Id lineItemId) {
    delete new Line_Item__c(Id = lineItemId);
  }

  public class LineItemDTO {
    public Id productId { get; set; }
    public Integer quantity { get; set; }
    public Integer amount { get; set; }
    public LineItemDTO(Id productId, Integer quantity, Integer amount) {
      this.productId = productId;
      this.quantity = quantity;
      this.amount = amount;
    }
  }
}