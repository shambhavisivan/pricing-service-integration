# Pricing Service API

## Starting and monitoring synchronisation

In order to be able to determine prices, Pricing Service needs to retrieve data from Salesforce. Retrieval of data is done through the synchronisation process. Records are read from Salesforce and stored in the Pricing Service's own Heroku database.
After each change to Pricing Model data, it needs to be synchronised again, so that the pricing information is accurate.

The following snippet describes how to invoke the synchronisation process:

```Java
cspsi.PricingServiceApi.SyncInProgressResponse syncResponse = 
    cspsi.PricingServiceApi.synchronise();
```

Information about the response is available in the [Pricing Service User Guide](https://drive.google.com/file/d/1uD6WuM15UsdHdq_YZmnogho745bhEiCB/view).

To verify that synchronisation attempts are successful, the following code can be used:

```Java
cspsi.PricingServiceApi.Synchronizations allSyncRespone = 
    cspsi.PricingServiceApi.getLastSynchronisations();
```

It lists all synchronisation attempts and whether they were successful, execution time, and an error message if the synchronisation was not successful.

Examples of responses for successful synchronizations, failed synchronizations, and synchronizations in progress are available in the [Pricing Service User Guide](https://drive.google.com/file/d/1uD6WuM15UsdHdq_YZmnogho745bhEiCB/view).

## Creating a Common Cart structure

```Java
// create a cart
cspsi.CommonCartWrapper.CommonCart cart = new cspsi.CommonCartWrapper.CommonCart();
cart.version = '3-1-0';
cart.pricingRuleGroupCodes = new List<String> { 'PRG1', 'PRG2' };
cart.id = 'a-cart-id';

// create cart item(s)
cspsi.CommonCartWrapper.CartItem aCartItem = new cspsi.CommonCartWrapper.CartItem();
aCartItem.version = '3-1-0';
aCartItem.id = 'a-cart-item-id';
aCartItem.quantity = 1;
aCartItem.catalogueItemId = 'a-commercial-product-code';

// add cart items to the cart
cart.items = new List<cspsi.CommonCartWrapper.CartItem> { aCartItem };

// validate whether all cart properties have been populated correctly
cart.validate();
```

## Invoking the Pricing Service

To execute pricing rules and determine prices, Pricing Service needs to be invoked. Calling the Pricing Service is done through the `cspsi.PricingServiceApi` method named \
`getPricings(CommonCartWrapper.CommonCart cart)`.

An Apex code snippet describing how to invoke the Pricing Service:

```Java
cspsi.CommonCartWrapper.CommonCart cart = ...;

cspsi.CommonCartWrapper.CommonCart responseCart = cspsi.PricingServiceApi.getPricings(cart);
```

Example of a request body:

```JSON
{
	"version": "3-1-0",
	"id": "4e460a83-35ba-4374-ace8-6d7d4b1448ac",
	"pricingRuleGroupCodes": [ "PRG1" ],
	"items": [
		{
			"version": "3-1-0",
			"id": "0569748f-a17a-483e-bf3f-3916294be294",
			"quantity": 1,
			"catalogueItemId": "a-catalogue-item-code"
		}
	]
}

```

### Understanding the response - pricing information

The response of the `getPricings` method is also in the Common Cart format. It contains pricing information for the provided cart items.

Example of a response:

```JSON
{
    "actions": [],
    "cart": {
        "version": "3-2-0",
        "id": "4e460a83-35ba-4374-ace8-6d7d4b1448ac",
        "pricingRuleGroupCodes": [
            "PRG1"
        ],
        "items": [
            {
                "version": "3-1-0",
                "id": "0569748f-a17a-483e-bf3f-3916294be294",
                "quantity": 1,
                "catalogueItemId": "a-catalogue-item-code",
                "childItems": {},
                "pricing": {
                    "listOneOffPrice": 1001,
                    "salesOneOffPrice": 1001,
                    "listRecurringPrice": 0,
                    "salesRecurringPrice": 0,
                    "discounts": [
                        {
                            "source": "a-catalogue-item-base-price",
                            "version": "3-1-0",
                            "discountCharge": "__PRODUCT__",
                            "amount": 1001,
                            "type": "init",
                            "chargeType": "oneOff",
                            "recordType": "single"
                        }
                    ],
                    "charges": [],
                    "unitListOneOffPrice": 1001,
                    "unitSalesOneOffPrice": 1001,
                    "totalListOneOffPrice": 1001,
                    "totalSalesOneOffPrice": 1001,
                    "unitListRecurringPrice": 0,
                    "unitSalesRecurringPrice": 0,
                    "totalListRecurringPrice": 0,
                    "totalSalesRecurringPrice": 0
                }
            }
        ],
        "pricing": {
            "listOneOffPrice": 1001,
            "listRecurringPrice": 0,
            "salesOneOffPrice": 1001,
            "salesRecurringPrice": 0,
            "totalListOneOffPrice": 1001,
            "totalListRecurringPrice": 0,
            "totalSalesOneOffPrice": 1001,
            "totalSalesRecurringPrice": 0,
            "unitListOneOffPrice": 1001,
            "unitListRecurringPrice": 0,
            "unitSalesOneOffPrice": 1001,
            "unitSalesRecurringPrice": 0
        }
    }
}
```

The authoritative result of the pricing service is contained in the `pricing.discounts` property of the response JSON.
These discount JSONs need to be stored in the `cscfga__Product_Configuration__c` record in a dedicated field and fed into the aggregation process.

>**Note**: The pricing service is just one of multiple possible sources of pricing information, and is optional.

The prices directly under the `pricing` key are pre-calculated aggregates assuming that the Pricing Service is the sole provider of the pricing information. 
The prices may be useful and are provided as a convenience, but each sales application should treat them judiciously and in the context of other sources of pricing (i.e. ignore them if other sources are present).