# Applying discounts to Configurator's Product Configuration records

The result of PricingAggregator can be applied onto Configurator's Product Configuration record with minimal necessary changes.

The Product Configuration discount\_\_c field expects discounts to be formatted in the following manner:

```json
{
  "discounts": [] // array of discounts go here
}
```

The following example shows how to create a structure which will be parseable by the discounts\_\_c field in the Product Configuration record:

```Java
cscfga__Product_Configuration__c productConfiguration = /* product configuration record */
cspsi.CommonCartWrapper.CartItem cartItem = /* common cart item data */

// aggregate the discounts
List<cspsi.CommonCartWrapper.Discount> aggregatedDiscounts = cspsi.PricingAggregator.aggregateCartItemPricing(cartItem);

// create the necessary structure
Map<String, Object> discountsMap = new Map<String, Object> {
    'discounts' => aggregatedDiscounts
};

// apply it to the discounts__c field
productConfiguration.cscfga__discounts__c = Json.serialize(discountsMap);
```
