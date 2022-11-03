public class IncreaseProductsAmountBatch implements Database.Batchable<sObject>, Schedulable {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Set<Id> productIds = new Set<Id>();
    for (AggregateResult result : [
      SELECT Product__c
      FROM Line_Item__c
      WHERE
        Transaction__r.Status__c != 'Cancelled'
        AND Transaction__r.CreatedDate = LAST_N_DAYS:30
      GROUP BY Product__c
      HAVING SUM(Quantity__c) > 10000
    ]) {
      productIds.add((Id) result.get('Product__c'));
    }
	system.debug('productIds = '+productIds);
    return Database.getQueryLocator(
      'SELECT Available_Amount__c FROM Product__c WHERE Id IN :productIds'
    );
  }

  public void execute(
    Database.BatchableContext bc,
    List<Product__c> productsToUpdate
  ) {
    for (Product__c product : productsToUpdate) {
      product.Available_Amount__c += 100;
    }
      System.debug('productsToUpdate = '+ productsToUpdate);
    update productsToUpdate;
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('Processing completed');
  }

  public void execute(System.SchedulableContext sc) {
    IncreaseProductsAmountBatch increaseProductsAmount = new IncreaseProductsAmountBatch();
    Database.executeBatch(increaseProductsAmount);
  }
}