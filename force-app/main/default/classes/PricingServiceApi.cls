global with sharing class PricingServiceApi {
	@TestVisible
	private static IRequestUtility requestUtility {
		get {
			if (requestUtility == null) {
				requestUtility = getDispatcherRequestUtilInstance();
			}
			return requestUtility;
		}
		private set;
	}

	/**
	 * Invokes the PS synchronisation process.
	 */
	global static SyncInProgressResponse synchronise() {
		HttpResponse response = requestUtility.sendRequest('GET', '/pre/synchronize-pricings', '');

		checkResponseStatusCode(response);

		try {
			String responseBody = response.getBody();
			return (SyncInProgressResponse) Json.deserialize(responseBody, SyncInProgressResponse.class);
		} catch (Exception e) {
			throw new PsiException.DeserializationException('Could not parse response: ' + e.getMessage());
		}
	}

	/**
	 * Returns the results of last synchronisation attempts.
	 */
	global static Synchronizations getLastSynchronisations() {
		HttpResponse response = requestUtility.sendRequest('GET', '/pre/synchronizations', '');

		checkResponseStatusCode(response);

		try {
			String responseBody = response.getBody();
			return (Synchronizations) Json.deserialize(responseBody, Synchronizations.class);
		} catch (Exception e) {
			throw new PsiException.DeserializationException('Could not parse response: ' + e.getMessage());
		}
	}

	/**
	 * Sends the common cart to PRE to get pricing information.
	 */
	global static CommonCartWrapper.CommonCart getPricings(CommonCartWrapper.CommonCart cart) {
		String apiVersion = getPricingServiceApiVersion(cart);

		HttpResponse response = requestUtility.sendRequest(
			'POST',
			String.format('/pre/{0}/pricings', new List<String> { apiVersion }),
			Json.serialize(cart, true) // remove all null values from the serialized JSON
		);

		checkResponseStatusCode(response);

		try {
			String responseBody = response.getBody();
			return (CommonCartWrapper.CommonCart) Json.deserialize(responseBody, CommonCartWrapper.CommonCart.class);
		} catch (Exception e) {
			throw new PsiException.DeserializationException('Could not parse response: ' + e.getMessage());
		}
	}

	private static void checkResponseStatusCode(HttpResponse response) {
		String message = response.getStatus();
		Integer statusCode = response.getStatusCode();

		if (statusCode >= 400 && statusCode < 500) {
			throw new PsiException.Rest4xxException(message, statusCode);
		} else if (statusCode >= 500 && statusCode < 600) {
			throw new PsiException.Rest5xxException(message, statusCode);
		}
	}

	@TestVisible
	private static String getPricingServiceApiVersion(CommonCartWrapper.CommonCart cart) {
		if (cart.version == '1-0-0') {
			return 'v1';
		} else if (cart.version == '3-0-0') {
			return 'v4';
		} else if (cart.version == '3-1-0') {
			return 'v5';
		} else if (cart.version == '3-2-0') {
			return 'v6';
		} else {
			throw new PsiException.InvalidVersionException('Unsupported common cart version ' + cart.version);
		}
	}

	@TestVisible
	private static DispatcherRequestUtilWrapper getDispatcherRequestUtilInstance() {
		Psi_Options__c options = Psi_Options__c.getInstance(UserInfo.getUserId());

		csutil.DispatcherRequestUtil dispatcherRequestUtil = new csutil.DispatcherRequestUtil(
			options.certificate_name__c,
			options.dispatcher_service_endpoint__c
		);

		return new DispatcherRequestUtilWrapper(dispatcherRequestUtil);
	}

	public class DispatcherRequestUtilWrapper implements IRequestUtility {
		@TestVisible
		private csutil.DispatcherRequestUtil dispatcherRequestUtil { get; set; }

		DispatcherRequestUtilWrapper(csutil.DispatcherRequestUtil util) {
			this.dispatcherRequestUtil = util;
		}

		public HttpResponse sendRequest(String method, String endpoint, String payload) {
			if (csutil.Log.isDebugEnabled) {
				String message = 'Sending request: ' + method + ' ' + endpoint;
				if (String.isNotBlank(payload)) {
					message += '\nPayload:\n' + payload;
				}
				csutil.Log.debug(message);
			}

			return dispatcherRequestUtil.sendRequest(method, endpoint, payload);
		}
	}

	global class SyncInProgressResponse {
		global String lastSync { get; set; }
		global String lastSyncSuccess { get; set; }
		global String message { get; set; }
	}

	global class Synchronizations {
		global List<Synchronization> results { get; set; }
	}

	global class Synchronization {
		global String createdAt { get; set; }
		private String created_at {
			get;
			set {
				createdAt = value;
			}
		}
		global String updatedAt { get; set; }
		private String updated_at {
			get;
			set {
				updatedAt = value;
			}
		}

		global String catalogueId { get; set; }
		global Boolean success { get; set; }
		global String message { get; set; }
	}
}
