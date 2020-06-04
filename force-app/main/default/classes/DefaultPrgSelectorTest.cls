@IsTest
private class DefaultPrgSelectorTest {
	@IsTest
	private static void testPluginReturnsPrgCode() {
		DefaultPrgSelector selector = new DefaultPrgSelector();
		DefaultPrgSelector.Configuration configuration = new DefaultPrgSelector.Configuration();
		configuration.prgCodes = new List<String> {'PRG1'};
		configuration.version = '1-0-0';
		selector.configuration = Json.serialize(configuration);

		Set<String> prgs = new Set<String>();
		Test.startTest();
		selector.selectPrgs(null, null, null, null, prgs);
		Test.stopTest();

		System.assertEquals(1, prgs.size());
		System.assertEquals('PRG1', prgs.iterator().next());
	}

	@IsTest
	private static void testPluginAddsPrgCodes() {
		DefaultPrgSelector selector = new DefaultPrgSelector();
		DefaultPrgSelector.Configuration configuration = new DefaultPrgSelector.Configuration();
		configuration.prgCodes = new List<String> { 'PRG2', 'PRG3' };
		configuration.version = '1-0-0';
		selector.configuration = Json.serialize(configuration);

		Set<String> prgs = new Set<String> { 'PRG1' };

		Test.startTest();
		selector.selectPrgs(null, null, null, null, prgs);
		Test.stopTest();

		System.assertEquals(3, prgs.size());
		System.assertEquals(new List<String> { 'PRG1', 'PRG2', 'PRG3' }, new List<String>(prgs));
	}

	@IsTest
	private static void testPluginMissingVersion() {
		DefaultPrgSelector selector = new DefaultPrgSelector();
		DefaultPrgSelector.Configuration configuration = new DefaultPrgSelector.Configuration();
		configuration.prgCodes = new List<String> {'PRG1'};
		selector.configuration = Json.serialize(configuration);

		Set<String> prgs = new Set<String>();

		Test.startTest();
		try {
			selector.selectPrgs(null, null, null, null, prgs);
			System.assert (
				false,
				'DefaultPrgSelector.selectPrgs should throw exception upon invocation a "version" value does not exist.'
			);
		} catch (PsiException.InvalidVersionException expected) {
			System.assertEquals(
				'Missing "version" value',
				expected.getMessage()
			);
		}
		Test.stopTest();
	}
}