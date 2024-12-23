@IsTest
public class CarModelsPriceInfoControllerTest {

    private class CustomHttpMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String responseBody;

        public CustomHttpMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.responseBody);
            return res;
        }
    }

    private static HttpCalloutMock createMockResponse(Integer statusCode, String responseBody) {
        return new CustomHttpMock(statusCode, responseBody);
    }

    @IsTest
    static void testGetCarModelsInfo() {
        List<Car_Model__c> testModels = new List<Car_Model__c>{
                new Car_Model__c(Name = 'Model A', Brand__c = 'Brand1', Model_Unique_Code__c = 'AB1'),
                new Car_Model__c(Name = 'Model B', Brand__c = 'Brand2', Model_Unique_Code__c = 'BB2')
        };
        insert testModels;

        Test.startTest();
        List<String> fields = new List<String>{'Name', 'Brand__c', 'Model_Unique_Code__c'};
        List<Car_Model__c> result = CarModelsPriceInfoController.getCarModelsInfo(fields);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Expected two records to be returned');
        System.assertEquals('Model A', result[0].Name, 'First model name does not match');
    }

    @IsTest
    static void testGetCarModelsInfoWithInvalidFields() {
        Test.startTest();
        try {
            List<String> fields = new List<String>{'InvalidField1', 'InvalidField2'};
            CarModelsPriceInfoController.getCarModelsInfo(fields);
            System.assert(false, 'Expected exception to be thrown due to invalid fields');
        } catch (Exception ex) {
            System.assert(ex.getTypeName().equals('System.AuraHandledException'), 'Expected AuraHandledException');
        }
        Test.stopTest();
    }

    @IsTest
    static void testFetchCarPrice() {
        Test.setMock(HttpCalloutMock.class, createMockResponse(200, '[{"modelCode": "TES-MS","price": "73,490$"}]'));

        Test.startTest();
        String price = CarModelsPriceInfoController.fetchCarPrice('TES-MS');
        Test.stopTest();

        System.assertEquals('73,490$', price, 'Expected price does not match the mock response');
    }

    @IsTest
    static void testFetchCarPriceNoData() {
        Test.setMock(HttpCalloutMock.class, createMockResponse(200, '[]'));

        Test.startTest();
        String price = CarModelsPriceInfoController.fetchCarPrice('MODEL456');
        Test.stopTest();

        System.assertEquals('No price data found', price, 'Expected message for no price data');
    }

    @IsTest
    static void testFetchCarPriceError() {
        Test.setMock(HttpCalloutMock.class, createMockResponse(500, 'Internal Server Error'));

        Test.startTest();
        try {
            CarModelsPriceInfoController.fetchCarPrice('MODEL789');
            System.assert(false, 'Expected exception to be thrown');
        } catch (Exception ex) {
            System.assert(ex.getTypeName().equals('System.AuraHandledException'), 'Expected AuraHandledException');
        }
        Test.stopTest();
    }
}