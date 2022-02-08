# Pricing Aggregation

The Pricing Aggregator should be used to aggregate pricing information from multiple sources. For every source to be used by the pricing aggregator, a registration record should exist.
The record describes which fields the aggregator should read from when aggregating a cart and/or cart items.
It is available both for Apex and JavaScript (as an npm module). The pricing aggregator returns a list of Discount objects after it is done with aggregation.

## Aggregating pricing information from multiple sources of pricing

Aggregation is currently done via a simple mechanism of JSON concatenation, i.e. if there are multiple available sources of pricing, the resulting discounts will be combined together to form a single list of discounts.

### Apex

The following snippet describes how to invoke the aggregation of cart prices:

```Java
cspsi.CommonCartWrapper.CommonCart cart = /* common cart data */

List<cspsi.CommonCartWrapper.Discount> discounts =
    cspsi.PricingAggregator.aggregateCartPricing(cart);
```

And this snippet describes how to do so for cart items:

```Java
cspsi.CommonCartWrapper.CartItem cartItem = /* common cart item data */

List<cspsi.CommonCartWrapper.Discount> discounts =
    cspsi.PricingAggregator.aggregateCartItemPricing(cartItem);
```

Use the method below in order to aggregate discounts for cart items and their child items:

```Java
cspsi.CommonCartWrapper.CartItem cartItem = /* common cart item data with child items */

List<cspsi.CommonCartWrapper.Discount> discounts =
    cspsi.PricingAggregator.aggregateCartItemPricingDeep(cartItem);
```

### JavaScript

Pricing Aggregator JavaScript usage is available in the README.md file of the @cloudsense/pricing-aggregator module.

## Registering a pricing aggregation source

A pricing aggregation source can be added either manually by creating a csutil\_\_Json_Metadata\_\_mdt/csutil\_\_Json_Settings\_\_c record, or by invoking the PricingAggregation registration function.

The following snippet describes how to register a pricing aggregation source:

```Java
cspsi.PricingAggregatorRegistration registration = new cspsi.PricingAggregatorRegistration();
registration.version = '1-0-0';
registration.cartFields = new List<String> {
    'customData.customFields!custom__discounts__c',
};
registration.cartItemFields = new List<String> {
    'customData.customFields!pre_pricing__c'
};

String name = 'CustomAggregationSource';

cspsi.PricingAggregator.registerPricingAggregator(name, registration);
```

> NOTE: The `!` operator indicates that the value needs to be deserialised before proceeding to follow the reference chain.
>
> I.e. the `customData.customFields` property needs to be deserialised before being able to access the `pre_pricing__c` field.

### Deleting an existing pricing aggregation source

An example of how to delete an existing registration:

```Java
String name = 'CustomAggregationSource';

cspsi.PricingAggregator.deletePricingAggregator(name);
```

> NOTE: The name used in both examples is the logical name of the source of pricing information. The package will turn the name into the proper Json Settings name.
