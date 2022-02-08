# Known issues & advisories

## The new aggregateCartItemPricingDeep method is limited to a single level of cart item nesting.

For example, aggregating prices for a cart item with one level of children (a commercial product with add-ons) will work, but doing the same for multiple levels of children like a package with commercial products having add-ons will not work.

As a workaround, you can use the old aggregation methods and recurse to multiple levels yourself.
