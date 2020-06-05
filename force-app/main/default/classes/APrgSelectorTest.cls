@IsTest
private class APrgSelectorTest {
	@IsTest
	private static void testImplementation() {
		Test.startTest();

		APrgSelector notImplementedPrgSelector = new MethodNotImplementedPrgSelector();
		try {
			notImplementedPrgSelector.selectPrgs(null, null, null, null, null);
			System.assert (
				false,
				'Default implementation of APrgSelector.selectPrgs should throw exception upon invocation if no method implementation exists.'
			);
		} catch (PsiException.MethodNotImplementedException expected) {
			System.assertEquals(
				'Method not implemented: void selectPrgs(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> prgs)',
				expected.getMessage()
			);
		}

		Test.stopTest();
	}

	private class MethodNotImplementedPrgSelector extends APrgSelector {
	}
}