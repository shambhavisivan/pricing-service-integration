# Registering with the Pricing Service

To be able to use this package there is a prerequisite to register/provision an org with the Pricing Service.

## Prerequisites

- A certificate (and private/public keypair) created or uploaded to Salesforce (Setup -> Security Controls -> Certificate and Key Management)
  - Salesforce has an inbuilt functionality to create such a certificate (and private/public keypair)
- Dispatcher service endpoint address

## Registration/provisioning

The certificate created in Salesforce should be used (the public key part) when registering/provisioning the org with the Pricing Service. Instructions on how to do so are available on [Pricing Service Documentation](https://cloudsense.atlassian.net/wiki/spaces/SEDE/pages/712179741/Pricing+Service).

## Custom settings setup

A `Psi_Options__c` custom settings record should be created.
It contains the following fields:

- Certificate Name (`certificate_name__c`)
  - The name of the generated certificate which resided in the Certificate and Key Management Salesforce Setup section
- Dispatcher Service Endpoint (`dispatcher_service_endpoint__c`)
  - The URL of the dispatcher service:
    - for EU region: https://messaging-api-eu.cloudsense.com
    - for US region: https://messaging-api-us.cloudsense.com
    - for APAC region: https://messaging-api-sydney.cloudsense.com
