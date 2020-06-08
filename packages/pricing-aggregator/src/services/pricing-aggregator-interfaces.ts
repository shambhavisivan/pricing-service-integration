export interface AJsonConfiguration {
	version: string;
}

export interface PricingAggregatorRegistration extends AJsonConfiguration {
	cartFields: string[];
	cartItemFields: string[];
}
