public with sharing class JsonConfigurationService {

	public static Object[] getPluginConfigurations(String name, Type objectType) {
		Object[] settings = csutil.JsonSettings.getSettings(name, objectType, null);

		if (settings != null) {
			return settings;
		}

		return null;
	}

	public static void setPluginConfiguration(String name, Object configuration) {
		// TODO: likely to change due to csutil changes, use this for now
		csutil__Json_Settings__c setting = new csutil__Json_Settings__c();
		setting.name = name;
		setting.csutil__json_configuration__c = Json.serializePretty(configuration);

		upsert setting;
	}
}
