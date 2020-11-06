@isTest(SeeAllData=true)
public class TestDataManagement {
	/**
	* Creates a record of a given Object. Accepts a list of values to be used in the record creation.
	* 
	* The list of values given by the user is analysed and ensured that it has the minimal values required for the record creation
	*
	* @param String $objectName - The specified Object Name to be worked with
	* @param Map<String, String> $listOfValues - The map of values given by the user
	* @param Boolean isInsert - Control variable checks whether to perform insert action or not
	*
	* @return Sobject - Returns the object created
	*/
	public static Sobject createRecord(String objectName, Map<String, String> listOfValues, Boolean isInsert){
		sObject sObj;
		
		//use GlobalDecribe to get a list of all available Objects
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        Set<String>objectKeys = gd.keySet();

        if(objectKeys.contains(objectName.toLowercase())) {
			try{
				//Creating a new sObject instance
				sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;

				// Check what are the required fields for the object
				Map<String,String> requiredFields = new Map<String, String>(getRequiredFieldsOfObject(objectName));
				
				// create a map with all values to be inserted
				Map<String, String> fieldValues = new Map<String, String>(compareMaps(listOfValues, requiredFields));

				for(String field: fieldValues.keySet()){
					
					// Insert values in record. Converts String values from the map to specific DataType of the Object Field.
					sObj.put(field, returnValueFormatted(field, fieldValues.get(field), objectName));
				}
				if(isInsert){
					insert sObj;
				}
				}Catch(DmlException e){
					System.debug('Error: '+ e.getMessage());
				}
				
			}else{
				// Given object name does not exists
				System.debug('Object ' + objectName + 'does not exists');
			}
			return sObj;
	}

	public static Object returnValueFormatted(String field, String value, String objName){
		// Get Global ORG scheme
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		// Get specific object scheme
		Schema.SObjectType objectSchema = gd.get(objName);
		// Get field of the object
		Map<String, Schema.SObjectField> fieldsMap = objectSchema.getDescribe().fields.getMap();
		// Get DataType of specific Field
		Schema.DisplayType fieldType = fieldsMap.get(field).getDescribe().getType();

		if(fieldType == Schema.DisplayType.Date){
			return Date.valueOf(value);
		}else if(fieldType == Schema.DisplayType.Boolean){
			return Boolean.valueOf(value);
		}else if(fieldType == Schema.DisplayType.Double){
			return Decimal.valueOf(value);
		}else if(fieldType == Schema.DisplayType.Currency){
			return Decimal.valueOf(value);
		}else{
			return value;
		}
	}

	public static Map<String, String> getRequiredFieldsOfObject(String objectName){
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Schema.SObjectType objectSchema = gd.get(objectName);
		Map<String, Schema.SObjectField> fieldsMap = objectSchema.getDescribe().fields.getMap();
		Map<String, String> reqFields = new Map<String, String>();
		// Schema.DisplayType fieldType = fieldMap.get('Direct_Channel_Partner__c').getDescribe().getType();
		for(String f:fieldsMap.keySet()){
			Schema.DescribeFieldResult field = fieldsMap.get(f).getDescribe();
			if(field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate()){
				reqFields.put(field.getName(),'');
			}
		}
		return reqFields;
	}

	/**
	* Compare two given maps adding to the first map those values that are missing in the second map
	* Returns a map with the minimal values required to create an Object
	*
	* @param Map<String, String> $m1 - The map of values given by the user.
	* @param Map<String, String> $m2 - The map of values containing the required values for the Object record creation
	* @return Map<String, String> - The map completed
	*/
	public static Map<String, String> compareMaps(Map<String, String> m1, Map<String, String> m2){
		for(String val: m2.keySet()){
			if(!m1.containsKey(val)){
				m1.put(val, m2.get(val));
			}
		}
		return m1;
	}



























    public static Map<String, String> createTestData(String partnerType, String partnerRank, String partnerType2, String partnerRank2, String distributorCountry, String DealReg, String productFamily, String quoteSalesChannel, String authenticationSupport1, String cryptoSupport1, String encryptionSupport1, String authenticationSupport2, String cryptoSupport2, String encryptionSupport2, String areaOfInterest) {  
        Map<String, String> returnedMap = new Map<String, String>();
		List<Account> accList = new List<Account>();
        //PriceBook
		List<Pricebook2> pbook = [SELECT Id FROM Pricebook2 WHERE Name = 'EURO_ZONE'];
        //Products for passed conditions and with an PricebookEntry with EURO currency
		List<Product2> productList = [SELECT Id, Name, SFNT_Tax_Catagory_SFDC_Internal__c FROM Product2 WHERE Product_Family_Internal__c=:productFamily AND IsActive=true 
                                      AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pbook[0].Id AND CurrencyIsoCode = 'EUR') LIMIT 1];
        //
		Id pricebookEntryId = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :pbook[0].Id AND Product2Id = :productList[0].Id AND CurrencyIsoCode = 'EUR'][0].Id;
        
		//CIPHER AGREEMENT
        CipherAgreement__c ca1 = new CipherAgreement__c(Name='Test_Cp_01', Partner_Type__c=partnerType,Partner_Rank__c=partnerRank, Partner_Approval_Date__c=Date.newInstance(2018, 07, 10), Partner_Program_Status__c='Active', Authentication_Support__c=authenticationSupport1, Crypto_Support__c=cryptoSupport1, Encryption_Support__c= encryptionSupport1);
		insert(ca1);
        
        CipherAgreement__c ca2 = new CipherAgreement__c(Name='Test_Cp_01', Partner_Type__c=partnerType2, Partner_Rank__c=partnerRank2, Partner_Approval_Date__c=Date.newInstance(2018, 07, 10), Partner_Program_Status__c='Active', Authentication_Support__c=authenticationSupport2, Crypto_Support__c=cryptoSupport2, Encryption_Support__c= encryptionSupport2);
		insert(ca2);
		
		//ACCOUNTS
		Account acc01 = new Account(Name='Test_Account01', Bill_To_Country__c='Argentina', Industry='Building', Enterprise_Type__c='Customer', Profile_Updated__c='Software Vendor', Direct_Channel_Partner__c=True, Encryption_Type__c='Customer');
		accList.add(acc01);
		Account acc02 = new Account(Name='Test_Account02', ChannelID__c=ca1.Id, Bill_To_Country__c='Argentina', Industry='Building',Enterprise_Type__c='Distributor', Profile_Updated__c='Reseller/Partner', Direct_Channel_Partner__c=True, Encryption_Type__c='Distributor');
		accList.add(acc02);
        Account acc03 = new Account(Name='Test_Account03', ChannelID__c=ca2.Id, Bill_To_Country__c=distributorCountry, Industry='Building',Enterprise_Type__c='Distributor', Profile_Updated__c='Reseller/Partner');
		accList.add(acc03);
		insert(accList);

		//CONTACT
        Contact con = new Contact(FirstName='FstName01', LastName='LstName01', AccountId=acc02.Id, Email='testcontact01@testaccount01.com');
		insert(con);

		//OPPORTUNITY
		Opportunity opty;
        if (DealReg == 'No') {
        	opty = new Opportunity(Name='Test_Opty_01', AccountId=acc02.Id, Type='Renewal', CloseDate=Date.newInstance(2020, 07, 10), StageName='6. Booked', OppPriceBook_c__c='EURO_ZONE', OppPriceBookCurrency_c__c='EUR', Area_Of_Interest__c =areaOfInterest);
        } else {
            opty = new Opportunity(Name='Test_Opty_01', AccountId=acc02.Id, Type='Renewal', CloseDate=Date.newInstance(2020, 07, 10), StageName='6. Booked', OppPriceBook_c__c='EURO_ZONE', OppPriceBookCurrency_c__c='EUR', Deal_Reg__c='1234', 
                                          Deal_Reg_Expiration_Date__c=Date.newInstance(2030, 07, 10), Area_Of_Interest__c =areaOfInterest);
        }
        insert(opty);

		//PRODUCT LINE                                                     
		OpportunityLineItem optyLine = new OpportunityLineItem(Product2Id=productList[0].Id, PricebookEntryId=pricebookEntryId, OpportunityId=opty.Id, Quantity=1000, TotalPrice=25000);
		insert(optyLine);
		
		//QUOTE
		Quote quo;
		//In case of Two Tier sales channel is necessary to set Distributor
        if (quoteSalesChannel == 'Two Tier (Both a Distributor and Reseller)') {
        	quo = new Quote(Name='Test_Quote_01', OpportunityId=opty.Id, Channel_Relationship__c=quoteSalesChannel, ContactId=con.Id, Primary_Partner__c=acc02.Id, Distributor__c=acc03.Id, Pricebook2Id=pbook[0].Id);
        } else {
            quo = new Quote(Name='Test_Quote_01', OpportunityId=opty.Id, Channel_Relationship__c=quoteSalesChannel, ContactId=con.Id, Primary_Partner__c=acc02.Id, Pricebook2Id=pbook[0].Id) ;
        }
        insert(quo);
		
                                                     
		//QUOTE ITEM
		QuoteLineItem quoLI = new QuoteLineItem(QuoteId=quo.Id, Product2Id=productList[0].Id, PricebookEntryId=pricebookEntryId, Quantity=1000, UnitPrice=10);
	
		//Set checkRecursive.run to true so trigger is fired in order to calculate discounts
		checkRecursive.run = true;
		insert(quoLI);
		
    
        returnedMap.put('Prod_Tax_Category', productList[0].SFNT_Tax_Catagory_SFDC_Internal__c);
		returnedMap.put('Partner_Rank', [SELECT Primary_Partner_Channel_Rank__c FROM Quote WHERE Id=:quo.Id][0].Primary_Partner_Channel_Rank__c);
		returnedMap.put('New_Cipher_Tier_1_Discount', String.valueOf([SELECT New_Cipher_Tier_1_Discount_Display__c FROM QuoteLineItem WHERE Id=:quoLI.Id].New_Cipher_Tier_1_Discount_Display__c));

        return returnedMap;
    }
}