@isTest
public class TestDataFactory {
	
    public static List<Transaction__c> createTransactions(String status, String paymentType, Integer count) {
		List<Transaction__c> transactions = new List<Transaction__c>();
        for(Integer i = 0; i < count; i++) {
       		transactions.add(new Transaction__c(Payment_Type__c = paymentType, Status__c = status));
        }

        insert transactions;
		return transactions;
	}
    
    public static List<Product__c> createProducts(Decimal price, Decimal amount, Integer count) {
        List<Product__c> products = new List<Product__c>();
        for(Integer i = 0; i < count; i++) {
        	products.add(new Product__c(Name = 'testProduct', Price__c = price, Available_Amount__c = amount, Code__c = ''+(i+1)));
        }
        
        insert products;
        return products;
	}
	
	public static List<Line_Item__c> createLineItems(List<Transaction__c> transactions, List<Product__c> products, Decimal quantity, Boolean doInsert) {
		List<Line_Item__c> lineItems = new List<Line_Item__c>();
       	for(Transaction__c transact: transactions) {
        for(Product__c product: products) {
        	lineItems.add(new Line_Item__c(Transaction__c = transact.Id, Product__c = product.Id, Quantity__c = quantity));
        }
        }
		if(doInsert) {
			insert lineItems;
		}
		return lineItems;
	}
}