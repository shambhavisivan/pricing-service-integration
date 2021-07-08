public with sharing class MockObjects {
	public static final String DISCOUNT_1 =
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

	public static final String DISCOUNT_2 =
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

	public static final String DISCOUNT_3 =
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
}
