# Introduction

Advanced Pricing Integration package serves as an interface between the Pricing Service and a sales application.

Every sales application can register via this package and utilize the Pricing Service functionality.

The responsibilities of this package are:

- An **[Apex API](#pricing-service-api)** to invoke Pricing Service endpoints:
    - Starting and monitoring data synchronisation from a Salesforce org to the Pricing Service
    - Sending requests to the Pricing Service
- An Apex API to parse Common Cart structures and extract discount, charge, and pricing data:
    - Creating common cart structures - used to fetch pricing data from the Pricing Service
    - Storing discounts in the Product Configuration records of the Product Configurator package
    - Validate the common cart structure

![]({{images}}/common-cart-transformation.png)

- A mechanism for automatic PRG (Pricing Rule Group) selection

![]({{images}}/prg-selection2.png)

- Apex and Typescript based modules for **[aggregating pricing contributions](#aggregating-pricing-information-from-multiple-sources-of-pricing)** from different sources

![]({{images}}/pricing-aggregation.png)
