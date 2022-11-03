@isTest
public class MostExpensiveProductsRESTTest {
  @IsTest
  public static void getProductsTest() {
    TestDataFactory.createProducts(10, 1, 1);
    TestDataFactory.createProducts(20, 1, 1);
    TestDataFactory.createProducts(30, 1, 1);
    TestDataFactory.createProducts(40, 1, 1);
    TestDataFactory.createProducts(50, 1, 1);
    TestDataFactory.createProducts(60, 1, 2);

    Test.startTest();
    List<Product__c> products = MostExpensiveProductsREST.getProducts();
    Test.stopTest();

    System.assertEquals(
      5,
      products.size(),
      'MostExpensiveProductsRESTTest: Incorrect total number of products'
    );
    System.assertEquals(
      60,
      products[0].Price__c,
      'MostExpensiveProductsRESTTest: Incorrect quantity of first product'
    );
    System.assertEquals(
      60,
      products[1].Price__c,
      'MostExpensiveProductsRESTTest: Incorrect quantity of second product'
    );
    System.assertEquals(
      50,
      products[2].Price__c,
      'MostExpensiveProductsRESTTest: Incorrect quantity of third product'
    );
    System.assertEquals(
      40,
      products[3].Price__c,
      'MostExpensiveProductsRESTTest: Incorrect quantity of fourth product'
    );
    System.assertEquals(
      30,
      products[4].Price__c,
      'MostExpensiveProductsRESTTest: Incorrect quantity of fifth product'
    );
  }
}
