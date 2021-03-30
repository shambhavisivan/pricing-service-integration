import { PricingAggregatorRegistration } from './pricing-aggregator-interfaces';
import { DeserializationError } from '../error/deserialisation-error';
import { InvalidExpressionError } from '../error/invalid-expression-error';
import { CommonCart, CartItem, Discount } from '@cloudsense/common-cart';
import { MissingRegistrationError } from '../error/missing-registration-error';

const PRICING_AGGREGATOR = 'PSI/PricingAggregator';
const DOT_CHAR = '.';
const EXCL_MARK_CHAR = '!';

export class PricingAggregator {
	// constructor should inject configuration
	// if no configuration fetch it from salesforce?
	public constructor(private registration?: PricingAggregatorRegistration) {}

	public aggregateCartPricing(cart: CommonCart): Discount[] {
		const par = this.getPluginConfiguration();

		return this.getDiscountsFor(par.cartFields, cart);
	}

	public aggregateCartItemPricing(cartItem: CartItem): Discount[] {
		const par = this.getPluginConfiguration();

		return this.getDiscountsFor(par.cartItemFields, cartItem);
	}

	public getPluginConfiguration(): PricingAggregatorRegistration {
		if (!this.registration) {
			throw new MissingRegistrationError(
				`Missing or invalid configuration for: ${PRICING_AGGREGATOR}`
			);
		}
		return this.registration;
	}

	private getDiscountsFor(expressions: string[], obj: any): Discount[] {
		let discounts: Discount[] = [];

		if (!expressions || !obj) {
			return discounts;
		}

		for (let expression of expressions) {
			this.validateExpression(expression);

			try {
				const discountsJson = this.evaluateExpression(expression, obj);
				if (discountsJson.startsWith('{')) {
					discounts.push(JSON.parse(discountsJson));
				} else if (discountsJson.startsWith('[')) {
					discounts = discounts.concat(JSON.parse(discountsJson));
				}
			} catch (e) {
				throw new DeserializationError(
					`Error parsing discounts json value for expression: ${expression} in item with Id: ${obj['id']} ${e.message}`
				);
			}
		}

		return discounts;
	}

	private evaluateExpression(expression: string, obj: any): string {
		const tokens = this.tokenize(expression);
		let currObject = obj;
		let currValue;

		for (let token of tokens) {
			if (token == DOT_CHAR && currValue != null) {
				// assign the currValue to currObject to traverse the nested property
				currObject = currValue;
			} else if (token == EXCL_MARK_CHAR && currValue != null) {
				// fields suffixed with '!' need to be deserialised before traversal
				currValue = JSON.parse(currValue);
				// assign the currValue to currObject to traverse the nested property
				currObject = currValue;
			} else if (token != DOT_CHAR && token != EXCL_MARK_CHAR) {
				// take only field values
				currValue = currObject[token];
			}
		}

		return currValue;
	}

	private validateExpression(expression: string): void {
		if (
			expression.startsWith(DOT_CHAR) ||
			expression.startsWith(EXCL_MARK_CHAR) ||
			expression.endsWith(DOT_CHAR) ||
			expression.endsWith(EXCL_MARK_CHAR) ||
			expression.includes(DOT_CHAR + DOT_CHAR) ||
			expression.includes(EXCL_MARK_CHAR + EXCL_MARK_CHAR)
		) {
			throw new InvalidExpressionError(`Invalid expression format: ${expression}`);
		}
	}

	private tokenize(expression: string): string[] {
		const retVal = [];
		let tmpToken = '';

		for (let char of expression) {
			if (char === DOT_CHAR || char === EXCL_MARK_CHAR) {
				if (tmpToken) {
					retVal.push(tmpToken);
					tmpToken = '';
				}

				retVal.push(char);
			} else {
				tmpToken = `${tmpToken}${char}`;
			}
		}

		if (tmpToken) {
			retVal.push(tmpToken);
		}

		return retVal;
		// commented out due safari issue. When safari enables support for lookbehind and lookahead replace above code with this
		// use regex lookbehind and lookahead to split the expression
		// by delimiters ("." and "!"), while keeping delimiters as well
		// e.g. 'a.b!c'.split(...) produces ['a', '.', 'b', '!', 'c']
		// return expression.split(/(?<=[.!])|(?=[.!])/);
	}
}
