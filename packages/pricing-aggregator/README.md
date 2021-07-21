# Pricing Aggregator

CloudSense pricing aggregator for NodeJS. Aggregates discount JSON pricing.

## Installation

```bash
npm install @cloudsense/pricing-aggregator
```

## Usage

### Node.js:

```javascript
const PricingAggregator = require('@cloudsense/pricing-aggregator').PricingAggregator;
const registration = ...;

const aggregator = new PricingAggregator(registration);

const discounts = aggregator.aggregateCartPricing(...);
```

### VisualForce:

To access the library in Salesforce, the component needs to be added to the page:

```html
<cspsi:PricingAggregator />
```

A remote action is available to retrieve the registration record:

```javascript
function getPricingAggregatorRegistration() {
    return new Promise((resolve,reject) => {
        // The function getPricingAggregatorRegistration is available through the component controller
        Visualforce.remoting.Manager.invokeAction(
            'cspsi.PricingAggregatorComponentController.getPricingAggregatorRegistration',
            (registration) => { resolve(registration); }
        );
    });
}
const registration = await getPricingAggregatorRegistration();

// PricingAggregator is available globally in VF context
const aggregator = new PricingAggregator(registration);

const discounts = aggregator.aggregateCartPricing(...);
```

## Versions

### 2021-07-21, Version 1.1.0

-   Replace Common Cart with Common Cart Version Adapter

### 2020-08-27, Version 1.0.0

-   Initial release
