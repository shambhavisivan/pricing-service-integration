global with sharing class PricingAggregatorComponentController {
    global PricingAggregatorComponentController() {}

    @RemoteAction
    global static PricingAggregatorRegistration getPricingAggregatorRegistration() {
        return PricingAggregator.getPluginConfiguration();
    }
}
