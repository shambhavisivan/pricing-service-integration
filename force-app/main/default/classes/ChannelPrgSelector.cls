global with sharing class ChannelPrgSelector extends APrgSelector {

	global ChannelPrgSelector() {
	}

	global override void selectPrgs(String salesAppId, User user, String basketId, Map<String, String> salesContext, Set<String> prgs) {
		Configuration pluginConfig = (Configuration) Json.deserialize(configuration, Configuration.class);
		pluginConfig.validate();

		List<String> salesAppPrgs = pluginConfig.prgsBySalesApp.get(salesAppId);
		if (salesAppPrgs != null && salesAppPrgs.size() > 0) {
			// clear the prgs if the exclusive flag is set to true
			if (pluginConfig.exclusive == true) {
				prgs.clear();
			}
			prgs.addAll(salesAppPrgs);
		}
	}

	public class Configuration implements csutil.JsonSettings.SelfValidating {
		public String version { get; set; }
		public Map<String, List<String>> prgsBySalesApp { get; set; }
		public Boolean exclusive { get; set; }

		public void validate() {
			Utils.validateVersion(version);

			if (prgsBySalesApp == null || prgsBySalesApp.keySet().size() == 0) {
				throw new PsiException.PluginRegistrationException('Missing "prgsBySalesApp" value');
			}
		}
	}
}
