global with sharing class CommonCartWrapper {
	public static final String VERSION_1_0_0 = '1-0-0';
	public static final String VERSION_2_0_0 = '2-0-0';
	public static final String VERSION_3_0_0 = '3-0-0';
	public static final String VERSION_3_1_0 = '3-1-0';
	public static final String VERSION_3_2_0 = '3-2-0';

	public static final List<String> ALL_VERSIONS = new List<String>{
		VERSION_1_0_0,
		VERSION_2_0_0,
		VERSION_3_0_0,
		VERSION_3_1_0,
		VERSION_3_2_0
	};

	private static final String[] CHARGE_TYPE = new List<String>{ 'oneOff', 'recurring' };
	private static final String[] CHARGE_TYPE_OPTIONAL = new List<String>{ 'oneOff', 'recurring', null };

	private static final String[] DISCOUNT_TYPE = new List<String>{ 'absolute', 'percentage', 'override', 'init' };
	private static final String[] DISCOUNT_TYPE_OPTIONAL = new List<String>{
		'absolute',
		'percentage',
		'override',
		'init',
		null
	};

	private static final String[] DISCOUNT_TYPE_100 = new List<String>{ 'absolute', 'percentage', 'override' };
	private static final String[] DISCOUNT_TYPE_OPTIONAL_100 = new List<String>{
		'absolute',
		'percentage',
		'override',
		null
	};

	private static final String[] PRICE_TYPE = new List<String>{ 'list', 'sales' };
	private static final String[] PRICE_TYPE_OPTIONAL = new List<String>{ 'list', 'sales', null };

	private static final String[] EVALUATION_ORDER = new List<String>{ 'serial', 'parallel' };
	private static final String[] EVALUATION_ORDER_OPTIONAL = new List<String>{ 'serial', 'parallel', null };

	private static final String[] RECORD_TYPE = new List<String>{ 'single', 'group' };

	private static Boolean isVersionEqualTo(String version, String equalTo) {
		if (version != null && equalTo != null && version.compareTo(equalTo) == 0) {
			return true;
		}

		return false;
	}

	private static Boolean isVersionLessThan(String version, String lessThan) {
		if (version != null && lessThan != null && version.compareTo(lessThan) == -1) {
			return true;
		}

		return false;
	}

	private static Boolean isVersionGreaterThan(String version, String greaterThan) {
		if (version != null && greaterThan != null && version.compareTo(greaterThan) == 1) {
			return true;
		}

		return false;
	}

	private static String validateVersion(String objectName, String value, String[] validVersions) {
		if (validVersions.contains(value)) {
			return value;
		} else {
			throw new PSIException('Invalid ' + objectName + ' version value: ' + value);
		}
	}

	private static Decimal require(String objName, String key, Decimal value) {
		if (value == null) {
			throw new PsiException('Missing required ' + objName + ' value: ' + key);
		}

		return value;
	}

	private static String require(String objName, String key, String value) {
		if (value == null || String.isBlank(value)) {
			throw new PsiException('Missing required ' + objName + ' value: ' + key);
		}

		return value;
	}

	private static String constrainValue(String objName, String key, String value, List<String> acceptedValues) {
		if (!acceptedValues.contains(value)) {
			throw new PsiException(
				String.format(
					'Invalid {0} value: "{1}" supplied for: "{2}". Accepted values are: "{3}"',
					new List<Object>{ objName, value, key, String.join(acceptedValues, '", "') }
				)
			);
		}

		return value;
	}

	global interface Validateable {
		void validate();
	}

	global with sharing class CommonCart implements Validateable {
		/**
		 * API version of the Cart structure
		 */
		global String version { get; set; }
		global String id { get; set; }
		global CartItem[] items { get; set; }
		global CartItem[] holdings { get; set; }
		global Pricing pricing { get; set; }
		/**
		 * A dictionary where keys represent IDs of shared data items and values are JSON serialised data that can be used by Cart Items to drive cross-product business logic.
		 */
		global Map<String, String> sharedData { get; set; }

		/**
		 * ISO 4217 currency code used for all monetary values in the Cart.
		 */
		// TODO: the currency is a reserved keyword and as such cannot be used inside apex classes for variable names.
		// This needs to be addressed in a way that it can be used through apex.

		// global String currency { get; set; }

		global String[] pricingRuleGroupCodes { get; set; }
		global Map<String, String> customData { get; set; }
		global Map<String, String> externalIds { get; set; }

		global void validate() {
			validateVersion(
				'CommonCart',
				this.version,
				new List<String>{ VERSION_1_0_0, VERSION_2_0_0, VERSION_3_0_0, VERSION_3_1_0, VERSION_3_2_0 }
			);

			require('CommonCart', 'version', this.version);
			require('CommonCart', 'id', this.id);

			if (isVersionLessThan(this.version, VERSION_3_2_0)) {
				if (holdings != null) {
					throw new PsiException(
						'Property "holdings" does not exist prior to common cart version ' +
						VERSION_3_2_0 +
						'.'
					);
				}
			}

			if (this.items != null) {
				for (CartItem ci : this.items) {
					if (ci != null) {
						ci.validate();
					}
				}
			}
			if (pricing != null) {
				pricing.validate();
			}
		}
	}

	global with sharing class CartItem implements Validateable {
		/**
		 * API version of the CartItem structure
		 */
		global String version { get; set; }
		/**
		 * The ID of the cart item in the cart.
		 */
		global String id { get; set; }
		/**
		 * The ID of the catalogue item that this cart item is an instance of.
		 */
		global String catalogueItemId { get; set; }
		global Attribute[] attributes { get; set; }
		/**
		 * A dictionary where keys represent names of child slots and values represent collections of child Cart Items. Children are hierarchically under the parent Cart Item and their pricing is added into the parent pricing. Child Cart Items are better known as related products in the Configurator terminology, but that term may be confusing in the wider landscape of services.
		 */
		global Map<String, CartItem> childItems { get; set; }
		/**
		 * A dictionary where keys represent names of associations and values represent collections of associated Cart Items. Cart Items can be associated for various purposes - see the Order Enrichment EAR for use cases. Pricing info does not interact automatically between associated items.
		 */
		global Map<String, String[]> associatedCartItems { get; set; }
		/**
		 * A dictionary where keys represent names of associations and values are collections of IDs to Cart-level Shared Data objects.
		 */
		global Map<String, String[]> associatedSharedData { get; set; }
		/**
		 * The sequential number of this item in the container (parent cart item or cart)
		 */
		global Integer sequence { get; set; }
		/**
		 * The number of units within the container, of the product being purchased.
		 */
		global Integer quantity { get; set; }
		global Pricing pricing { get; set; }
		/**
		 * The number of times a year recurring prices are charged. E.g. 1 means once a year and 12 means 12 times a year (monthly). This field is only allowed and it is required on the root Cart Item. On add-ons it is always inherited from the root.
		 */
		global Integer recurrenceFrequency { get; set; }
		/**
		 * The number of recurrence periods (year/recurrenceFrequency time units) that the contract lasts.This field is only allowed on the root Cart Item. On add-ons it is always inherited from the root.
		 */
		global Integer contractTerm { get; set; }
		global Map<String, String> customData { get; set; }
		global Map<String, String> externalIds { get; set; }

		global void validate() {
			validateVersion(
				'CartItem',
				this.version,
				new List<String>{ VERSION_1_0_0, VERSION_2_0_0, VERSION_3_0_0, VERSION_3_1_0 }
			);

			require('CartItem', 'version', this.version);
			require('CartItem', 'id', this.id);

			if (this.attributes != null) {
				for (Attribute a : this.attributes) {
					if (a != null) {
						a.validate();
					}
				}
			}

			if (pricing != null) {
				pricing.validate();
			}
		}
	}

	global with sharing class Attribute implements Validateable {
		/**
		 * The ID of the attribute.
		 */
		global String id { get; set; }
		/**
		 * Name of the attribute - must be unique within the containing Cart Item
		 */
		global String name { get; set; }
		/**
		 * The normalised value for the attribute. Normalised means that: - date values must be encoded using ISO-8601 - decimal numbers must use the dot (.) as decimal separator and must not use a thousands separator
		 */
		global String value { get; set; }
		global Map<String, String> attributeFields { get; set; }
		global Map<String, String> customData { get; set; }
		global Map<String, String> externalIds { get; set; }

		global void validate() {
			require('Attribute', 'id', this.id);
			require('Attribute', 'name', this.name);
		}
	}

	global with sharing class Pricing implements Validateable {
		global Charge[] charges { get; set; }
		global Discount[] discounts { get; set; }
		/**
		 * Sum of internal list prices for one-off charges for a single unit of the product. Does not include prices for down-hierarchy priceables.
		 */
		global Decimal listOneOffPrice { get; set; }
		/**
		 * Sum of internal sales prices for one-off charges for a single unit of the product. Does not include prices for down-hierarchy priceables.
		 */
		global Decimal salesOneOffPrice { get; set; }
		/**
		 * Sum of list prices for one-off charges for the whole downward hierarchy of related priceables for a single unit of the product.
		 */
		global Decimal unitListOneOffPrice { get; set; }
		/**
		 * Sum of sales prices for one-off charges for the whole downward hierarchy of related priceables for a single unit of the product.
		 */
		global Decimal unitSalesOneOffPrice { get; set; }
		/**
		 * Sum of list prices for one-off charges for the whole downward hierarchy of related priceables.
		 */
		global Decimal totalListOneOffPrice { get; set; }
		/**
		 * Sum of sales prices for one-off charges for the whole downward hierarchy of related priceables.
		 */
		global Decimal totalSalesOneOffPrice { get; set; }
		/**
		 * Sum of internal list prices for recurring charges for a single unit of the product. Does not include prices for down-hierarchy priceables.
		 */
		global Decimal listRecurringPrice { get; set; }
		/**
		 * Sum of internal sales prices for recurring charges for a single unit of the product. Does not include prices for down-hierarchy priceables.
		 */
		global Decimal salesRecurringPrice { get; set; }
		/**
		 * Sum of list prices for recurring charges for the whole downward hierarchy of related priceables for a single unit of the product.
		 */
		global Decimal unitListRecurringPrice { get; set; }
		/**
		 * Sum of sales prices for recurring charges for the whole downward hierarchy of related priceables for a single unit of the product.
		 */
		global Decimal unitSalesRecurringPrice { get; set; }
		/**
		 * Sum of list prices for recurring charges for the whole downward hierarchy of related priceables.
		 */
		global Decimal totalListRecurringPrice { get; set; }
		/**
		 * Sum of sales prices for recurring charges for the whole downward hierarchy of related priceables.
		 */
		global Decimal totalSalesRecurringPrice { get; set; }

		global void validate() {
			if (this.charges != null) {
				for (Charge c : this.charges) {
					if (c != null) {
						c.validate();
					}
				}
			}
			if (this.discounts != null) {
				for (Discount d : this.discounts) {
					if (d != null) {
						d.validate();
					}
				}
			}
		}
	}

	global with sharing class Charge implements Validateable {
		/**
		 * API version of the Charge structure
		 */
		global String version { get; set; }
		/**
		 * A short, machine-readable identifier for the charge - akin to line item attribute name
		 */
		global String name { get; set; }
		global String chargeType { get; set; }
		/**
		 * The list price for the charge if it needs to be presented to the customer. Optional. Has no effect on price calculations.
		 */
		global Decimal listPrice { get; set; }
		/**
		 * The sales price for the charge. Required.
		 */
		global Decimal salesPrice { get; set; }
		/**
		 * A description, typically used for rendering the charge line item in quotes etc. If it represents a i18n-able label key, the key should be surrounded by <# and #>
		 */
		global String description { get; set; }
		/**
		 * Reference to the source of the charge. With integrations to the Product and Pricing Model, it could be the charge id.
		 */
		global String source { get; set; }
		global Map<String, String> customData { get; set; }

		global void validate() {
			validateVersion('Charge', this.version, new List<String>{ VERSION_1_0_0 });

			constrainValue('Charge', 'chargeType', this.chargeType, CHARGE_TYPE);
			require('Charge', 'description', this.description);
			require('Charge', 'name', this.name);
			require('Charge', 'source', this.source);
			require('Charge', 'version', this.version);
		}
	}

	global with sharing class Discount implements Validateable {
		/**
		 * API version of the Discount structure
		 */
		global String version { get; set; }
		/**
		 * Name of the charge being adjusted. If '__PRODUCT__', the adjustment will apply to product-level charges, otherwise to line item attribute with the specified name or the charge with the same name.
		 */
		global String discountCharge { get; set; }
		global String chargeType { get; set; }
		global String discountPrice { get; set; }
		global String type { get; set; }
		/**
		 * The amount by which the charge price should be discounted.
		 */
		global Decimal amount { get; set; }
		/**
		 * A human-readable description for this discount. The value has no effect on the discounting mechanism.
		 */
		global String description { get; set; }
		/**
		 * In case the discount is applicable only for a limited time, this duration of the discount starting with the service commencement date. The unit of measure is the recurrence period.
		 */
		global Decimal duration { get; set; }
		global Decimal recurringOffset { get; set; }
		/**
		 * An identifier for the reason for the discount, such as a pricing rule code, a keyword identifying a manual discount category etc. Customer implementation code can use this identifier to refer to the specific discount record. The value has no effect on the discounting mechanism.
		 */
		global String source { get; set; }
		global String evaluationOrder { get; set; }
		global String recordType { get; set; }
		global Discount[] memberDiscounts { get; set; }
		global Map<String, String> customData { get; set; }

		global void validate() {
			validateVersion(
				'Discount',
				this.version,
				new List<String>{ VERSION_1_0_0, VERSION_2_0_0, VERSION_3_0_0, VERSION_3_1_0 }
			);

			if (isVersionEqualTo(this.version, VERSION_1_0_0)) {
				require('Discount', 'amount', this.amount);
				require('Discount', 'discountCharge', this.discountCharge);
				constrainValue('Discount', 'discountPrice', this.discountPrice, PRICE_TYPE);
				constrainValue('Discount', 'type', this.type, DISCOUNT_TYPE_100);
			} else if (isVersionEqualTo(this.version, VERSION_2_0_0)) {
				require('Discount', 'amount', this.amount);
				constrainValue('Discount', 'chargeType', this.chargeType, CHARGE_TYPE);
				require('Discount', 'discountCharge', this.discountCharge);
				constrainValue('Discount', 'discountPrice', this.discountPrice, PRICE_TYPE);
				constrainValue('Discount', 'type', this.type, DISCOUNT_TYPE_100);
				require('Discount', 'version', this.version);
			} else if (isVersionEqualTo(this.version, VERSION_3_0_0)) {
				require('Discount', 'version', this.version);
				constrainValue('Discount', 'recordType', this.recordType, RECORD_TYPE);
				constrainValue('Discount', 'chargeType', this.chargeType, CHARGE_TYPE_OPTIONAL);
				constrainValue('Discount', 'discountPrice', this.discountPrice, PRICE_TYPE_OPTIONAL);
				constrainValue('Discount', 'type', this.type, DISCOUNT_TYPE_OPTIONAL_100);
				constrainValue('Discount', 'evaluationOrder', this.evaluationOrder, EVALUATION_ORDER_OPTIONAL);
			} else if (isVersionEqualTo(this.version, VERSION_3_1_0)) {
				require('Discount', 'version', this.version);
				constrainValue('Discount', 'chargeType', this.chargeType, CHARGE_TYPE_OPTIONAL);
				constrainValue('Discount', 'discountPrice', this.discountPrice, PRICE_TYPE_OPTIONAL);
				constrainValue('Discount', 'type', this.type, DISCOUNT_TYPE_OPTIONAL); // this changed in version 3-1-0
				constrainValue('Discount', 'evaluationOrder', this.evaluationOrder, EVALUATION_ORDER_OPTIONAL);
				constrainValue('Discount', 'recordType', this.recordType, RECORD_TYPE);
			}

			if (this.memberDiscounts != null) {
				for (Discount m : this.memberDiscounts) {
					if (m != null) {
						m.validate();
					}
				}
			}
		}
	}
}
