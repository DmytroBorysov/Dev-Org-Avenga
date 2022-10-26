public class MostProfitableTransactionsController {
    @AuraEnabled(cacheable=true)
    public static List<Transaction__c> getMostProfitableTransactions() {
       	return [SELECT Name, CreatedDate, Status__c, Payment_Type__c, Total_Amount__c FROM Transaction__c WHERE Status__c !='Cancelled' ORDER BY Total_Amount__c DESC LIMIT 10];
    }

}