# Technical Notes

## Key Notes

1. **Unique Identifier for Machine Models**:
   - A new field, `Model_Unique_Code__c`, was added to uniquely identify car models.
     ![Screenshot 2024-12-23 084617](https://github.com/user-attachments/assets/9f06055a-f6af-4a79-a881-d809046e38b3)

   - Using fields like `Name`, `Brand`, or even `ID` to communicate with the API is unreliable because:
     - The values of these fields can easily change due to scenarios like rebranding.
     - On different Salesforce instances, the same record might have a different ID.
     - A unique identifier ensures consistency and reliability when communicating with the API.
     - This field can also serve as an external ID for integrations, such as migrating data from another system.

2. **Fetch Car Price Method**:
   - The method:
     ```
     @AuraEnabled
     public static String fetchCarPrice(String uniqueCode)
     ```
     - Does **not** include the annotation `Cacheable=true` because:
       - Data from the API may change frequently.
       - Caching could lead to outdated data being returned.

3. **Dynamic Field Handling**:
   - The Apex controller does not need to be modified when new fields on the  (Car_Model__c) object  are added and need to be displayed on the UI because the fields are passed dynamically:
     ```
     String soqlQuery = 'SELECT ' + String.join(fields, ', ') + ' FROM Car_Model__c';
     ```
   - To include a new field:
     - Retrieve it in the JS code using the `Schema` class.
     - Pass it dynamically to the method.

4. **UI Examples**:
   - **PC Version**:
    ![Recording 2024-12-23 at 08 53 10](https://github.com/user-attachments/assets/4780cb8c-e63d-4338-9d21-c40fe2d38b8f)

   - **Mobile Version**:
     ![Recording 2024-12-23 at 08 43 33](https://github.com/user-attachments/assets/df133113-44bd-49b3-b98a-12f80095ef64)


