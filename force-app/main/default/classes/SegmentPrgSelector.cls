global with sharing class SegmentPrgSelector extends APrgSelector {

	public static final String SEGMENT_RESOLUTION_ERROR = 'SEGMENT_ERROR';
	public static final String SEGMENT_RESOLUTION_BLANK = 'SEGMENT_BLANK';

	global SegmentPrgSelector() {
	}

	global override void selectPrgs(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> prgs) {
		Configuration pluginConfig = (Configuration) Json.deserialize(configuration, Configuration.class);
		pluginConfig.validate();

		String segment = getSegmentValue(basketId, pluginConfig.fieldPath);

		List<String> segmentPrgs = pluginConfig.prgsBySegment.get(segment);
		if (segmentPrgs != null && segmentPrgs.size() > 0) {
			// clear the prgs if the exclusive flag is set to true and prgs exist
			if (pluginConfig.exclusive == true) {
				prgs.clear();
			}

			prgs.addAll(segmentPrgs);
		}
	}

	public class Configuration implements csutil.JsonSettings.SelfValidating {
		public String version { get; set; }
		public String fieldPath { get; set; }
		public Map<String, List<String>> prgsBySegment { get; set; }
		public Boolean exclusive { get; set; }

		public void validate() {
			Utils.validateVersion(version);

			if (String.isBlank(fieldPath)) {
				throw new PsiException.PluginRegistrationException('Missing "fieldPath" value');
			}

			if (prgsBySegment == null || prgsBySegment.keySet().size() == 0) {
				throw new PsiException.PluginRegistrationException('Missing "prgsBySegment" value');
			}
		}
	}

	private String getSegmentValue(String basketId, String fieldPath) {
		String segment;
		try {
			segment = getFieldValue(basketId, fieldPath);
			if (segment == null) {
				segment = SEGMENT_RESOLUTION_BLANK;
			}
		} catch (Exception e) {
			csutil.Log.warn('Segment resolution error: ' + e.getMessage());
			segment = SEGMENT_RESOLUTION_ERROR;
		}

		csutil.Log.debug('Retrieved segment value: ' + segment);
		return segment;
	}

	private String getFieldValue(String sObjId, String fieldPath) {
		Schema.SObjectType sobjectType = ((Id) sObjId).getSObjectType();

		csutil.SOQLBuilder soqlBuilder = new csutil.SOQLBuilder(sobjectType);
		soqlBuilder.selectColumn(fieldPath);
		soqlBuilder.addWhereClauseExpression('id = \'' + String.escapeSingleQuotes(sObjId) + '\'');
		String query = soqlBuilder.getSOQL();

		sObject record = Database.query(query);
		if (record == null) {
			return null;
		}

		Object fieldValue = csutil.SObjectUtils.getSObjectFieldValue(record, fieldPath);
		if (fieldValue == null) {
			return null;
		}

		return (String) fieldValue;
	}
}
