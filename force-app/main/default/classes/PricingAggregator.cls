global with sharing class PricingAggregator {
	public static final String PRICING_AGGREGATOR_NAMESPACE = 'PSI/PricingAggregator';

	private static final String DOT_CHAR = '.';
	private static final String EXCL_MARK_CHAR = '!';

	global static List<CommonCartWrapper.Discount> aggregateCartPricing(CommonCartWrapper.CommonCart cart) {
		PricingAggregatorRegistration par = getPluginConfiguration();

		return getDiscountsFor(par.cartFields, cart);
	}

	global static List<CommonCartWrapper.Discount> aggregateCartItemPricing(CommonCartWrapper.CartItem cartItem) {
		PricingAggregatorRegistration par = getPluginConfiguration();

		return getDiscountsFor(par.cartItemFields, cartItem);
	}

	public static PricingAggregatorRegistration getPluginConfiguration() {
		List<PricingAggregatorRegistration> pluginConfigurations = (List<PricingAggregatorRegistration>) JsonConfigurationService.getPluginConfigurations(
			PRICING_AGGREGATOR_NAMESPACE,
			PricingAggregatorRegistration.class
		);

		if (pluginConfigurations == null || pluginConfigurations.size() == 0) {
			throw new PsiException.PluginRegistrationException(
				'Missing or invalid configuration for: ' + PRICING_AGGREGATOR_NAMESPACE
			);
		}

		PricingAggregatorRegistration mergedConfiguration = new PricingAggregatorRegistration();
		// TODO: add version check and upgrade once PricingAggregatorRegistration changes
		mergedConfiguration.version = '1-0-0';

		for (PricingAggregatorRegistration par : pluginConfigurations) {
			mergedConfiguration.cartFields.addAll(par.cartFields);
			mergedConfiguration.cartItemFields.addAll(par.cartItemFields);
		}

		return mergedConfiguration;
	}

	private static List<CommonCartWrapper.Discount> getDiscountsFor(
		List<String> expressions,
		CommonCartWrapper.FieldsAsMap obj
	) {
		List<CommonCartWrapper.Discount> discounts = new List<CommonCartWrapper.Discount>();

		if (expressions == null || obj == null) {
			return discounts;
		}

		for (String expression : expressions) {
			validateExpression(expression);
			try {
				String discountsJson = evaluateExpression(expression, obj);
				if (discountsJson.startsWith('{')) {
					discounts.add(
						(CommonCartWrapper.Discount) Json.deserialize(discountsJson, CommonCartWrapper.Discount.class)
					);
				} else if (discountsJson.startsWith('[')) {
					discounts.addAll(
						(List<CommonCartWrapper.Discount>) Json.deserialize(
							discountsJson,
							List<CommonCartWrapper.Discount>.class
						)
					);
				}
			} catch (Exception e) {
				throw new PsiException.DeserializationException(
					'Error parsing discounts json value for expression: ' +
					expression +
					' in item with Id: ' +
					obj.getPopulatedFieldsAsMap().get('id') +
					' ' +
					e.getMessage()
				);
			}
		}

		return discounts;
	}

	@TestVisible
	private static String evaluateExpression(String expression, CommonCartWrapper.FieldsAsMap obj) {
		List<String> tokens = tokenize(expression);
		Map<String, Object> currObject = obj.getPopulatedFieldsAsMap();
		Object currValue;

		for (String token : tokens) {
			if (token == DOT_CHAR && currValue != null) {
				// assign the currValue to currObject to traverse the nested property
				currObject = (Map<String, Object>) currValue;
			} else if (token == EXCL_MARK_CHAR && currValue != null) {
				// fields suffixed with '!' need to be deserialised before traversal
				currValue = Json.deserializeUntyped((String) currValue);
				// assign the currValue to currObject to traverse the nested property
				currObject = (Map<String, Object>) currValue;
			} else if (token != DOT_CHAR && token != EXCL_MARK_CHAR) {
				// take only field values
				currValue = currObject.get(token);
			}
		}

		return (String) currValue;
	}

	@TestVisible
	private static void validateExpression(String expression) {
		if (
			expression.startsWith(DOT_CHAR) ||
			expression.startsWith(EXCL_MARK_CHAR) ||
			expression.endsWith(DOT_CHAR) ||
			expression.endsWith(EXCL_MARK_CHAR) ||
			expression.contains(DOT_CHAR + DOT_CHAR) ||
			expression.contains(EXCL_MARK_CHAR + EXCL_MARK_CHAR)
		) {
			throw new PsiException.InvalidExpressionException('Invalid expression format: ' + expression);
		}
	}

	@TestVisible
	private static List<String> tokenize(String expression) {
		// use regex lookbehind and lookahead to split the expression
		// by delimiters ("." and "!"), while keeping delimiters as well
		// e.g. 'a.b!c'.split(...) produces ['a', '.', 'b', '!', 'c']
		return expression.split('((?<=[\\.!])|(?=[\\.!]))');
	}
}
