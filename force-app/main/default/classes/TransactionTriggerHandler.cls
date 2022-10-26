public class TransactionTriggerHandler {
   public static void onAfterUpdate(List<Transaction__c> transactionList,  Map <Id, Transaction__c> priorTransactionMap) {
       Map<Id, List<Line_Item__c>> transactionToLineItemsMap = new Map<Id, List<Line_Item__c>>();
       Map<Id, Decimal> productAmountMap = new Map<Id, Decimal>();
       for (Line_Item__c curItem: [SELECT Transaction__c, Quantity__c, Product__c, Product__r.Available_Amount__c FROM Line_Item__c WHERE Transaction__c IN :priorTransactionMap.keySet()]) {
           if(!transactionToLineItemsMap.containsKey(curItem.Transaction__c)) {
               transactionToLineItemsMap.put(curItem.Transaction__c, new List<Line_Item__c>());
           }
           transactionToLineItemsMap.get(curItem.Transaction__c).add(curItem);
           if(!productAmountMap.containsKey(curItem.Product__c)) {
               productAmountMap.put(curItem.Product__c, curItem.Product__r.Available_Amount__c);
           }           
       }
       Transaction__c priorTransaction;
       for(Transaction__c curTransaction: transactionList) {
           priorTransaction = priorTransactionMap.get(curTransaction.Id);
           if(curTransaction.Status__c == 'Cancelled' && priorTransaction.Status__c != 'Cancelled') {
               for(Line_Item__c curItem: transactionToLineItemsMap.get(curTransaction.Id)) {
                   productAmountMap.put(curItem.Product__c, productAmountMap.get(curItem.Product__c) + curItem.Quantity__c);
               }
           } else if(curTransaction.Status__c != 'Cancelled' && priorTransaction.Status__c == 'Cancelled') {
               Boolean isError = false;
               Map<Id, Decimal> productAmountMapCopy = productAmountMap.clone();
               for(Line_Item__c curItem: transactionToLineItemsMap.get(curTransaction.Id)) {
                   if(productAmountMapCopy.get(curItem.Product__c)-curItem.Quantity__c < 0) {
                       isError = true;
                       break;
                   } else {
                       productAmountMapCopy.put(curItem.Product__c, productAmountMapCopy.get(curItem.Product__c) - curItem.Quantity__c);
                   }
               }
               if(isError) {
                   curTransaction.addError('Insufficient amount available!');
               } else {
                   productAmountMap = productAmountMapCopy;
               }                   
           }
       }
       List<Product__c> productsToUpdate = new List<Product__c>();
       for(Id productId: productAmountMap.keySet()) {
			productsToUpdate.add(new Product__c(Id = productId, Available_Amount__c = productAmountMap.get(productId)));
       }
       update productsToUpdate;
   }
}