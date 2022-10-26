@isTest
public class GroceryServicesTest {
    final static Integer ACTIVE_TRANSACTION_COUNT = 4;
    final static Integer CLOSED_TRANSACTION_COUNT = 6;
    final static Integer CANCELLED_TRANSACTION_COUNT = 3;
    final static Integer PRODUCT_COUNT = 5;
	final static Integer PRODUCT_PRICE = 10;
    
    @TestSetup
    public static void setup() {
		List<Transaction__c> allTransactions = new List<Transaction__c>();
        allTransactions.addAll(TestDataFactory.createTransactions('Active', 'Visa', ACTIVE_TRANSACTION_COUNT));
        allTransactions.addAll(TestDataFactory.createTransactions('Closed', 'Visa', CLOSED_TRANSACTION_COUNT)); 
        allTransactions.addAll(TestDataFactory.createTransactions('Cancelled', 'Visa', CANCELLED_TRANSACTION_COUNT));
        
        List<Product__c> products = TestDataFactory.createProducts(PRODUCT_PRICE, 1000, PRODUCT_COUNT);
        
        TestDataFactory.createLineItems(allTransactions, products, 1, true);
    }
    
    @isTest 
    public static void filterValidTransactionsTest() {
    	List<Transaction__c> transactions = [SELECT Id, Status__c FROM Transaction__c];
        test.startTest();
        List<Transaction__c> validTransactions = GroceryServices.filterValidTransactions(transactions);
        test.stopTest();
        
        System.assertEquals(ACTIVE_TRANSACTION_COUNT + CLOSED_TRANSACTION_COUNT, validTransactions.size(), 'Wrong number of valid transactions');
        
        for(Transaction__c tr: validTransactions) {
            System.assert(tr.Status__c == 'Active' || tr.Status__c == 'Closed', 'Unexpected transaction status');
        }
    }
    
    @isTest 
    public static void filterValidTransactionsTest_EmptyList() {
        test.startTest();
        List<Transaction__c> validTransactions = GroceryServices.filterValidTransactions(new List<Transaction__c>());
        test.stopTest();
        
        System.assertEquals(0, validTransactions.size(), 'Blank list expected');
    }
    
    @isTest 
    public static void calculateTotalAmountTest() {
		List<Line_Item__c> lineItems = [SELECT Id, Amount__c FROM Line_Item__c];            

        test.startTest();
        Integer amount = GroceryServices.calculateTotalAmount(lineItems);
        test.stopTest();
        
        System.assertEquals((ACTIVE_TRANSACTION_COUNT + CLOSED_TRANSACTION_COUNT + CANCELLED_TRANSACTION_COUNT)*PRODUCT_COUNT*PRODUCT_PRICE, amount, 'Wrong amount');
    }
    
    @isTest 
    public static void calculateTotalAmountTest_Closed() {
		List<Line_Item__c> lineItems = [SELECT Id, Amount__c FROM Line_Item__c WHERE Transaction__r.Status__c = 'Closed'];            

        test.startTest();
        Integer amount = GroceryServices.calculateTotalAmount(lineItems);
        test.stopTest();
        
        System.assertEquals(CLOSED_TRANSACTION_COUNT*PRODUCT_COUNT*PRODUCT_PRICE, amount, 'Wrong amount');
    }
    
	@isTest 
    public static void calculateTotalAmountTest_EmptyList() {
        test.startTest();
        Integer amount = GroceryServices.calculateTotalAmount(new List<Line_Item__c>());
        test.stopTest();
        
        System.assertEquals(0, amount, 'Wrong amount');
    }
    
    @isTest 
    public static void createTransactionTest_Valid() {
        test.startTest();
        Database.SaveResult result = GroceryServices.createTransaction('MasterCard');
        test.stopTest();
        System.assert(result.isSuccess(), 'Unexpected error');
        Map<Id, Transaction__c> allTransactionMap = new Map<Id, Transaction__c>([SELECT Payment_Type__c FROM Transaction__c]);
        System.assertEquals(ACTIVE_TRANSACTION_COUNT + CLOSED_TRANSACTION_COUNT + CANCELLED_TRANSACTION_COUNT + 1, allTransactionMap.keySet().size(), 'Wrong total number of transaction');
        System.assertEquals('MasterCard', allTransactionMap.get(result.getId()).Payment_Type__c, 'Wrong payment type in new transaction');
    }
    
    @isTest 
    public static void createTransactionTest_Invalid() {
        test.startTest();
        Database.SaveResult result = GroceryServices.createTransaction('WRONG');
        test.stopTest();
        System.assert(!result.isSuccess(), 'Error expected');
        Map<Id, Transaction__c> allTransactionMap = new Map<Id, Transaction__c>([SELECT Payment_Type__c FROM Transaction__c]);
        System.assertEquals(ACTIVE_TRANSACTION_COUNT + CLOSED_TRANSACTION_COUNT + CANCELLED_TRANSACTION_COUNT, allTransactionMap.keySet().size(), 'Wrong total number of transaction');
   }
    
    @isTest 
    public static void createTransactionWithLineItemsTest_Valid() {
        List<GroceryServices.LineItemDTO> lineItemDTOList = new List<GroceryServices.LineItemDTO>();
        for(Line_Item__c lineItem: [SELECT Product__c, Quantity__c, Amount__c FROM Line_Item__c WHERE Transaction__r.Status__c = 'Cancelled']) {
            lineItemDTOList.add(new GroceryServices.LineItemDTO(lineItem.Product__c, (Integer)lineItem.Quantity__c, (Integer)lineItem.Amount__c));
        }
        test.startTest();
        Database.SaveResult result = GroceryServices.createTransaction('MasterCard', lineItemDTOList);
        test.stopTest();
        System.assert(result.isSuccess(), 'Unexpected error');
        Map<Id, Transaction__c> allTransactionMap = new Map<Id, Transaction__c>([SELECT Payment_Type__c FROM Transaction__c]);
        System.assertEquals(ACTIVE_TRANSACTION_COUNT + CLOSED_TRANSACTION_COUNT + CANCELLED_TRANSACTION_COUNT + 1, allTransactionMap.keySet().size(), 'Wrong total number of transaction');
        System.assertEquals('MasterCard', allTransactionMap.get(result.getId()).Payment_Type__c, 'Wrong payment type in new transaction');
        List<Line_Item__c> newLineItems = [SELECT Id FROM Line_Item__c WHERE Transaction__c = :result.getId()];
        System.assertEquals(CANCELLED_TRANSACTION_COUNT*PRODUCT_COUNT, newLineItems.size(), 'Wrong number of new line items');
    }
    
    @isTest 
    public static void createTransactionWithLineItemsTest_Invalid() {
        List<GroceryServices.LineItemDTO> lineItemDTOList = new List<GroceryServices.LineItemDTO>();
        for(Line_Item__c lineItem: [SELECT Product__c, Quantity__c, Amount__c FROM Line_Item__c WHERE Transaction__r.Status__c = 'Cancelled']) {
            lineItemDTOList.add(new GroceryServices.LineItemDTO(lineItem.Product__c, (Integer)lineItem.Quantity__c, (Integer)lineItem.Amount__c));
        }
        test.startTest();
        Database.SaveResult result = GroceryServices.createTransaction('WRONG', lineItemDTOList);
        test.stopTest();
        System.assert(!result.isSuccess(), 'Error expected');
        Map<Id, Transaction__c> allTransactionMap = new Map<Id, Transaction__c>([SELECT Payment_Type__c FROM Transaction__c]);
        System.assertEquals(ACTIVE_TRANSACTION_COUNT + CLOSED_TRANSACTION_COUNT + CANCELLED_TRANSACTION_COUNT, allTransactionMap.keySet().size(), 'Wrong total number of transaction');
        List<Line_Item__c> allLineItems = [SELECT Id FROM Line_Item__c];
        System.assertEquals((ACTIVE_TRANSACTION_COUNT + CLOSED_TRANSACTION_COUNT + CANCELLED_TRANSACTION_COUNT)*PRODUCT_COUNT, allLineItems.size(), 'Wrong total of line items');
    }
    
    @isTest 
    public static void createLineItemTest_Valid() {
        Transaction__c newTransaction = TestDataFactory.createTransactions('Active', 'Visa', 1)[0];  
        Product__c product = [SELECT Id FROM Product__c LIMIT 1];
        test.startTest();
        Database.SaveResult result = GroceryServices.createLineItem(newTransaction.Id, product.id, PRODUCT_PRICE);
        test.stopTest();
        System.assert(result.isSuccess(), 'Unexpected error');
        List<Line_Item__c> newLineItems = [SELECT Product__c, Quantity__c, Amount__c FROM Line_Item__c WHERE Transaction__c = :newTransaction.Id];
        System.assertEquals(1, newLineItems.size(), 'Wrong number of new line items');
        System.assertEquals(product.Id, newLineItems[0].Product__c, 'Wrong product in new line item');
        System.assertEquals(1, newLineItems[0].Quantity__c, 'Wrong quantity in new line item');
        System.assertEquals(PRODUCT_PRICE, newLineItems[0].Amount__c, 'Wrong amount in new line item');        
    }
    
    @isTest 
    public static void createLineItemTest_Invalid() {
        Product__c product = [SELECT Id FROM Product__c LIMIT 1];
        test.startTest();
        Database.SaveResult result = GroceryServices.createLineItem(null, product.id, PRODUCT_PRICE);
        test.stopTest();
        System.assert(!result.isSuccess(), 'Error expected');      
    }
    
    @isTest 
    public static void cancelTransactionTest() {
    	Transaction__c tr = [SELECT Id FROM Transaction__c WHERE Status__c!='Cancelled' LIMIT 1];   
        
        test.startTest();
        GroceryServices.cancelTransaction(tr.Id);
        test.stopTest();
        
        Map<Id, Transaction__c> allCancelledTransactionMap = new Map<Id, Transaction__c>([SELECT Status__c FROM Transaction__c WHERE Status__c = 'Cancelled']);
        System.assertEquals(CANCELLED_TRANSACTION_COUNT+1, allCancelledTransactionMap.keySet().size(), 'Wrong number of cancelled transaction');
        System.assertEquals('Cancelled', allCancelledTransactionMap.get(tr.Id).Status__c, 'Wrong transaction status');     
    }
    
    @isTest 
    public static void cancelTransactionTest_AlreadyCancelled() {
    	Transaction__c tr = [SELECT Id FROM Transaction__c WHERE Status__c='Cancelled' LIMIT 1];   
        
        test.startTest();
        GroceryServices.cancelTransaction(tr.Id);
        test.stopTest();
        
        Map<Id, Transaction__c> allCancelledTransactionMap = new Map<Id, Transaction__c>([SELECT Status__c FROM Transaction__c WHERE Status__c = 'Cancelled']);
        System.assertEquals(CANCELLED_TRANSACTION_COUNT, allCancelledTransactionMap.keySet().size(), 'Wrong number of cancelled transaction');
        System.assertEquals('Cancelled', allCancelledTransactionMap.get(tr.Id).Status__c, 'Wrong transaction status');     
    }
    
    @isTest  
    public static void deleteLineItemTest() {
    	Line_Item__c lineItem = [SELECT Id FROM Line_Item__c LIMIT 1];   
        
        test.startTest();
        GroceryServices.deleteLineItem(lineItem.Id);
        test.stopTest();
        
        Map<Id, Line_Item__c> allLineItemMap = new Map<Id, Line_Item__c>([SELECT Id FROM Line_Item__c]);
        System.assertEquals((ACTIVE_TRANSACTION_COUNT + CLOSED_TRANSACTION_COUNT + CANCELLED_TRANSACTION_COUNT) * PRODUCT_COUNT - 1, allLineItemMap.keySet().size(), 'Wrong total number of line items');
        System.assert(!allLineItemMap.containsKey(lineItem.Id), 'Unexpected result');     
    }
}