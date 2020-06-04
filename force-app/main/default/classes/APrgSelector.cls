global virtual with sharing class APrgSelector {

	global String configuration { get; set; }

	global APrgSelector() {
	}

	global virtual void selectPrgs(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> prgs) {
		throw new PsiException.MethodNotImplementedException(
			'Method not implemented: void selectPrgs(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> prgs)'
		);
	}
}
