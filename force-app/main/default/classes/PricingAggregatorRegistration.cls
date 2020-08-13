global with sharing class PricingAggregatorRegistration extends AJsonConfiguration {
	global List<String> cartFields { get; set; }
	global List<String> cartItemFields { get; set; }

	public PricingAggregatorRegistration() {
	}

	global override void validate() {
		validateVersion();
	}
}
