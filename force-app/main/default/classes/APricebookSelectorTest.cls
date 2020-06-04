@IsTest
private class APricebookSelectorTest {
	@IsTest
	private static void testImplementation() {
		Test.startTest();

		APricebookSelector notImplementedPricebookSelector = new MethodNotImplementedPricebookSelector();
		try {
			notImplementedPricebookSelector.selectPricebook(null, null, null, null, null);
			System.assert(
				false,
				'Default implementation of APricebookSelector.selectPricebook should throw exception upon invocation if no method implementation exists.'
			);
		} catch (PSIException.MethodNotImplementedException expected) {
			System.assertEquals(
				'Method not implemented: void selectPricebook(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> pricebooks)',
				expected.getMessage()
			);
		}

		Test.stopTest();
	}

	private class MethodNotImplementedPricebookSelector extends APricebookSelector {
	}
}