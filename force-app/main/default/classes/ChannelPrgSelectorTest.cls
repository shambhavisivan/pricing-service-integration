@IsTest
private class ChannelPrgSelectorTest {
	@IsTest
	private static void testPluginReturnsValue() {
		Set<String> prgs = new Set<String>();

		ChannelPrgSelector.Configuration configuration = new ChannelPrgSelector.Configuration();
		configuration.prgsBySalesApp = new Map<String, List<String>> {
			'salesapp1' => new List<String> { 'PRG1', 'PRG2' }
		};
		configuration.version = '1-0-0';
		configuration.exclusive = true;

		ChannelPrgSelector selector = new ChannelPrgSelector();
		selector.configuration = Json.serialize(configuration);

		Test.startTest();
		selector.selectPrgs('salesapp1', null, null, null, prgs);
		Test.stopTest();

		System.assertEquals(2, prgs.size());
		System.assertEquals(new List<String> { 'PRG1', 'PRG2' }, new List<String>(prgs));
	}
}