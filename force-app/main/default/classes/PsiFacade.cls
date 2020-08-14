global with sharing class PsiFacade extends csutil.ARestController {
	private class SelectPrgsRequestData {
		String salesAppId { get; set; }
		User user { get; set; }
		String basketId { get; set; }
		Map<String, String> salesContext { get; set; }
	}

	global class PrgSelectorV1 extends csutil.ARestController {
		// POST /cspsi/api/v1/prgs/select
		global override void doPost(RestRequest req, RestResponse resp, Map<String, String> routeParams) {
			SelectPrgsRequestData data;
			try {
				data = (SelectPrgsRequestData) JSON.deserialize(
					req.requestBody.toString(),
					SelectPrgsRequestData.class
				);
			} catch (Exception e) {
				// currently not visible, the class is public
				// throw new csutil.RestException.Rest4xxException('Invalid payload: ' + e.getMessage(), 400);
			}

			if (data.user == null) {
				data.user = new User(id = UserInfo.getUserId());
			}

			Set<String> response = PrgSelector.selectPrgs(data.salesAppId, data.user, data.basketId, data.salesContext);

			resp.responseBody = Blob.valueOf(Json.serialize(response));
			resp.statusCode = 200;
		}
	}

	global class PricingAggregatorV1 extends csutil.ARestController {
		// GET /cspsi/api/v1/pricing-aggregator/configuration
		global override void doGet(RestRequest req, RestResponse resp, Map<String, String> routeParams) {
			PricingAggregatorRegistration registration = PricingAggregator.getPluginConfiguration();

			resp.responseBody = Blob.valueOf(Json.serialize(registration));
			resp.statusCode = 200;
		}
	}
}
