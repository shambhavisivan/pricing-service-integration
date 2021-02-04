global with sharing class PricingAggregatorRegistration extends AJsonConfiguration {
	global List<String> cartFields { get; set; }
	global List<String> cartItemFields { get; set; }

	global PricingAggregatorRegistration() {
		this.cartFields = new List<String>();
		this.cartItemFields = new List<String>();
	}

	global override void validate() {
		validateVersion();
	}
}
