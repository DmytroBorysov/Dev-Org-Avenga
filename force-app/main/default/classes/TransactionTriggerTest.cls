@isTest
public class TransactionTriggerTest {
    @isTest
    public static void testAfterUpdate_ToCancelled() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer PRODUCT_QUANTITY = 1;

        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', 1);
        TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        
        System.assertEquals(INITIAL_AMOUNT-PRODUCT_QUANTITY, products[0].Available_Amount__c, 'TransactionTrigger: Wrong initial amount');
        
        transactions[0].Status__c = 'Cancelled';
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(transactions);
        Test.stopTest();
        
        for(Database.SaveResult result: results) {
        	System.assert(result.isSuccess(), 'TransactionTrigger: Unexpected error');
        }
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'TransactionTrigger: Wrong amount');
    }
    
    @isTest
    public static void testAfterUpdate_FromCancelled() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer PRODUCT_QUANTITY = 1;

        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Cancelled', 'Visa', 1);
        TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'TransactionTrigger: Wrong initial amount');
        
        transactions[0].Status__c = 'Active';
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(transactions);
        Test.stopTest();
        
        for(Database.SaveResult result: results) {
        	System.assert(result.isSuccess(), 'TransactionTrigger: Unexpected error');
        }
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT-PRODUCT_QUANTITY, products[0].Available_Amount__c, 'TransactionTrigger: Wrong amount');
    }
    
    @isTest
    public static void testAfterUpdate_BetweenOtherStatuses() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer PRODUCT_QUANTITY = 1;

        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Closed', 'Visa', 1);
        TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        
        System.assertEquals(INITIAL_AMOUNT-PRODUCT_QUANTITY, products[0].Available_Amount__c, 'TransactionTrigger: Wrong initial amount');
        
        transactions[0].Status__c = 'Active';
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(transactions);
        Test.stopTest();
        
        for(Database.SaveResult result: results) {
        	System.assert(result.isSuccess(), 'TransactionTrigger: Unexpected error');
        }
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT-PRODUCT_QUANTITY, products[0].Available_Amount__c, 'TransactionTrigger: Wrong amount');
    }
    
    @isTest
    public static void testAfterUpdate_Excess() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer PRODUCT_QUANTITY = 101;

        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Cancelled', 'Visa', 1);
        TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'TransactionTrigger: Wrong initial amount');
        
        transactions[0].Status__c = 'Active';
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(transactions, false);
        Test.stopTest();
        
  		List<Database.Error> errors = new List<Database.Error>();
        for(Database.SaveResult result: results) {
        	if(!result.isSuccess())
            errors = result.getErrors();
        }
        System.assert(errors.size()>0, 'TransactionTrigger: Error expected');
        System.assertEquals('Insufficient amount available!', errors[0].getMessage(), 'TransactionTrigger: Wrong error');
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'TransactionTrigger: Wrong amount');
    }
    
}