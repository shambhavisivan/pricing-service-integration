@IsTest
public with sharing class CommonCartWrapperTest {
	private static String createDiscount() {
		return '{' +
			'	"version": "3-1-0",' +
			'	"discountCharge": "__PRODUCT__",' +
			'	"chargeType": "oneOff",' + // 'oneOff', 'recurring'
			'	"discountPrice": "sales",' +
			'	"type": "absolute",' +
			'	"amount": 0,' +
			'	"description": "sample discount description",' +
			'	"duration": 0,' +
			'	"recurringOffset": 0,' +
			'	"source": "discount source",' +
			'	"evaluationOrder": "serial",' +
			'	"recordType": "single",' +
			'	"memberDiscounts": null,' +
			'	"customData": {}' +
			'}';
	}

	@IsTest
	public static void testValidCartVersion300() {
		String cart =
			'{' +
			'	"version": "3-0-0",' +
			'	"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d1",' +
			'	"items": [' +
			'		{' +
			'			"version": "3-0-0",' +
			'			"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d2",' +
			'			"catalogueItemId": "P_P999003",' +
			'			"quantity": 1,' +
			'			"childItems": {},' +
			'			"pricing": {' +
			'				"charges": [],' +
			'				"discounts": [],' +
			'				"listOneOffPrice": 100,' +
			'				"listRecurringPrice": 100,' +
			'				"salesOneOffPrice": 100,' +
			'				"salesRecurringPrice": 100,' +
			'				"totalListOneOffPrice": 100,' +
			'				"totalListRecurringPrice": 100,' +
			'				"totalSalesOneOffPrice": 100,' +
			'				"totalSalesRecurringPrice": 100,' +
			'				"unitListOneOffPrice": 100,' +
			'				"unitListRecurringPrice": 100,' +
			'				"unitSalesOneOffPrice": 100,' +
			'				"unitSalesRecurringPrice": 100' +
			'			}' +
			'		},' +
			'		{' +
			'			"version": "3-0-0",' +
			'			"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d4",' +
			'			"catalogueItemId": "P_P998017",' +
			'			"quantity": 1,' +
			'			"childItems": {},' +
			'			"pricing": {' +
			'				"discounts": [' +
			'					{' +
			'						"evaluationOrder": "parallel",' +
			'						"recordType": "group",' +
			'						"version": "3-0-0",' +
			'						"memberDiscounts": [' +
			'							{' +
			'								"amount": 10,' +
			'								"chargeType": "oneOff",' +
			'								"recordType": "single",' +
			'								"discountCharge": "__PRODUCT__",' +
			'								"discountPrice": "sales",' +
			'								"source": "pr1",' +
			'								"type": "percentage",' +
			'								"version": "3-0-0"' +
			'							},' +
			'							{' +
			'								"amount": 10,' +
			'								"chargeType": "oneOff",' +
			'								"recordType": "single",' +
			'								"discountCharge": "__PRODUCT__",' +
			'								"discountPrice": "sales",' +
			'								"source": "pr2",' +
			'								"type": "absolute",' +
			'								"version": "3-0-0"' +
			'							}' +
			'						]' +
			'					}' +
			'				],' +
			'				"charges": [],' +
			'				"listOneOffPrice": 100,' +
			'				"listRecurringPrice": 100,' +
			'				"salesOneOffPrice": 80,' +
			'				"salesRecurringPrice": 100,' +
			'				"totalListOneOffPrice": 100,' +
			'				"totalListRecurringPrice": 100,' +
			'				"totalSalesOneOffPrice": 80,' +
			'				"totalSalesRecurringPrice": 100,' +
			'				"unitListOneOffPrice": 100,' +
			'				"unitListRecurringPrice": 100,' +
			'				"unitSalesOneOffPrice": 80,' +
			'				"unitSalesRecurringPrice": 100' +
			'			}' +
			'		}' +
			'	],' +
			'	"pricingRuleGroupCodes": [' +
			'		"prg1",' +
			'		"prg2"' +
			'	],' +
			'	"pricing": {' +
			'		"listOneOffPrice": 200,' +
			'		"listRecurringPrice": 200,' +
			'		"salesOneOffPrice": 180,' +
			'		"salesRecurringPrice": 200,' +
			'		"totalListOneOffPrice": 200,' +
			'		"totalListRecurringPrice": 200,' +
			'		"totalSalesOneOffPrice": 180,' +
			'		"totalSalesRecurringPrice": 200,' +
			'		"unitListOneOffPrice": 200,' +
			'		"unitListRecurringPrice": 200,' +
			'		"unitSalesOneOffPrice": 180,' +
			'		"unitSalesRecurringPrice": 200' +
			'	}' +
			'}';

		Test.startTest();
		try {
			CommonCartWrapper.CommonCart cc = (CommonCartWrapper.CommonCart) JSON.deserialize(
				cart,
				CommonCartWrapper.CommonCart.class
			);
			cc.validate();
		} catch (Exception e) {
			System.assert(false, e.getMessage());
		}
		Test.stopTest();
	}

	@IsTest
	public static void testValidCartVersion310() {
		String cart =
			'{' +
			'	"version": "3-1-0",' +
			'	"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d1",' +
			'	"currency": "USD",' +
			'	"items": [' +
			'		{' +
			'			"version": "3-1-0",' +
			'			"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d2",' +
			'			"catalogueItemId": "P_P999003",' +
			'			"quantity": 1,' +
			'			"childItems": {},' +
			'			"pricing": {' +
			'				"charges": [],' +
			'				"discounts": [],' +
			'				"listOneOffPrice": 100,' +
			'				"listRecurringPrice": 100,' +
			'				"salesOneOffPrice": 100,' +
			'				"salesRecurringPrice": 100,' +
			'				"totalListOneOffPrice": 100,' +
			'				"totalListRecurringPrice": 100,' +
			'				"totalSalesOneOffPrice": 100,' +
			'				"totalSalesRecurringPrice": 100,' +
			'				"unitListOneOffPrice": 100,' +
			'				"unitListRecurringPrice": 100,' +
			'				"unitSalesOneOffPrice": 100,' +
			'				"unitSalesRecurringPrice": 100' +
			'			}' +
			'		},' +
			'		{' +
			'			"version": "3-1-0",' +
			'			"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d4",' +
			'			"catalogueItemId": "P_P998017",' +
			'			"quantity": 1,' +
			'			"childItems": {},' +
			'			"pricing": {' +
			'				"discounts": [' +
			'					{' +
			'						"amount": 43,' +
			'						"chargeType": "oneOff",' +
			'						"recordType": "single",' +
			'						"discountCharge": "pet1",' +
			'						"source": "pr9",' +
			'						"type": "init",' +
			'						"version": "3-1-0"' +
			'					}' +
			'				],' +
			'				"charges": [' +
			'					{' +
			'						"chargeType": "oneOff",' +
			'						"listPrice": 43,' +
			'						"salesPrice": 43,' +
			'						"source": "pr9",' +
			'						"name": "pet1",' +
			'						"description": "charge description",' +
			'						"version": "1-0-0"' +
			'					}' +
			'				],' +
			'				"listOneOffPrice": 143,' +
			'				"listRecurringPrice": 100,' +
			'				"salesOneOffPrice": 143,' +
			'				"salesRecurringPrice": 100,' +
			'				"totalListOneOffPrice": 143,' +
			'				"totalListRecurringPrice": 100,' +
			'				"totalSalesOneOffPrice": 143,' +
			'				"totalSalesRecurringPrice": 100,' +
			'				"unitListOneOffPrice": 143,' +
			'				"unitListRecurringPrice": 100,' +
			'				"unitSalesOneOffPrice": 143,' +
			'				"unitSalesRecurringPrice": 100' +
			'			}' +
			'		}' +
			'	],' +
			'	"pricingRuleGroupCodes": [' +
			'		"prg10"' +
			'	],' +
			'	"pricing": {' +
			'		"listOneOffPrice": 243,' +
			'		"listRecurringPrice": 200,' +
			'		"salesOneOffPrice": 243,' +
			'		"salesRecurringPrice": 200,' +
			'		"totalListOneOffPrice": 243,' +
			'		"totalListRecurringPrice": 200,' +
			'		"totalSalesOneOffPrice": 243,' +
			'		"totalSalesRecurringPrice": 200,' +
			'		"unitListOneOffPrice": 243,' +
			'		"unitListRecurringPrice": 200,' +
			'		"unitSalesOneOffPrice": 243,' +
			'		"unitSalesRecurringPrice": 200' +
			'	}' +
			'}';

		Test.startTest();
		try {
			CommonCartWrapper.CommonCart cc = (CommonCartWrapper.CommonCart) JSON.deserialize(
				cart,
				CommonCartWrapper.CommonCart.class
			);
			cc.validate();
		} catch (Exception e) {
			System.assert(false, e.getMessage());
		}
		Test.stopTest();
	}

	@IsTest
	public static void testCartVersion310InvalidDiscountPropertyValues() {
		String discount = createDiscount();
		CommonCartWrapper.Discount d = (CommonCartWrapper.Discount) JSON.deserialize(
			discount,
			CommonCartWrapper.Discount.class
		);

		Test.startTest();
		try {
			d.chargeType = 'invalid charge type';
			d.validate();
		} catch (Exception e) {
			System.assertEquals(
				'Invalid Discount value: "invalid charge type" supplied for: "chargeType". Accepted values are: "oneOff", "recurring", ""',
				e.getMessage()
			);
		} finally {
			d.chargeType = 'oneOff';
		}

		try {
			d.discountPrice = 'invalid discount price';
			d.validate();
		} catch (Exception e) {
			System.assertEquals(
				'Invalid Discount value: "invalid discount price" supplied for: "discountPrice". Accepted values are: "list", "sales", ""',
				e.getMessage()
			);
		} finally {
			d.discountPrice = 'sales';
		}

		try {
			d.type = 'invalid type';
			d.validate();
		} catch (Exception e) {
			System.assertEquals(
				'Invalid Discount value: "invalid type" supplied for: "type". Accepted values are: "absolute", "percentage", "override", "init", ""',
				e.getMessage()
			);
		} finally {
			d.type = 'absolute';
		}

		try {
			d.evaluationOrder = 'invalid evaluation order';
			d.validate();
		} catch (Exception e) {
			System.assertEquals(
				'Invalid Discount value: "invalid evaluation order" supplied for: "evaluationOrder". Accepted values are: "serial", "parallel", ""',
				e.getMessage()
			);
		} finally {
			d.evaluationOrder = 'serial';
		}

		try {
			d.recordType = 'invalid record type';
			d.validate();
		} catch (Exception e) {
			System.assertEquals(
				'Invalid Discount value: "invalid record type" supplied for: "recordType". Accepted values are: "single", "group"',
				e.getMessage()
			);
		} finally {
			d.recordType = 'single';
		}
		Test.stopTest();
	}

	@IsTest
	public static void testCartVersion320PricingServiceCart() {
		String preCart =
			'{' +
			'	"version": "3-2-0",' +
			'	"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d1",' +
			'	"currency": "HRK",' +
			'	"items": [' +
			'		{' +
			'			"version": "3-1-0",' +
			'			"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d2",' +
			'			"catalogueItemId": "P_P999003",' +
			'			"quantity": 1,' +
			'			"childItems": {},' +
			'			"pricing": {' +
			'				"charges": [],' +
			'				"discounts": [],' +
			'				"listOneOffPrice": 100,' +
			'				"listRecurringPrice": 100,' +
			'				"salesOneOffPrice": 100,' +
			'				"salesRecurringPrice": 100,' +
			'				"totalListOneOffPrice": 100,' +
			'				"totalListRecurringPrice": 100,' +
			'				"totalSalesOneOffPrice": 100,' +
			'				"totalSalesRecurringPrice": 100,' +
			'				"unitListOneOffPrice": 100,' +
			'				"unitListRecurringPrice": 100,' +
			'				"unitSalesOneOffPrice": 100,' +
			'				"unitSalesRecurringPrice": 100' +
			'			},' +
			'			"attributes": [' +
			'				{' +
			'					"id": "attr1",' +
			'				"name": "testAttribute"' +
			'				}' +
			'			]' +
			'		},' +
			'		{' +
			'			"version": "3-1-0",' +
			'			"id": "b62bbf9e-5154-4e7c-92a6-5c947ebde0d4",' +
			'			"catalogueItemId": "P_P998017",' +
			'			"quantity": 1,' +
			'			"childItems": {},' +
			'			"pricing": {' +
			'				"charges": [],' +
			'				"discounts": [],' +
			'				"listOneOffPrice": 100,' +
			'				"listRecurringPrice": 100,' +
			'				"salesOneOffPrice": 100,' +
			'				"salesRecurringPrice": 100,' +
			'				"totalListOneOffPrice": 100,' +
			'				"totalListRecurringPrice": 100,' +
			'				"totalSalesOneOffPrice": 100,' +
			'				"totalSalesRecurringPrice": 100,' +
			'				"unitListOneOffPrice": 100,' +
			'				"unitListRecurringPrice": 100,' +
			'				"unitSalesOneOffPrice": 100,' +
			'				"unitSalesRecurringPrice": 100' +
			'			},' +
			'			"associatedCartItems": {' +
			'				"testAssociation": [' +
			'					"b62bbf9e-5154-4e7c-92a6-5c947ebde0d2"' +
			'				]' +
			'			}' +
			'		},' +
			'		{' +
			'			"version": "3-1-0",' +
			'			"id": "00665c4d-a2b4-49ac-b7ef-dff67aa356e0",' +
			'			"catalogueItemId": "P_P998017",' +
			'			"quantity": 2,' +
			'			"childItems": {},' +
			'			"pricing": {' +
			'				"charges": [],' +
			'				"discounts": [],' +
			'				"listOneOffPrice": 100,' +
			'				"listRecurringPrice": 100,' +
			'				"salesOneOffPrice": 100,' +
			'				"salesRecurringPrice": 100,' +
			'				"totalListOneOffPrice": 200,' +
			'				"totalListRecurringPrice": 200,' +
			'				"totalSalesOneOffPrice": 200,' +
			'				"totalSalesRecurringPrice": 200,' +
			'				"unitListOneOffPrice": 100,' +
			'				"unitListRecurringPrice": 100,' +
			'				"unitSalesOneOffPrice": 100,' +
			'				"unitSalesRecurringPrice": 100' +
			'			}' +
			'		},' +
			'		{' +
			'			"version": "3-1-0",' +
			'			"id": "02aa5cf6-5104-4e88-b66b-119be640bbf1",' +
			'			"catalogueItemId": "P_P998017",' +
			'			"quantity": 3,' +
			'			"childItems": {},' +
			'			"pricing": {' +
			'				"discounts": [' +
			'					{' +
			'						"amount": 777,' +
			'						"chargeType": "oneOff",' +
			'						"discountCharge": "__PRODUCT__",' +
			'						"discountPrice": "sales",' +
			'						"recordType": "single",' +
			'						"source": "pr10",' +
			'						"type": "override",' +
			'						"version": "3-1-0"' +
			'					}' +
			'				],' +
			'				"charges": [],' +
			'				"listOneOffPrice": 100,' +
			'				"listRecurringPrice": 100,' +
			'				"salesOneOffPrice": 777,' +
			'				"salesRecurringPrice": 100,' +
			'				"totalListOneOffPrice": 300,' +
			'				"totalListRecurringPrice": 300,' +
			'				"totalSalesOneOffPrice": 2331,' +
			'				"totalSalesRecurringPrice": 300,' +
			'				"unitListOneOffPrice": 100,' +
			'				"unitListRecurringPrice": 100,' +
			'				"unitSalesOneOffPrice": 777,' +
			'				"unitSalesRecurringPrice": 100' +
			'			},' +
			'			"associatedCartItems": {' +
			'				"testAssociation": [' +
			'					"b62bbf9e-5154-4e7c-92a6-5c947ebde0d2"' +
			'				]' +
			'			}' +
			'		}' +
			'	],' +
			'	"pricingRuleGroupCodes": [' +
			'		"prg11"' +
			'	],' +
			'	"pricing": {' +
			'		"listOneOffPrice": 700,' +
			'		"listRecurringPrice": 700,' +
			'		"salesOneOffPrice": 2731,' +
			'		"salesRecurringPrice": 700,' +
			'		"totalListOneOffPrice": 700,' +
			'		"totalListRecurringPrice": 700,' +
			'		"totalSalesOneOffPrice": 2731,' +
			'		"totalSalesRecurringPrice": 700,' +
			'		"unitListOneOffPrice": 700,' +
			'		"unitListRecurringPrice": 700,' +
			'		"unitSalesOneOffPrice": 2731,' +
			'		"unitSalesRecurringPrice": 700' +
			'	}' +
			'}';

		Test.startTest();
		try {
			CommonCartWrapper.CommonCart cc = (CommonCartWrapper.CommonCart) JSON.deserialize(
				preCart,
				CommonCartWrapper.CommonCart.class
			);
			cc.validate();
		} catch (Exception e) {
			System.assert(false, e.getMessage());
		}
		Test.stopTest();
	}
}
