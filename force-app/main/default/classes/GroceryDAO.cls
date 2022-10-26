public with sharing class GroceryDAO {
  public static Map<Id, Integer> getNumberOfSoldProducts(
    DateTime startDate,
    DateTime endDate
  ) {
    Map<Id, Integer> soldProductsMap = new Map<Id, Integer>();
    for (AggregateResult result : [
      SELECT Product__c productId, SUM(Quantity__c) totalQuantity
      FROM Line_Item__c
      WHERE
        Transaction__r.Status__c = 'Closed'
        AND Transaction__r.CreatedDate > :startDate
        AND Transaction__r.CreatedDate < :endDate
      GROUP BY Product__c
    ]) {
      soldProductsMap.put(
        (Id) result.get('productId'),
        (Integer) ((Decimal) result.get('totalQuantity'))
      );
    }
    return soldProductsMap;
  }

  public static Map<Id, Decimal> getTotalAmountOfTransactions(
    Set<Id> transactionIds
  ) {
    Map<Id, Decimal> transactionAmountsMap = new Map<Id, Decimal>();
    for (AggregateResult result : [
      SELECT Transaction__c transactionId, SUM(Amount__c) totalAmount
      FROM Line_Item__c
      WHERE Transaction__c IN :transactionIds
      GROUP BY Transaction__c
    ]) {
      transactionAmountsMap.put(
        (Id) result.get('transactionId'),
        (Decimal) result.get('totalAmount')
      );
    }
    return transactionAmountsMap;
  }

  public static List<Product__c> getTopSellers(
    Integer limitNumber,
    Integer offsetNumber,
    Integer year
  ) {
    List<Id> topSellerIds = new List<Id>();
    for (AggregateResult result : [
      SELECT Product__c productId, SUM(Quantity__c) totalQuantity
      FROM Line_Item__c
      WHERE
        Transaction__r.Status__c = 'Closed'
        AND CALENDAR_YEAR(Transaction__r.CreatedDate) = :year
      GROUP BY Product__c
      ORDER BY SUM(Quantity__c) DESC
      LIMIT :limitNumber
      OFFSET :offsetNumber
    ]) {
      topSellerIds.add((Id) result.get('productId'));
    }
    Map<Id, Product__c> productsMap = new Map<Id, Product__c>(
      [SELECT Name, Code__c, Price__c FROM Product__c WHERE Id IN :topSellerIds]
    );
    List<Product__c> topSellers = new List<Product__c>();
    for (Id curId : topSellerIds) {
      topSellers.add(productsMap.get(curId));
    }
    return topSellers;
  }

  public static List<AggregateResult> getPaymentStatisticsAmount() {
    return [
      SELECT
        Transaction__r.Payment_Type__c paymentType,
        SUM(Quantity__c) totalQuantity
      FROM Line_Item__c
      WHERE Transaction__r.Status__c = 'Closed'
      GROUP BY Transaction__r.Payment_Type__c
    ];
  }

  public static List<Product__c> getProducts(
    Integer limitNumber,
    Integer offsetNumber
  ) {
    return [
      SELECT Name, Code__c, Price__c, Available_Amount__c
      FROM Product__c
      ORDER BY Code__c
      LIMIT :limitNumber
      OFFSET :offsetNumber
    ];
  }

  public static List<Product__c> getProductAvailableInStore(
    Integer limitNumber,
    Integer offsetNumber
  ) {
    return [
      SELECT Name, Code__c, Price__c, Available_Amount__c
      FROM Product__c
      WHERE Available_Amount__c > 0
      ORDER BY Code__c
      LIMIT :limitNumber
      OFFSET :offsetNumber
    ];
  }
}