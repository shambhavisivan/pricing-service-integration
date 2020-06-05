@IsTest
global with sharing class PrgSelectorTest {
	@IsTest
	private static void testGetPluginRegistrationsValid() {

		// register a plugin
		PrgSelectorRegistration selector = new PrgSelectorRegistration();
		selector.version = '1-0-0';
		selector.className = TestPrgSelector.class.getName();

		JsonConfigurationService.setPluginConfiguration(PrgSelector.PRG_SELECTORS + '/1', selector);

		Test.startTest();
		List<PrgSelectorRegistration> configItems = PrgSelector.getPluginRegistrations();
		Test.stopTest();

		System.assertEquals(1, configItems.size());
		System.assertEquals(selector.className, configItems[0].className);
	}

	@IsTest
	private static void testGetPluginRegistrationsMissingRegistration() {
		Test.startTest();
		try {
			List<PrgSelectorRegistration> configItems = PrgSelector.getPluginRegistrations();
		} catch (PsiException.PluginRegistrationException expected) {
			System.assertEquals(expected.getMessage(), 'Missing or invalid plugin registrations for: ' + PrgSelector.PRG_SELECTORS);
		}
		Test.stopTest();
	}

	@IsTest
	private static void testSelectPrgs() {
		// register a plugin
		PrgSelectorRegistration selector = new PrgSelectorRegistration();
		selector.className = TestPrgSelector.class.getName();
		selector.version = '1-0-0';

		JsonConfigurationService.setPluginConfiguration(PrgSelector.PRG_SELECTORS + '/1', selector);

		Test.startTest();
		Set<String> prgs = PrgSelector.selectPrgs(null, null, null, null);
		Test.stopTest();

		System.assertEquals(1, prgs.size());
		System.assertEquals('test-prg', prgs.iterator().next());
	}

	global class TestPrgSelector extends APrgSelector {
		global override void selectPrgs(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> prgs) {
			prgs.add('test-prg');
		}
	}
}
