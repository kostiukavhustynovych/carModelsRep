public with sharing class CarModelsPriceInfoController {
    @AuraEnabled(Cacheable=true)
    public static List<Car_Model__c> getCarModelsInfo(List<String> fields) {
        try {
            String soqlQuery = 'SELECT ' + String.join(fields, ', ') + ' FROM Car_Model__c';
            return Database.query(soqlQuery);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String fetchCarPrice(String uniqueCode) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CarModelsRealTimePrices' + '?modelCode=' + String.escapeSingleQuotes(uniqueCode));
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            List<Object> responseBody = (List<Object>) JSON.deserializeUntyped(response.getBody());
            if (!responseBody.isEmpty()) {
                Map<String, Object> firstItem = (Map<String, Object>) responseBody[0];
                return String.valueOf(firstItem.get('price'));
            } else {
                return 'No price data found';
            }
        } else {
            throw new AuraHandledException('Failed to fetch price. HTTP Status: ' + response.getStatus());
        }
    }
}