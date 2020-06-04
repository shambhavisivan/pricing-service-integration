global virtual with sharing class APricebookSelector {

	global APricebookSelector() {
	}

	global virtual void selectPricebook(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> pricebooks) {
		throw new PSIException.MethodNotImplementedException(
			'Method not implemented: void selectPricebook(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> pricebooks)'
		);
	}
}
