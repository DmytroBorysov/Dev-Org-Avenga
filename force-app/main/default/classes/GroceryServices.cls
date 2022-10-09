public with sharing class GroceryServices {
    
    public static List<Transaction__c> filterValidTransactions (List<Transaction__c> transactions) {
        List<Transaction__c> resultTransactions = new List<Transaction__c>();
        for(Transaction__c curTransaction: transactions) {
            if (curTransaction.Status__c == 'Active' || curTransaction.Status__c == 'Closed') {
                resultTransactions.add(curTransaction);
            }
        }
        return resultTransactions;       
    }

    public static Integer calculateTotalAmount (List<Line_Item__c> lineItems) {
        Integer amount = 0;
        for (Line_Item__c lineItem: lineItems) {
            amount += (Integer) lineItem.Amount__c;
        }
        return amount;
    }
}