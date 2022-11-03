@RestResource(urlMapping='/MostExpensiveProducts/*')
global with sharing class MostExpensiveProductsREST {
  @HttpGet
  global static List<Product__c> getProducts() {
    return [
      SELECT Name, Code__c, Price__c, Available_Amount__c
      FROM Product__c
      ORDER BY Price__c DESC
      LIMIT 5
    ];
  }
}
