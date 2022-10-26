@isTest
public class GroceryDAOTest {
    final static Integer ACTIVE_VISA_TRANSACTION_COUNT = 4;
    final static Integer ACTIVE_MASTERCARD_TRANSACTION_COUNT = 2;
    final static Integer CLOSED_VISA_TRANSACTION_COUNT = 6;
    final static Integer CLOSED_MASTERCARD_TRANSACTION_COUNT = 5;
    final static Integer CANCELLED_VISA_TRANSACTION_COUNT = 1;
    final static Integer CANCELLED_MASTERCARD_TRANSACTION_COUNT = 1;
    final static Integer PRODUCT_PRICE = 10;   
    
    @TestSetup
    public static void setup() {
        List<Transaction__c> allTransactions = new List<Transaction__c>();
        allTransactions.addAll(TestDataFactory.createTransactions('Active', 'Visa', ACTIVE_VISA_TRANSACTION_COUNT));
        allTransactions.addAll(TestDataFactory.createTransactions('Active', 'Mastercard', ACTIVE_Mastercard_TRANSACTION_COUNT));
        allTransactions.addAll(TestDataFactory.createTransactions('Closed', 'Visa', CLOSED_VISA_TRANSACTION_COUNT));
        allTransactions.addAll(TestDataFactory.createTransactions('Closed', 'Mastercard', CLOSED_MASTERCARD_TRANSACTION_COUNT));
        allTransactions.addAll(TestDataFactory.createTransactions('Cancelled', 'Visa', CANCELLED_VISA_TRANSACTION_COUNT));
        allTransactions.addAll(TestDataFactory.createTransactions('Cancelled', 'Mastercard', CANCELLED_MASTERCARD_TRANSACTION_COUNT));
        
        List<Product__c> products = TestDataFactory.createProducts(PRODUCT_PRICE, 1000, 4);
        products[3].Available_Amount__c = 0;
        update products[3];
        
        TestDataFactory.createLineItems(allTransactions, new List<Product__c>{products[0]}, 3, true);
        TestDataFactory.createLineItems(allTransactions, new List<Product__c>{products[1]}, 2, true);
        TestDataFactory.createLineItems(allTransactions, new List<Product__c>{products[2]}, 1, true);
    
    }
   
    @isTest
    public static void getNumberOfSoldProductsTest() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        Map<Id, Integer> soldProductMap = GroceryDAO.getNumberOfSoldProducts(Datetime.now().addDays(-1), Datetime.now());
        test.stopTest();
        System.assertEquals(3, soldProductMap.keyset().size(), 'Wrong count of products');
        System.assertEquals((CLOSED_VISA_TRANSACTION_COUNT+CLOSED_MASTERCARD_TRANSACTION_COUNT)*3, soldProductMap.get(productMap.get('1').Id), 'Wrong quantity for product 1');
        System.assertEquals((CLOSED_VISA_TRANSACTION_COUNT+CLOSED_MASTERCARD_TRANSACTION_COUNT)*2, soldProductMap.get(productMap.get('2').Id), 'Wrong quantity for product 2');
        System.assertEquals((CLOSED_VISA_TRANSACTION_COUNT+CLOSED_MASTERCARD_TRANSACTION_COUNT), soldProductMap.get(productMap.get('3').Id), 'Wrong quantity for product 3');
    }
    
    @isTest
	public static void getNumberOfSoldProductsTest_Negative() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        Map<Id, Integer> soldProductMap = GroceryDAO.getNumberOfSoldProducts(System.now(), Datetime.newInstance(Date.today(), Time.newInstance(1, 1, 1, 1)));
        test.stopTest();
        System.assertEquals(0, soldProductMap.keyset().size(), 'Wrong count of products');
    }
    
    @isTest 
    public static void getTotalAmountOfTransactionsTest() {
        Set<id> transactionIds = new Map<id, Transaction__c>([SELECT Id FROM Transaction__c]).keyset();
        test.startTest();
        Map<Id, Decimal> transactionAmountMap = GroceryDAO.getTotalAmountOfTransactions(transactionIds);
        test.stopTest(); 	
        System.assertEquals(ACTIVE_VISA_TRANSACTION_COUNT+ACTIVE_MASTERCARD_TRANSACTION_COUNT+
                            CLOSED_VISA_TRANSACTION_COUNT+CLOSED_MASTERCARD_TRANSACTION_COUNT+
                            CANCELLED_VISA_TRANSACTION_COUNT+CANCELLED_MASTERCARD_TRANSACTION_COUNT, transactionAmountMap.keyset().size(), 'Wrong count of transactions');
        for(Decimal amount: transactionAmountMap.values()) {
           System.assertEquals((3+2+1)*PRODUCT_PRICE, amount, 'Wrong amount for transaction'); 
        }
    }
    
    @isTest 
    public static void getTotalAmountOfTransactionsTest_Negative() {
       	Transaction__c voidTransaction = new Transaction__c();
        insert voidTransaction;
        Set<Id> idSet = new Set<Id>();
        idSet.add(voidTransaction.id);
        test.startTest();
        Map<Id, Decimal> transactionAmountMap = GroceryDAO.getTotalAmountOfTransactions(idSet);
        test.stopTest(); 	
        System.assertEquals(0, transactionAmountMap.keyset().size(), 'Wrong count of products');
    }
	
    @isTest 
    public static void getTopSellersTest() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> topSellers = GroceryDAO.getTopSellers(3, 0, Date.today().year());
        test.stopTest();
        System.assertEquals(3, topSellers.size(), 'Wrong count of products');
        System.assertEquals(productMap.get('1').Id, topSellers[0].Id, 'Unexpected position 1');
        System.assertEquals(productMap.get('2').Id, topSellers[1].Id, 'Unexpected position 2');
        System.assertEquals(productMap.get('3').Id, topSellers[2].Id, 'Unexpected position 3');
    }
    
    @isTest 
    public static void getTopSellersTest_Offset() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> topSellers = GroceryDAO.getTopSellers(3, 1, Date.today().year());
        test.stopTest();
        System.assertEquals(2, topSellers.size(), 'Wrong count of products');
        System.assertEquals(productMap.get('2').Id, topSellers[0].Id, 'Unexpected position 1');
        System.assertEquals(productMap.get('3').Id, topSellers[1].Id, 'Unexpected position 2');
    }
    
    @isTest 
    public static void getTopSellersTest_Negative() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> topSellers = GroceryDAO.getTopSellers(0, 1, Date.today().year());
        test.stopTest();
        System.assertEquals(0, topSellers.size(), 'Wrong count of products');
    }
    
    @isTest 
    public static void getPaymentStatisticsAmountTest() {
		test.startTest();
        List<AggregateResult> results = GroceryDAO.getPaymentStatisticsAmount();
        test.stopTest();
        System.assertEquals(2, results.size(), 'Wrong count of results');
        Map<String, Decimal> paymentAmountMap = new Map<String, Decimal>();
            for(AggregateResult result: results) {
                paymentAmountMap.put((String) result.get('paymentType'), (Decimal) result.get('totalQuantity'));
            }
        System.assertEquals(CLOSED_VISA_TRANSACTION_COUNT*(3+2+1), paymentAmountMap.get('Visa'), 'Wrong amount for Visa payment');
        System.assertEquals(CLOSED_MASTERCARD_TRANSACTION_COUNT*(3+2+1), paymentAmountMap.get('MasterCard'), 'Wrong amount for Mastercard payment');
    }
    
    @isTest 
    public static void getProductsTest() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> products = GroceryDAO.getProducts(5, 0);
        test.stopTest();
        System.assertEquals(4, products.size(), 'Wrong count of products');
    }
    
    @isTest 
    public static void getProductsTest_Offset() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> products = GroceryDAO.getProducts(5, 2);
        test.stopTest();
        System.assertEquals(2, products.size(), 'Wrong count of products');
    }
    
    @isTest 
    public static void getProductsTest_Negative() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> products = GroceryDAO.getProducts(1, 5);
        test.stopTest();
        System.assertEquals(0, products.size(), 'Wrong count of products');
    }
    
    @isTest 
    public static void getProductAvailableInStoreTest() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> products = GroceryDAO.getProductAvailableInStore(5, 0);
        test.stopTest();
        System.assertEquals(3, products.size(), 'Wrong count of products');
    }
    
    @isTest 
    public static void getProductAvailableInStoreTest_Offset() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> products = GroceryDAO.getProductAvailableInStore(5, 2);
        test.stopTest();
        System.assertEquals(1, products.size(), 'Wrong count of products');
    }
    
    @isTest 
    public static void getProductAvailableInStoreTest_Negative() {
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product: [SELECT Code__c FROM Product__c]) {
            productMap.put(product.Code__c, product);
        }
        test.startTest();
        List<Product__c> products = GroceryDAO.getProductAvailableInStore(1, 5);
        test.stopTest();
        System.assertEquals(0, products.size(), 'Wrong count of products');
    }

}