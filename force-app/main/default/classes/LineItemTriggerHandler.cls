public class LineItemTriggerHandler {
    public static void onAfterInsert(List<Line_Item__c> lineItemList) {
        Set<id> productIds = new Set<id>();
        Set<id> transactionIds = new Set<id>();
        
        for (Line_Item__c curItem : lineItemList) {
            productIds.add(curItem.Product__c);
            transactionIds.add(curItem.Transaction__c);
        }
        
        Map<Id, Product__c> productMap = getProductMap(productIds);
        Map<Id, String> transactionStatusMap = getTransactionStatusMap(transactionIds);
        
        for (Line_Item__c curItem : lineItemList) {
            if (transactionStatusMap.get(curItem.Transaction__c) != 'Cancelled') {
                if (productMap.get(curItem.Product__c).Available_Amount__c - curItem.Quantity__c < 0) {
                    curItem.Quantity__c.addError('Insufficient amount available!');
                } else {
                    productMap.get(curItem.Product__c).Available_Amount__c -= curItem.Quantity__c;
                }
            }
        }
        update productMap.values();
    }
    
    public static void onAfterDelete(List<Line_Item__c> priorlineItemList) {
        Set<id> productIds = new Set<id>();
        Set<id> transactionIds = new Set<id>();
        
        for (Line_Item__c curItem : priorlineItemList) {
            productIds.add(curItem.Product__c);
            transactionIds.add(curItem.Transaction__c);
        }
        
        Map<Id, Product__c> productMap = getProductMap(productIds);
        Map<Id, String> transactionStatusMap = getTransactionStatusMap(transactionIds);
        
        for (Line_Item__c curItem : priorlineItemList) {
            if (transactionStatusMap.get(curItem.Transaction__c) != 'Cancelled') {
                productMap.get(curItem.Product__c).Available_Amount__c += curItem.Quantity__c;
            }
        }
        update productMap.values();
    }
    
    public static void onAfterUpdate(List<Line_Item__c> lineItemList, Map <Id, Line_Item__c> priorLineItemMap) {
        Set<id> productIds = new Set<id>();
        Set<id> transactionIds = new Set<id>();
        
        for (Line_Item__c curItem : priorLineItemMap.values()) {
            productIds.add(curItem.Product__c);
            transactionIds.add(curItem.Transaction__c);
        }      
        for (Line_Item__c curItem : lineItemList) {
            productIds.add(curItem.Product__c);
            transactionIds.add(curItem.Transaction__c);
        }
        
        Map<Id, Product__c> productMap = getProductMap(productIds);
        Map<Id, String> transactionStatusMap = getTransactionStatusMap(transactionIds);
        Line_Item__c priorItem;
        for (Line_Item__c curItem : lineItemList) {
            priorItem = priorLineItemMap.get(curItem.Id);
            if (transactionStatusMap.get(priorItem.Transaction__c) != 'Cancelled') {
                productMap.get(priorItem.Product__c).Available_Amount__c += priorItem.Quantity__c;	    
            }
            if (transactionStatusMap.get(curItem.Transaction__c) != 'Cancelled') {
                if (productMap.get(curItem.Product__c).Available_Amount__c - curItem.Quantity__c < 0) {
                    curItem.Quantity__c.addError('Insufficient amount available!');
                } else {
                    productMap.get(curItem.Product__c).Available_Amount__c -= curItem.Quantity__c;
                }
            }
        }
        update productMap.values();
    }
    
    private static Map<Id, Product__c> getProductMap(Set<id> productIds) {
        return new Map<Id, Product__c>([SELECT Available_Amount__c FROM Product__c WHERE Id IN :productIds]);
    }
    
    private static Map<Id, String> getTransactionStatusMap(Set<id> transactionIds) {
        Map<Id, String> transactionStatusMap = new Map<Id, String>();
        
        for (Transaction__c curTransaction : [SELECT Status__c FROM Transaction__c WHERE Id IN :transactionIds]) {
            transactionStatusMap.put(curTransaction.Id, curTransaction.Status__c);
        }
        return transactionStatusMap;
    }
}