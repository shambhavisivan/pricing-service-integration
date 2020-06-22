global with sharing class PricingServiceApi {

	private static csutil.DispatcherRequestUtil dispatcherRequestUtil {
		get {
			return getDispatcherRequestUtilInstance();
		}
		private set;
	}

	/**
	 * Invokes the PS synchronisation process.
	 */
	global static SyncInProgressResponse synchronise() {
		HttpResponse response = dispatcherRequestUtil.sendRequest(
			'GET',
			'/pre/synchronize-pricings',
			''
		);

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
		HttpResponse response = dispatcherRequestUtil.sendRequest(
			'GET',
			'/pre/synchronizations',
			''
		);

		checkResponseStatusCode(response);

		try {
			String responseBody = response.getBody();
			return (Synchronizations) Json.deserialize(responseBody, Synchronizations.class);
		} catch (Exception e) {
			throw new PsiException.DeserializationException('Could not parse response: ' + e.getMessage());
		}
	}

	private static csutil.DispatcherRequestUtil getDispatcherRequestUtilInstance() {
		if (dispatcherRequestUtil == null) {
			Psi_Options__c options = Psi_Options__c.getInstance(UserInfo.getUserId());

			dispatcherRequestUtil = new csutil.DispatcherRequestUtil(
				options.certificate_name__c,
				options.dispatcher_service_endpoint__c
			);
		}

		return dispatcherRequestUtil;
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

	global class SyncInProgressResponse {
		global Synchronization lastSync { get; set; }
		global Synchronization lastSyncSuccess { get; set; }
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