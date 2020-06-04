global with sharing class DefaultPrgSelector extends APrgSelector {

	global DefaultPrgSelector() {
	}

	global override void selectPrgs(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> prgs) {
		Configuration pluginConfig = (Configuration) Json.deserialize(configuration, Configuration.class);
		pluginConfig.validate();

		prgs.addAll(pluginConfig.prgCodes);
	}

	public class Configuration implements csutil.JsonSettings.SelfValidating {
		public String version { get; set; }
		public List<String> prgCodes { get; set; }

		public void validate() {
			Utils.validateVersion(version);
		}
	}
}
