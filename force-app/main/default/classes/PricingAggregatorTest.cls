@IsTest
public with sharing class PricingAggregatorTest {
	@IsTest
	public static void aggregateCartPricingTest() {
		String discount1 =
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
			'	"customData": {}' +
			'}';
		String discount2 =
			'{' +
			'	"version": "3-1-0",' +
			'	"discountCharge": "__PRODUCT__",' +
			'	"chargeType": "recurring",' +
			'	"discountPrice": "list",' +
			'	"type": "absolute",' +
			'	"amount": 2,' +
			'	"description": "sample discount2",' +
			'	"duration": 0,' +
			'	"recurringOffset": 0,' +
			'	"source": "discount source",' +
			'	"evaluationOrder": "serial",' +
			'	"recordType": "single",' +
			'	"memberDiscounts": null,' +
			'	"customData": {}' +
			'}';
		String discount3 =
			'{' +
			'	"version": "3-1-0",' +
			'	"discountCharge": "__PRODUCT__",' +
			'	"chargeType": "oneOff",' +
			'	"discountPrice": "sales",' +
			'	"type": "absolute",' +
			'	"amount": 3,' +
			'	"description": "sample discount3",' +
			'	"duration": 3,' +
			'	"recurringOffset": 3,' +
			'	"source": "discount source",' +
			'	"evaluationOrder": "serial",' +
			'	"recordType": "single",' +
			'	"memberDiscounts": null,' +
			'	"customData": {}' +
			'}';
		CommonCartWrapper.CommonCart c = new CommonCartWrapper.CommonCart();
		c.customData = new Map<String, String> {
			'customFields' => Json.serialize(
				new Map<String, String> {
					'csdm__discounts__c' => discount1,
					'pre_pricing__c' => '[' +
					String.join(new List<String> { discount2, discount3 }, ',') +
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
		JsonConfigurationService.setPluginConfiguration(PricingAggregator.PRICING_AGGREGATOR, registration);

		Test.startTest();
		List<CommonCartWrapper.Discount> discounts = PricingAggregator.aggregateCartPricing(c);
		Test.stopTest();

		System.assertEquals(3, discounts.size());
		System.assertEquals('sample discount', discounts.get(0).description);
		System.assertEquals('sample discount2', discounts.get(1).description);
		System.assertEquals('sample discount3', discounts.get(2).description);
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
		JsonConfigurationService.setPluginConfiguration(PricingAggregator.PRICING_AGGREGATOR, registration);

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
}
