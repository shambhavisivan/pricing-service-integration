
@IsTest
public with sharing class PricingServiceApiTest {

	@IsTest
	public static void testSynchronizationCreatedUpdatedFieldsDeserialization() {
		String syncJson = '{ "created_at": "created-val", "updated_at": "updated-val" }';

		PricingServiceApi.Synchronization syncObj = (PricingServiceApi.Synchronization) Json.deserialize(syncJson, PricingServiceApi.Synchronization.class);

		System.assertEquals('created-val', syncObj.createdAt);
		System.assertEquals('updated-val', syncObj.updatedAt);
	}
}
