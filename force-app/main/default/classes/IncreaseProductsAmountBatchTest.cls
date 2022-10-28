@IsTest
public class IncreaseProductsAmountBatchTest {
  @TestSetup
  static void setup() {
    List<Transaction__c> transactions = TestDataFactory.createTransactions(
      'Active',
      'Visa',
      5
    );
    List<Product__c> products = TestDataFactory.createProducts(1, 15000, 200);
    TestDataFactory.createLineItems(transactions, products, 3000, true);
  }

  @IsTest
  static void test() {
    Test.startTest();
    IncreaseProductsAmountBatch increaseProductsAmount = new IncreaseProductsAmountBatch();
    Database.executeBatch(increaseProductsAmount);
    Test.stopTest();

    for (Product__c product : [SELECT Available_Amount__c FROM Product__c]) {
      System.assertEquals(
        100,
        product.Available_Amount__c,
        'Unexpected available amount of product'
      );
    }
  }
}
