@IsTest
public with sharing class PricingServiceApiTest {
	public static void requestUtilityGetterTest() {
		// default implementation should return a (wrapped) dispatcher request util
		IRequestUtility reqUtil = PricingServiceApi.requestUtility;

		System.assertEquals(true, reqUtil instanceof PricingServiceApi.DispatcherRequestUtilWrapper);
	}

	@IsTest
	public static void testSynchronizationCreatedUpdatedFieldsDeserialization() {
		String syncJson = '{ "created_at": "created-val", "updated_at": "updated-val", "catalogueId": null, "success": true, "message": "done" }';

		PricingServiceApi.Synchronization syncObj = (PricingServiceApi.Synchronization) Json.deserialize(
			syncJson,
			PricingServiceApi.Synchronization.class
		);

		System.assertEquals('created-val', syncObj.createdAt);
		System.assertEquals('updated-val', syncObj.updatedAt);
		System.assertEquals(null, syncObj.catalogueId);
		System.assertEquals(true, syncObj.success);
		System.assertEquals('done', syncObj.message);
	}

	@IsTest
	public static void synchroniseTest() {
		MockRequestUtil mock = new MockRequestUtil()
			.setResponse('{"lastSync":null, "lastSyncSuccess":null, "message": "done"}');
		PricingServiceApi.requestUtility = mock;

		Test.startTest();
		PricingServiceApi.SyncInProgressResponse response = PricingServiceApi.synchronise();
		Test.stopTest();

		RequestParams rp = mock.requestParams;
		System.assertEquals('GET', rp.method);
		System.assertEquals('/pre/synchronize-pricings', rp.endpoint);
		System.assertEquals('', rp.payload);

		System.assertEquals(null, response.lastSync);
		System.assertEquals(null, response.lastSyncSuccess);
		System.assertEquals('done', response.message);
	}

	@IsTest
	public static void getLastSynchronisationsTest() {
		MockRequestUtil mock = new MockRequestUtil()
			.setResponse('{"results":[{"lastSync":null, "lastSyncSuccess":null, "message": "done"}]}');
		PricingServiceApi.requestUtility = mock;

		Test.startTest();
		PricingServiceApi.Synchronizations response = PricingServiceApi.getLastSynchronisations();
		Test.stopTest();

		RequestParams rp = mock.requestParams;
		System.assertEquals('GET', rp.method);
		System.assertEquals('/pre/synchronizations', rp.endpoint);
		System.assertEquals('', rp.payload);

		System.assertNotEquals(null, response.results);
	}

	@IsTest
	public static void getPricingsTest() {
		CommonCartWrapper.CommonCart cart = new CommonCartWrapper.CommonCart();
		cart.version = '3-2-0';
		cart.id = 'some-cart-id';
		cart.pricingRuleGroupCodes = new List<String> { 'PRG1' };

		MockRequestUtil mock = new MockRequestUtil()
			.setResponse('{"actions": [], "cart":' + JSON.serialize(cart) + '}');
		PricingServiceApi.requestUtility = mock;

		Test.startTest();
		PricingServiceApi.PricingResponse response = PricingServiceApi.getPricings(cart);
		Test.stopTest();

		RequestParams rp = mock.requestParams;
		System.assertEquals('POST', rp.method);
		System.assertEquals('/pre/v6/pricings', rp.endpoint);
		System.assertEquals('{"version":"3-2-0","pricingRuleGroupCodes":["PRG1"],"id":"some-cart-id"}', rp.payload);

		System.assertEquals(
			'{"cart":{"version":"3-2-0","sharedData":null,"pricingRuleGroupCodes":["PRG1"],"pricing":null,"items":null,"id":"some-cart-id","holdings":null,"externalIds":null,"customData":null},"actions":[]}',
			Json.serialize(response)
		);
	}

	@IsTest
	public static void getPricingServiceApiVersionTest() {
		CommonCartWrapper.CommonCart cart = new CommonCartWrapper.CommonCart();
		cart.version = '1-0-0';
		String apiVersion = PricingServiceApi.getPricingServiceApiVersion(cart);
		System.assertEquals('v1', apiVersion);

		cart.version = '3-0-0';
		apiVersion = PricingServiceApi.getPricingServiceApiVersion(cart);
		System.assertEquals('v4', apiVersion);

		cart.version = '3-1-0';
		apiVersion = PricingServiceApi.getPricingServiceApiVersion(cart);
		System.assertEquals('v5', apiVersion);

		cart.version = '3-2-0';
		apiVersion = PricingServiceApi.getPricingServiceApiVersion(cart);
		System.assertEquals('v6', apiVersion);

		cart.version = '123-123-123';
		try {
			apiVersion = PricingServiceApi.getPricingServiceApiVersion(cart);
			System.assert(
				false,
				'Default implementation of PricingServiceApi.getPricingServiceApiVersion should throw exception upon invocation if no valid version has been provided.'
			);
		} catch (PsiException.InvalidVersionException e) {
			System.assertEquals('Unsupported common cart version 123-123-123', e.getMessage());
		}
	}

	@IsTest
	public static void getDispatcherRequestUtilInstanceTest() {
		Psi_Options__c options = new Psi_Options__c();
		options.cspsi__dispatcher_service_endpoint__c = '/some-test-endpoint';
		options.cspsi__certificate_name__c = 'test-certificate-name';
		insert options;

		PricingServiceApi.DispatcherRequestUtilWrapper wrapper = PricingServiceApi.getDispatcherRequestUtilInstance();

		System.assertNotEquals(null, wrapper);
		System.assertNotEquals(null, wrapper.dispatcherRequestUtil);
	}

	public class MockRequestUtil implements IRequestUtility {
		private String responseBody { get; set; }
		public RequestParams requestParams { get; set; }

		public MockRequestUtil setResponse(String responseBody) {
			this.responseBody = responseBody;
			return this;
		}

		public HttpResponse sendRequest(String method, String endpoint, String payload) {
			this.requestParams = new RequestParams(method, endpoint, payload);

			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(this.responseBody);
			res.setStatusCode(200);
			return res;
		}
	}

	public class RequestParams {
		public String method { get; set; }
		public String endpoint { get; set; }
		public String payload { get; set; }

		public RequestParams(String method, String endpoint, String payload) {
			this.method = method;
			this.endpoint = endpoint;
			this.payload = payload;
		}
	}
}
