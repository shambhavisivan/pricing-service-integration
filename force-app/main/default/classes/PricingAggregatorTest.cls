@IsTest
public with sharing class PricingAggregatorTest {
	@IsTest
	public static void aggregateCartPricingTest() {
		CommonCartWrapper.CommonCart c = new CommonCartWrapper.CommonCart();
		c.customData = new Map<String, String> {
			'customFields' => Json.serialize(
				new Map<String, String> {
					'csdm__discounts__c' => MockObjects.DISCOUNT_1,
					'pre_pricing__c' => '[' +
					String.join(new List<String> { MockObjects.DISCOUNT_2, MockObjects.DISCOUNT_3 }, ',') +
					']'
				}
			)
		};

		// register the plugin
		PricingAggregatorRegistration registration = new PricingAggregatorRegistration();
		registration.version = '1-0-0';
		registration.cartFields = new List<String> {
			'customData.customFields!csdm__discounts__c',
			'customData.customFields!pre_pricing__c'
		};
		registration.cartItemFields = new List<String>();
		JsonConfigurationService.setPluginConfiguration(PricingAggregator.PRICING_AGGREGATOR_NAMESPACE, registration);

		Test.startTest();
		List<CommonCartWrapper.Discount> discounts = PricingAggregator.aggregateCartPricing(c);
		Test.stopTest();

		System.assertEquals(3, discounts.size());
		System.assertEquals('sample discount', discounts.get(0).description);
		System.assertEquals('sample discount2', discounts.get(1).description);
		System.assertEquals('sample discount3', discounts.get(2).description);
	}

	@IsTest
	public static void aggregateCartItemPricingDeepTest() {
		CommonCartWrapper.CartItemV2 ci = new CommonCartWrapper.CartItemV2();
		ci.id = 'cartitem-1';
		ci.version = CommonCartWrapper.VERSION_3_1_0;
		ci.customData = new Map<String, String>{
			'customFields' => Json.serialize(new Map<String, String>{ 'csdm__discounts__c' => MockObjects.DISCOUNT_1 })
		};
		ci.pricing = new CommonCartWrapper.Pricing();

		List<CommonCartWrapper.CartItemV2> childItems = new List<CommonCartWrapper.CartItemV2>();

		CommonCartWrapper.CartItemV2 child1 = new CommonCartWrapper.CartItemV2();
		child1.id = 'childitem-1';
		child1.version = CommonCartWrapper.VERSION_3_1_0;
		child1.customData = new Map<String, String>{
			'customFields' => Json.serialize(new Map<String, String>{ 'csdm__discounts__c' => MockObjects.DISCOUNT_2 })
		};
		child1.pricing = new CommonCartWrapper.Pricing();

		CommonCartWrapper.CartItemV2 child2 = new CommonCartWrapper.CartItemV2();
		child2.id = 'childitem-2';
		child2.version = CommonCartWrapper.VERSION_3_1_0;
		child2.customData = new Map<String, String>{
			'customFields' => Json.serialize(new Map<String, String>{ 'csdm__discounts__c' => MockObjects.DISCOUNT_3 })
		};
		child2.pricing = new CommonCartWrapper.Pricing();

		ci.childItems = new Map<String, List<CommonCartWrapper.CartItemV2>>{
			'relatedProducts' => new List<CommonCartWrapper.CartItemV2>{ child1, child2 }
		};

		// register the plugin
		PricingAggregatorRegistration registration = new PricingAggregatorRegistration();
		registration.version = '1-0-0';
		registration.cartItemFields = new List<String>{ 'customData.customFields!csdm__discounts__c' };
		registration.cartFields = new List<String>();
		JsonConfigurationService.setPluginConfiguration(PricingAggregator.PRICING_AGGREGATOR_NAMESPACE, registration);

		Test.startTest();
		CommonCartWrapper.CartItemV2 cartItemWithDiscounts = PricingAggregator.aggregateCartItemPricingDeep(ci);
		Test.stopTest();

		System.assertEquals(1, cartItemWithDiscounts.pricing.discounts.size());
		System.assertEquals('sample discount', cartItemWithDiscounts.pricing.discounts.get(0).description);

		List<CommonCartWrapper.CartItemV2> childItemsWithDiscounts = cartItemWithDiscounts.childItems.get(
			'relatedProducts'
		);

		System.assertEquals(1, childItemsWithDiscounts.get(0).pricing.discounts.size());
		System.assertEquals('sample discount2', childItemsWithDiscounts.get(0).pricing.discounts.get(0).description);

		System.assertEquals(1, childItemsWithDiscounts.get(1).pricing.discounts.size());
		System.assertEquals('sample discount3', childItemsWithDiscounts.get(1).pricing.discounts.get(0).description);
	}

	@IsTest
	public static void aggregateCartPricingInvalidDiscountsJsonTest() {
		String invalidJson =
			'{' +
			'	"version": "3-1-0",' +
			'	"discountCharge": "__PRODUCT__",' +
			'	"chargeType": "oneOff",' +
			'	"discountPrice": "sales",' +
			'	"type": "absolute",' +
			'	"amount": 1,' +
			'	"description": "sample discount",' +
			'	"duration": 0,' +
			'	"recurringOffset": 0,' +
			'	"source": "discount source",' +
			'	"evaluationOrder": "serial",' +
			'	"recordType": "single",' +
			'	"memberDiscounts": null,' +
			'	"customData": {},' + // extra comma should break deserialisation
			'}';

		CommonCartWrapper.CommonCart c = new CommonCartWrapper.CommonCart();
		c.id = 'cart-id';
		c.customData = new Map<String, String> {
			'customFields' => Json.serialize(new Map<String, String> { 'csdm__discounts__c' => invalidJson })
		};

		// register the plugin
		PricingAggregatorRegistration registration = new PricingAggregatorRegistration();
		registration.version = '1-0-0';
		registration.cartFields = new List<String> { 'customData.customFields!csdm__discounts__c' };
		registration.cartItemFields = new List<String>();
		JsonConfigurationService.setPluginConfiguration(PricingAggregator.PRICING_AGGREGATOR_NAMESPACE, registration);

		Test.startTest();
		try {
			List<CommonCartWrapper.Discount> discounts = PricingAggregator.aggregateCartPricing(c);
		} catch (PsiException.DeserializationException e) {
			System.assertEquals(
				'Error parsing discounts json value for expression: customData.customFields!csdm__discounts__c in item with Id: cart-id Unexpected character (\'}\' (code 125)): was expecting double-quote to start field name at [line:1, column:335]',
				e.getMessage()
			);
		}
		Test.stopTest();
	}

	@IsTest
	public static void multiplePluginRegistrationsTest() {
		// register multiple plugins
		PricingAggregatorRegistration registration1 = new PricingAggregatorRegistration();
		registration1.version = '1-0-0';
		registration1.cartFields = new List<String> { 'customData.customFields!cart_field' };
		registration1.cartItemFields = new List<String>();
		JsonConfigurationService.setPluginConfiguration(
			PricingAggregator.PRICING_AGGREGATOR_NAMESPACE + '/Discounts',
			registration1
		);

		PricingAggregatorRegistration registration2 = new PricingAggregatorRegistration();
		registration2.version = '1-0-0';
		registration2.cartFields = new List<String> { 'customData.customFields!another_cart_field' };
		registration2.cartItemFields = new List<String> { 'customData.customFields!another_cart_item_field' };
		JsonConfigurationService.setPluginConfiguration(
			PricingAggregator.PRICING_AGGREGATOR_NAMESPACE + '/Pricing',
			registration2
		);

		PricingAggregatorRegistration registration3 = new PricingAggregatorRegistration();
		registration3.version = '1-0-0';
		registration3.cartFields = new List<String>();
		registration3.cartItemFields = new List<String> { 'customData.customFields!cart_item_field' };
		JsonConfigurationService.setPluginConfiguration(
			PricingAggregator.PRICING_AGGREGATOR_NAMESPACE + '/OtherSource',
			registration3
		);

		Test.startTest();
		PricingAggregatorRegistration mergedConfiguration = PricingAggregator.getPluginConfiguration();
		Test.stopTest();

		System.assertEquals(
			new List<String> { 'customData.customFields!cart_field', 'customData.customFields!another_cart_field' },
			mergedConfiguration.cartFields
		);
		System.assertEquals(
			new List<String> {
				'customData.customFields!cart_item_field',
				'customData.customFields!another_cart_item_field'
			},
			mergedConfiguration.cartItemFields
		);
	}

	@IsTest
	public static void evaluateExpressionTest() {
		CommonCartWrapper.CommonCart c = new CommonCartWrapper.CommonCart();
		c.customData = new Map<String, String> {
			'customFields' => Json.serialize(
				new Map<String, String> {
					'csdm__discounts__c' => Json.serialize(new Map<String, String> { 'prop1' => 'val1' })
				}
			)
		};

		String expression = 'customData.customFields!csdm__discounts__c';

		Test.startTest();
		String actualValue = PricingAggregator.evaluateExpression(expression, c);
		Test.stopTest();

		String expected = '{"prop1":"val1"}';
		System.assertEquals(expected, actualValue);
	}

	@IsTest
	public static void validateTest() {
		try {
			PricingAggregator.validateExpression('a.b.');
			System.assert(
				false,
				'Default implementation of PricingAggregator.validateExpression should throw exception upon invocation if an invalid expression is encountered.'
			);
		} catch (PsiException.InvalidExpressionException e) {
			System.assertEquals('Invalid expression format: a.b.', e.getMessage());
		}

		try {
			PricingAggregator.validateExpression('.a.b');
			System.assert(
				false,
				'Default implementation of PricingAggregator.validateExpression should throw exception upon invocation if an invalid expression is encountered.'
			);
		} catch (PsiException.InvalidExpressionException e) {
			System.assertEquals('Invalid expression format: .a.b', e.getMessage());
		}

		try {
			PricingAggregator.validateExpression('c.d.e!');
			System.assert(
				false,
				'Default implementation of PricingAggregator.validateExpression should throw exception upon invocation if an invalid expression is encountered.'
			);
		} catch (PsiException.InvalidExpressionException e) {
			System.assertEquals('Invalid expression format: c.d.e!', e.getMessage());
		}

		try {
			PricingAggregator.validateExpression('!c.d.e');
			System.assert(
				false,
				'Default implementation of PricingAggregator.validateExpression should throw exception upon invocation if an invalid expression is encountered.'
			);
		} catch (PsiException.InvalidExpressionException e) {
			System.assertEquals('Invalid expression format: !c.d.e', e.getMessage());
		}

		try {
			PricingAggregator.validateExpression('f.g..h');
			System.assert(
				false,
				'Default implementation of PricingAggregator.validateExpression should throw exception upon invocation if an invalid expression is encountered.'
			);
		} catch (PsiException.InvalidExpressionException e) {
			System.assertEquals('Invalid expression format: f.g..h', e.getMessage());
		}

		try {
			PricingAggregator.validateExpression('f.g.h!!i.j.k');
			System.assert(
				false,
				'Default implementation of PricingAggregator.validateExpression should throw exception upon invocation if an invalid expression is encountered.'
			);
		} catch (PsiException.InvalidExpressionException e) {
			System.assertEquals('Invalid expression format: f.g.h!!i.j.k', e.getMessage());
		}
	}

	@IsTest
	public static void tokenizeTest() {
		System.assertEquals(new List<String> { 'a', '.', 'b', '!', 'c' }, PricingAggregator.tokenize('a.b!c'));
		System.assertEquals(
			new List<String> { 'a', '.', 'b', '.', 'c', '.', 'd', '.', 'e', '.', 'f' },
			PricingAggregator.tokenize('a.b.c.d.e.f')
		);
		System.assertEquals(
			new List<String> { 'a', '!', 'b', '!', 'c', '!', 'd', '!', 'e', '!', 'f' },
			PricingAggregator.tokenize('a!b!c!d!e!f')
		);
		System.assertEquals(
			new List<String> { 'a', '!', 'b', '.', 'c', '!', 'd', '!', 'e', '.', 'f' },
			PricingAggregator.tokenize('a!b.c!d!e.f')
		);
		System.assertEquals(
			new List<String> { 'customData', '.', 'customFields', '!', 'csdm__discounts__c' },
			PricingAggregator.tokenize('customData.customFields!csdm__discounts__c')
		);
	}

	@IsTest
	public static void getRegisteredCartFieldsTest() {
		// prepare sample data 1
		createPsiData('SalesApp1', 'csdiscounts__DLM_cartfield__c', '');
		// prepare sample data 2
		createPsiData('SalesApp2', 'cssalesapp2__SA2_cartfield__c', '');

		List<String> expectedData = new List<String> {
			'customData.customFields!csdiscounts__DLM_cartfield__c',
			'customData.customFields!cssalesapp2__SA2_cartfield__c'
		};

		Test.startTest();
		List<String> actualCartFields = PricingAggregator.getRegisteredCartFields();
		Test.stopTest();

		System.assertEquals(expectedData, actualCartFields);
	}

	@IsTest
	public static void getRegisteredCartItemFieldsTest() {
		// prepare sample data 1
		createPsiData('SalesApp1', '', 'csdiscounts__manual_discounts__c');
		// prepare sample data 2
		createPsiData('SalesApp2', '', 'cssalesapp2__salesapp2_discounts__c');

		List<String> expectedData = new List<String> {
			'customData.customFields!csdiscounts__manual_discounts__c',
			'customData.customFields!cssalesapp2__salesapp2_discounts__c'
		};

		Test.startTest();
		List<String> actualCartItemFields = PricingAggregator.getRegisteredCartItemFields();
		Test.stopTest();

		System.assertEquals(expectedData, actualCartItemFields);
	}

	@IsTest
	public static void registerPricingAggregatorTest() {
		// prepare sample data
		final String pricingAggregatorName = 'SalesApp1';
		PricingAggregatorRegistration psiRegistration = setTestPlg(
			'csdiscounts__SA1_cartfield__c',
			'csdiscounts__manual_discounts__c'
		);

		Test.startTest();
		PricingAggregator.registerPricingAggregator(
			pricingAggregatorName,
			psiRegistration
		);
		Test.stopTest();

		String settingName = PricingAggregator.PRICING_AGGREGATOR_NAMESPACE + '/' + pricingAggregatorName;
		csutil__Json_Settings__c setting = [
			select id,name,csutil__json_configuration__c
			from csutil__Json_Settings__c
			where name = :settingName
		];

		PricingAggregatorRegistration regActual = (PricingAggregatorRegistration) Json.deserialize(
			setting.csutil__json_configuration__c, PricingAggregatorRegistration.class
		);
		List<String> cartFieldsExpected = new List<String> {'customData.customFields!csdiscounts__SA1_cartfield__c'};
		List<String> cartItemFieldsExpected = new List<String> {'customData.customFields!csdiscounts__manual_discounts__c'};

		System.assertEquals(settingName, setting.name);
		System.assertEquals(cartFieldsExpected, regActual.cartFields);
		System.assertEquals(cartItemFieldsExpected, regActual.cartItemFields);
	}

	@IsTest
	public static void deletePricingAggregatorTest() {
		// prepare sample data
		final String name = 'SalesApp3' ;
		createPsiData(name, 'SalesApp3__SA3_cartfield__c', 'SalesApp3__manual_discounts__c');

		Test.startTest();
		PricingAggregator.deletePricingAggregator(name);
		Test.stopTest();

		List<PricingAggregatorRegistration> ob = (List<PricingAggregatorRegistration>)  JsonConfigurationService.getPluginConfigurations(name, PricingAggregatorRegistration.class);

		System.assertEquals(0, ob.size());
	}

	public static void createPsiData(String name, String cartField, String cartItemField) {
		PricingAggregatorRegistration psiRegistration = setTestPlg(
			cartField, cartItemField
		);
		JsonConfigurationService.setPluginConfiguration(
			PricingAggregator.PRICING_AGGREGATOR_NAMESPACE + '/' + name,
			psiRegistration
		);
	}

	public static PricingAggregatorRegistration setTestPlg(String cartField, String cartItemField) {

		PricingAggregatorRegistration psiRegistration = new PricingAggregatorRegistration();
		psiRegistration.version = '1-0-0';

		if (!String.isBlank(cartField)) {
			psiRegistration.cartFields = new List<String> { 'customData.customFields!' + cartField };
		}
		if (!String.isBlank(cartItemField)) {
			psiRegistration.cartItemFields = new List<String> { 'customData.customFields!' + cartItemField };
		}
		return psiRegistration;
	}
}