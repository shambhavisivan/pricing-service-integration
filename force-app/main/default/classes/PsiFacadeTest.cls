@IsTest
public with sharing class PsiFacadeTest {
	@TestSetup
	private static void testSetup() {
		// setup prgs
		// register a plugin
		PrgSelectorRegistration selector = new PrgSelectorRegistration();
		selector.className = PrgSelectorTest.TestPrgSelector.class.getName();
		selector.version = '1-0-0';

		JsonConfigurationService.setPluginConfiguration(PrgSelector.PRG_SELECTORS + '/1', selector);

		// setup pricing aggregator
		// register the plugin
		PricingAggregatorRegistration registration = new PricingAggregatorRegistration();
		registration.version = '1-0-0';
		registration.cartFields = new List<String> { 'customData.customFields!csdm__discounts__c' };
		registration.cartItemFields = new List<String> { 'customData.customFields!pre_pricing__c' };
		JsonConfigurationService.setPluginConfiguration(PricingAggregator.PRICING_AGGREGATOR_NAMESPACE, registration);
	}

	@IsTest
	public static void testSelectPrgs() {
		PsiFacade.PrgSelectorV1 prgSelector = new PsiFacade.PrgSelectorV1();
		RestRequest request = new RestRequest();
		request.requestBody = Blob.valueOf(
			'{ "salesAppId": "external-app", "user": null, "basketId": "sample-basket-id", "salesContext": null }'
		);
		RestResponse response = new RestResponse();

		Test.startTest();
		prgSelector.doPost(request, response, new Map<String, String>());
		Test.stopTest();

		System.assertEquals(200, response.statusCode);
		System.assertEquals('["test-prg"]', response.responseBody.toString());
	}

	@IsTest
	public static void testGetPricingAggregatorConfiguration() {
		PsiFacade.PricingAggregatorV1 pricingAggregator = new PsiFacade.PricingAggregatorV1();
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		Test.startTest();
		pricingAggregator.doGet(request, response, new Map<String, String>());
		Test.stopTest();

		System.assertEquals(200, response.statusCode);
		System.assertEquals(
			'{"version":"1-0-0","cartItemFields":["customData.customFields!pre_pricing__c"],"cartFields":["customData.customFields!csdm__discounts__c"]}',
			response.responseBody.toString()
		);
	}
}
