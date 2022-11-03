public class LineItemsFromExternalAppController {
  @AuraEnabled(cacheable=true)
  public static List<LineItemWrapper> getLineItems() {
    HttpRequest req = new HttpRequest();
    req.setMethod('GET');
    req.setHeader('ProjectName', 'GroceryStore');
    req.setEndpoint('https://avenga-school.herokuapp.com/retrieve-data');

    Http http = new Http();
    try {
      HttpResponse res = http.send(req);
      if (res.getStatusCode() == 200) {
        return (List<LineItemWrapper>) JSON.deserialize(
          res.getBody(),
          List<LineItemWrapper>.class
        );
      } else {
        throw new AuraHandledException(res.getStatus());
      }
    } catch (System.CalloutException e) {
      system.debug('error: ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class LineItemWrapper {
    @AuraEnabled
    public String transactionNumber;
    @AuraEnabled
    public String productCode;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public Integer quantity;
    @AuraEnabled
    public Integer amount;

    public LineItemWrapper(
      Integer quantity,
      Integer amount,
      String productName,
      String productCode,
      String transactionNumber
    ) {
      this.transactionNumber = transactionNumber;
      this.productCode = productCode;
      this.productName = productName;
      this.quantity = quantity;
      this.amount = amount;
    }
  }
}