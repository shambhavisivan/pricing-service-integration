import { PricingAggregator } from '../../src/services/pricing-aggregator';
import { CommonCart, CartItem } from '@cloudsense/common-cart-version-adapter';
import { PricingAggregatorRegistration } from '../../src/services/pricing-aggregator-interfaces';
import { expect } from 'chai';
import { InvalidExpressionError } from '../../src/error/invalid-expression-error';
import { DeserializationError } from '../../src/error/deserialisation-error';

const pricingAggregatorRegistration: PricingAggregatorRegistration = {
	version: '1-0-0',
	cartFields: ['customData.customFields!csdm__discounts__c'],
	cartItemFields: ['customData.customFields!custom_discount_field__c']
};
const pricingAggregator = new PricingAggregator(pricingAggregatorRegistration);
const discountJson = {
	version: '3-1-0',
	discountCharge: '__PRODUCT__',
	chargeType: 'oneOff',
	discountPrice: 'sales',
	type: 'absolute',
	amount: 1,
	description: 'sample discount',
	duration: 0,
	recurringOffset: 0,
	source: 'discount source',
	evaluationOrder: 'serial',
	recordType: 'single',
	memberDiscounts: [],
	customData: {}
};

describe('Pricing Aggregator', () => {
	describe('aggregateCartPricing', () => {
		it('returns cart custom discount json defined in the registration record', () => {
			const cart: CommonCart = {
				id: 'cart-id',
				version: '3-1-0',
				customData: {
					customFields: JSON.stringify({
						csdm__discounts__c: JSON.stringify(discountJson)
					})
				}
			};

			const cartPricing = pricingAggregator.aggregateCartPricing(cart);

			expect(cartPricing).to.deep.equal([discountJson]);
		});

		it('returns multiple cart custom discount jsons defined in the registration record', () => {
			const cart: CommonCart = {
				id: 'cart-id',
				version: '3-1-0',
				customData: {
					customFields: JSON.stringify({
						csdm__discounts__c: JSON.stringify([discountJson, discountJson])
					})
				}
			};

			const cartPricing = pricingAggregator.aggregateCartPricing(cart);

			expect(cartPricing).to.deep.equal([discountJson, discountJson]);
		});

		describe('throws exception', () => {
			it('when the expression is invalid', () => {
				const pricingAggregatorRegistration: PricingAggregatorRegistration = {
					version: '1-0-0',
					cartFields: ['customData.customFields!!csdm__discounts__c'], // extra exclamation mark - invalid expression
					cartItemFields: ['']
				};
				const pricingAggregator = new PricingAggregator(pricingAggregatorRegistration);
				const cart: CommonCart = {
					id: 'cart-id',
					version: '3-1-0',
					customData: {
						customFields: JSON.stringify({
							csdm__discounts__c: JSON.stringify([discountJson])
						})
					}
				};

				try {
					pricingAggregator.aggregateCartPricing(cart);
				} catch (e) {
					expect(e instanceof InvalidExpressionError).to.be.true;
					expect(e.message).to.equal(
						'Invalid expression format: customData.customFields!!csdm__discounts__c'
					);
				}
			});

			it('when the json is invalid', () => {
				const pricingAggregatorRegistration: PricingAggregatorRegistration = {
					version: '1-0-0',
					cartFields: ['customData.customFields!csdm__discounts__c'],
					cartItemFields: ['']
				};
				const pricingAggregator = new PricingAggregator(pricingAggregatorRegistration);
				const cart: CommonCart = {
					id: 'cart-id',
					version: '3-1-0',
					customData: {
						customFields: JSON.stringify({
							csdm__discounts__c: JSON.stringify(discountJson).substring(
								0,
								JSON.stringify(discountJson).length - 3
							)
						})
					}
				};

				try {
					pricingAggregator.aggregateCartPricing(cart);
				} catch (e) {
					expect(e instanceof DeserializationError).to.be.true;
					expect(e.message).to.equal(
						'Error parsing discounts json value for expression: customData.customFields!csdm__discounts__c in item with Id: cart-id Unexpected end of JSON input'
					);
				}
			});
		});
	});

	describe('aggregateCartItemPricing', () => {
		it('returns cart item custom discount json defined in the registration record', () => {
			const cartItem: CartItem = {
				id: 'cart-id',
				version: '3-1-0',
				customData: {
					customFields: JSON.stringify({
						custom_discount_field__c: JSON.stringify(discountJson)
					})
				}
			};

			const cartItemPricing = pricingAggregator.aggregateCartItemPricing(cartItem);

			expect(cartItemPricing).to.deep.equal([discountJson]);
		});

		it('returns multiple cart item custom discount jsons defined in the registration record', () => {
			const cartItem: CartItem = {
				id: 'cart-id',
				version: '3-1-0',
				customData: {
					customFields: JSON.stringify({
						custom_discount_field__c: JSON.stringify([discountJson, discountJson])
					})
				}
			};

			const cartItemPricing = pricingAggregator.aggregateCartItemPricing(cartItem);

			expect(cartItemPricing).to.deep.equal([discountJson, discountJson]);
		});
	});

	describe('aggregateCartItemPricingDeep', () => {
		it('returns cart item with aggregated discount json for all its child items', () => {
			const cartItem: CartItem = {
				id: 'cart-id',
				version: '3-1-0',
				customData: {
					custom_discount_field__c: JSON.stringify(discountJson)
				},
				childItems: {
					relatedProducts: [
						{
							id: 'child-id-1',
							version: '3-1-0',
							customData: {
								custom_discount_field__c: JSON.stringify(discountJson)
							}
						},
						{
							id: 'child-id-2',
							version: '3-1-0',
							customData: {
								custom_discount_field__c: JSON.stringify(discountJson)
							}
						},
						{
							id: 'child-id-3',
							version: '3-1-0',
							customData: {
								custom_discount_field__c: JSON.stringify(discountJson)
							}
						}
					]
				}
			};

			const cartItemWithDiscouts = pricingAggregator.aggregateCartItemPricingDeep(cartItem);

			const childItemsWithDiscounts = Object.values(
				cartItemWithDiscouts.childItems || {}
			).flat();

			[cartItemWithDiscouts, ...childItemsWithDiscounts].forEach(item => {
				expect(item.pricing?.discounts).to.deep.equal([discountJson]);
			});
		});
	});
});
