@isTest
public class LineItemTriggerTest {
	@isTest
    public static void testAfterInsert() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 1;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, false);
        
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(lineItems);
        Test.stopTest();
        
        for(Database.SaveResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT-TRANSACTION_COUNT*PRODUCT_QUANTITY, products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    @isTest
    public static void testAfterInsert_Cancelled() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 1;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Cancelled', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, false);
        
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(lineItems);
        Test.stopTest();
        
        for(Database.SaveResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    @isTest
	public static void testAfterInsert_Excess() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 30;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, false);
        
        Test.startTest();
        List<Database.SaveResult> results = Database.insert(lineItems, false);
        Test.stopTest();
        
        List<Database.Error> errors = new List<Database.Error>();
        for(Database.SaveResult result: results) {
        	if(!result.isSuccess())
            errors = result.getErrors();
        }
        System.assert(errors.size()>0, 'LineItemTrigger: Error expected');
        System.assertEquals('Insufficient amount available!', errors[0].getMessage(), 'LineItemTrigger: Wrong error');
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT-PRODUCT_QUANTITY*(Integer)(INITIAL_AMOUNT/PRODUCT_QUANTITY), products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    
	@isTest
    public static void testAfterDelete() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 1;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT-TRANSACTION_COUNT*PRODUCT_QUANTITY, products[0].Available_Amount__c, 'LineItemTrigger: Wrong initial amount');
        
        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(lineItems);
        Test.stopTest();
        
        for(Database.DeleteResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    @isTest
    public static void testAfterDelete_Cancelled() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 1;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Cancelled', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong initial amount');

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(lineItems);
        Test.stopTest();
        
        for(Database.DeleteResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    
    @isTest
    public static void testAfterUndelete() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 1;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        delete lineItems;
       
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong initial amount');
        
        Test.startTest();
        List<Database.UndeleteResult> results = Database.undelete(lineItems);
        Test.stopTest();
        
        for(Database.UndeleteResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT-TRANSACTION_COUNT*PRODUCT_QUANTITY, products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    
    @isTest
    public static void testAfterUndelete_Cancelled() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 1;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Cancelled', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        delete lineItems;
       
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong initial amount');
        
        Test.startTest();
        List<Database.UndeleteResult> results = Database.undelete(lineItems);
        Test.stopTest();
        
        for(Database.UndeleteResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    
    @isTest
	public static void testAfterUndelete_Excess() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 30;
        List<Product__c> products = TestDataFactory.createProducts(10, TRANSACTION_COUNT*PRODUCT_QUANTITY, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_QUANTITY, true);
        
        delete lineItems;
        products[0].Available_Amount__c = INITIAL_AMOUNT;
        update products;
  
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong initial amount');
        
        Test.startTest();
        List<Database.UndeleteResult> results = Database.undelete(lineItems, false);
        Test.stopTest();
        
        List<Database.Error> errors = new List<Database.Error>();
        for(Database.UndeleteResult result: results) {
        	if(!result.isSuccess())
            errors = result.getErrors();
        }
        System.assert(errors.size()>0, 'LineItemTrigger: Error expected');
        System.assertEquals('Insufficient amount available!', errors[0].getMessage(), 'LineItemTrigger: Wrong error');
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT-PRODUCT_QUANTITY*(Integer)(INITIAL_AMOUNT/PRODUCT_QUANTITY), products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }

    @isTest
    public static void testAfterUpdate_ChangeQuantity() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_INIT_QUANTITY = 1;
        final Integer PRODUCT_FINAL_QUANTITY = 2;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_INIT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        
        System.assertEquals(INITIAL_AMOUNT-TRANSACTION_COUNT*PRODUCT_INIT_QUANTITY, products[0].Available_Amount__c, 'LineItemTrigger: Wrong initial amount');
        
        for(Line_Item__c lineItem: lineItems){
            lineItem.Quantity__c = PRODUCT_FINAL_QUANTITY;
        }
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(lineItems);
        Test.stopTest();
        
        for(Database.SaveResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT-TRANSACTION_COUNT*PRODUCT_FINAL_QUANTITY, products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    
    @isTest
    public static void testAfterUpdate_ChangeProduct() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_QUANTITY = 1;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 2);
        Id product1Id = products[0].Id;
        Id product2Id = products[1].Id;
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, new List<Product__c>{products[0]}, PRODUCT_QUANTITY, true);
        
        Map<Id, Product__c> productMap = new Map<Id, Product__c>([SELECT Available_Amount__c FROM Product__c]);
        System.assertEquals(INITIAL_AMOUNT-TRANSACTION_COUNT*PRODUCT_QUANTITY, productMap.get(product1Id).Available_Amount__c, 'LineItemTrigger: Wrong initial amount for first product');
        System.assertEquals(INITIAL_AMOUNT, productMap.get(product2Id).Available_Amount__c, 'LineItemTrigger: Wrong initial amount for second product');
        
        for(Line_Item__c lineItem: lineItems){
            lineItem.Product__c = product2Id;
        }
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(lineItems);
        Test.stopTest();
        
        for(Database.SaveResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        productMap = new Map<Id, Product__c>([SELECT Available_Amount__c FROM Product__c]);
        System.assertEquals(INITIAL_AMOUNT, productMap.get(product1Id).Available_Amount__c, 'LineItemTrigger: Wrong amount for first product');
        System.assertEquals(INITIAL_AMOUNT-TRANSACTION_COUNT*PRODUCT_QUANTITY, productMap.get(product2Id).Available_Amount__c, 'LineItemTrigger: Wrong amount for second product');
    }
    
    @isTest
    public static void testAfterUpdate_Cancelled() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_INIT_QUANTITY = 1;
        final Integer PRODUCT_FINAL_QUANTITY = 2;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Cancelled', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_INIT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong initial amount');
        
        for(Line_Item__c lineItem: lineItems){
            lineItem.Quantity__c = PRODUCT_FINAL_QUANTITY;
        }
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(lineItems);
        Test.stopTest();
        
        for(Database.SaveResult result: results) {
        	System.assert(result.isSuccess(), 'LineItemTrigger: Unexpected error');
        }
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        System.assertEquals(INITIAL_AMOUNT, products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }
    
    @isTest
    public static void testAfterUpdate_Excess() {
        final Integer INITIAL_AMOUNT = 100;
        final Integer TRANSACTION_COUNT = 5;
        final Integer PRODUCT_INIT_QUANTITY = 1;
        final Integer PRODUCT_FINAL_QUANTITY = 30;
        List<Product__c> products = TestDataFactory.createProducts(10, INITIAL_AMOUNT, 1);
        List<Transaction__c> transactions = TestDataFactory.createTransactions('Active', 'Visa', TRANSACTION_COUNT);
        List<Line_Item__c> lineItems = TestDataFactory.createLineItems(transactions, products, PRODUCT_INIT_QUANTITY, true);
        
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
        
        System.assertEquals(INITIAL_AMOUNT-TRANSACTION_COUNT*PRODUCT_INIT_QUANTITY, products[0].Available_Amount__c, 'LineItemTrigger: Wrong initial amount');
        
        for(Line_Item__c lineItem: lineItems){
            lineItem.Quantity__c = PRODUCT_FINAL_QUANTITY;
        }
        
        Test.startTest();
        List<Database.SaveResult> results = Database.update(lineItems, false);
        Test.stopTest();
        
  		List<Database.Error> errors = new List<Database.Error>();
        for(Database.SaveResult result: results) {
        	if(!result.isSuccess())
            errors = result.getErrors();
        }
        System.assert(errors.size()>0, 'LineItemTrigger: Error expected');
        System.assertEquals('Insufficient amount available!', errors[0].getMessage(), 'TransactionTrigger: Wrong error');
        products = [SELECT Available_Amount__c FROM Product__c WHERE Id = :products[0].Id];
       
        System.assertEquals(INITIAL_AMOUNT-PRODUCT_FINAL_QUANTITY*(Integer)(INITIAL_AMOUNT/PRODUCT_FINAL_QUANTITY) - 
                            PRODUCT_INIT_QUANTITY*(TRANSACTION_COUNT-(Integer)(INITIAL_AMOUNT/PRODUCT_FINAL_QUANTITY)), products[0].Available_Amount__c, 'LineItemTrigger: Wrong amount');
    }

}