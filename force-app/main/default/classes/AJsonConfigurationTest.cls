@IsTest
private class AJsonConfigurationTest {
	@IsTest
	private static void testValidateMethodImplementation() {
		Test.startTest();

		AJsonConfiguration notImplementedConfiguration = new AJsonConfiguration();
		try {
			notImplementedConfiguration.validate();
			System.assert (
				false,
				'Default implementation of AJsonConfiguration.validate should throw exception upon invocation if no method implementation exists.'
			);
		} catch (PsiException.MethodNotImplementedException expected) {
			System.assertEquals(
				'Method not implemented: void validate()',
				expected.getMessage()
			);
		}

		Test.stopTest();
	}

	@IsTest
	private static void testUpgradeToCurrentVersionMethodImplementation() {
		Test.startTest();

		AJsonConfiguration notImplementedConfiguration = new AJsonConfiguration();
		try {
			notImplementedConfiguration.upgradeToCurrentVersion();
			System.assert (
				false,
				'Default implementation of AJsonConfiguration.upgradeToCurrentVersion should throw exception upon invocation if no method implementation exists.'
			);
		} catch (PsiException.MethodNotImplementedException expected) {
			System.assertEquals(
				'Method not implemented: void upgradeToCurrentVersion()',
				expected.getMessage()
			);
		}

		Test.stopTest();
	}

	@IsTest
	private static void testValidateVersionMissingVersion() {
		Test.startTest();

		AJsonConfiguration missingVersion = new AJsonConfiguration();
		try {
			missingVersion.validateVersion();
			System.assert (
				false,
				'Default implementation of AJsonConfiguration.validateVersion() should throw exception upon invocation if no method version value exists.'
			);
		} catch (PsiException.InvalidVersionException expected) {
			System.assertEquals(
				'Missing "version" value',
				expected.getMessage()
			);
		}

		Test.stopTest();
	}

	@IsTest
	private static void testValidateVersionInvalidVersionString() {
		Test.startTest();

		AJsonConfiguration invalidVersion = new AJsonConfiguration();
		invalidVersion.version = 'a-2-3';
		try {
			invalidVersion.validateVersion();
			System.assert (
				false,
				'Default implementation of AJsonConfiguration.validateVersion() should throw exception upon invocation if no valid version value exists.'
			);
		} catch (PsiException.InvalidVersionException expected) {
			System.assertEquals(
				'Invalid "version" value: a-2-3',
				expected.getMessage()
			);
		}

		Test.stopTest();
	}
}