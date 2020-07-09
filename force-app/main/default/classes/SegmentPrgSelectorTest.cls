@IsTest
private class SegmentPrgSelectorTest {
	@TestSetup
	private static void setup() {
		Account acc = new Account(
			name = 'Account Name',
			industry = 'Agriculture',
			rating = null
		);
		insert acc;

		Contact cnt = new Contact(
			accountId = acc.id,
			firstName = 'Test Name',
			lastName = 'Test Surname',
			email = 'email@test.com'
		);
		insert cnt;
	}

	@IsTest
	private static void testPluginReturnsValue() {
		Contact cnt = [select id from contact limit 1];
		String sObjId = cnt.Id;
		Set<String> prgs = new Set<String>();

		SegmentPrgSelector.Configuration configuration = new SegmentPrgSelector.Configuration();
		configuration.fieldPath = 'Account.Industry';
		configuration.prgsBySegment = new Map<String, List<String>> {
			'Agriculture' => new List<String> { 'PRG1', 'PRG2' }
		};
		configuration.version = '1-0-0';
		configuration.exclusive = true;

		SegmentPrgSelector selector = new SegmentPrgSelector();
		selector.configuration = Json.serialize(configuration);

		Test.startTest();
		selector.selectPrgs(null, null, sObjId, null, prgs);
		Test.stopTest();

		System.assertEquals(2, prgs.size());
		System.assertEquals(new List<String> { 'PRG1', 'PRG2' }, new List<String>(prgs));
	}

	@IsTest
	private static void testBlankSegmentValue() {
		Contact cnt = [select id from contact limit 1];
		String sObjId = cnt.Id;
		Set<String> prgs = new Set<String>();

		SegmentPrgSelector.Configuration configuration = new SegmentPrgSelector.Configuration();
		configuration.fieldPath = 'Account.Rating'; // rating field value is null
		configuration.prgsBySegment = new Map<String, List<String>> {
			'Agriculture' => new List<String> { 'PRG1', 'PRG2' },
			SegmentPrgSelector.SEGMENT_RESOLUTION_BLANK => new List<String> { 'PRG3', 'PRG4' }, // these should be returned
			SegmentPrgSelector.SEGMENT_RESOLUTION_ERROR => new List<String> { 'PRG5', 'PRG6' }
		};
		configuration.version = '1-0-0';
		configuration.exclusive = true;

		SegmentPrgSelector selector = new SegmentPrgSelector();
		selector.configuration = Json.serialize(configuration);

		Test.startTest();
		selector.selectPrgs(null, null, sObjId, null, prgs);
		Test.stopTest();

		System.assertEquals(2, prgs.size());
		System.assertEquals(new List<String> { 'PRG3', 'PRG4' }, new List<String>(prgs));
	}

	@IsTest
	private static void testErrorSegmentValue() {
		Contact cnt = [select id from contact limit 1];
		String sObjId = cnt.Id;
		Set<String> prgs = new Set<String>();

		SegmentPrgSelector.Configuration configuration = new SegmentPrgSelector.Configuration();
		configuration.fieldPath = 'Account.NonExistingField'; // NonExistingField field value does not exist
		configuration.prgsBySegment = new Map<String, List<String>> {
			'Agriculture' => new List<String> { 'PRG1', 'PRG2' },
			SegmentPrgSelector.SEGMENT_RESOLUTION_BLANK => new List<String> { 'PRG3', 'PRG4' },
			SegmentPrgSelector.SEGMENT_RESOLUTION_ERROR => new List<String> { 'PRG5', 'PRG6' } // these should be returned
		};
		configuration.version = '1-0-0';
		configuration.exclusive = true;

		SegmentPrgSelector selector = new SegmentPrgSelector();
		selector.configuration = Json.serialize(configuration);

		Test.startTest();
		selector.selectPrgs(null, null, sObjId, null, prgs);
		Test.stopTest();

		System.assertEquals(2, prgs.size());
		System.assertEquals(new List<String> { 'PRG5', 'PRG6' }, new List<String>(prgs));
	}
}