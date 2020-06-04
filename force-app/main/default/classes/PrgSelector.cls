global with sharing class PrgSelector {

	public static final String PRG_SELECTORS = 'PSI/PrgSelectors';

	global static Set<String> selectPrgs(String salesAppId, User user, String basketId, Map<String, String> salesContext) {
		List<PrgSelectorRegistration> pluginRegistrations = getPluginRegistrations();
		List<Tuple> plugins = instantiatePlugins(pluginRegistrations);

		Set<String> prgs = new Set<String>();

		for (Tuple t : plugins) {
			try {
				LimitsSnapshot ls = new LimitsSnapshot();
				t.plugin.selectPrgs(salesAppId, user, basketId, salesContext, prgs);
				String limitsMessage = getLimitsMsg(ls);
				csutil.Log.info(limitsMessage);
			} catch (Exception e) {
				csutil.Log.warn('Error during plugin "selectPrgs" method invocation in plugin ' + t.className + ': ', e);
			}
		}

		return prgs;
	}

	@TestVisible
	private static List<PrgSelectorRegistration> getPluginRegistrations() {
		List<Object> pluginConfigurations = JsonConfigurationService.getPluginConfigurations(
			PRG_SELECTORS,
			PrgSelectorRegistration.class
		);

		if (pluginConfigurations == null || pluginConfigurations.size() == 0) {
			throw new PsiException.PluginRegistrationException('Missing or invalid plugin registrations for: ' + PRG_SELECTORS);
		}

		return (List<PrgSelectorRegistration>) pluginConfigurations;
	}

	private static List<Tuple> instantiatePlugins(List<PrgSelectorRegistration> prgSelectorRegistrations) {
		List<Tuple> plugins = new List<Tuple>();

		for (PrgSelectorRegistration selectorRegistration : prgSelectorRegistrations) {
			APrgSelector plugin = instantiatePlugin(selectorRegistration.className);
			if (plugin != null) {
				plugin.configuration = selectorRegistration.configuration;
				plugins.add(new Tuple(selectorRegistration.className, plugin));
			}
		}

		return plugins;
	}

	private static APrgSelector instantiatePlugin(String className) {
		Type pluginType = csutil.MiscUtils.findType(className);

		if (pluginType != null) {
			APrgSelector instance = (APrgSelector) pluginType.newInstance();
			return instance;
		}

		return null;
	}

	private static final String limitsMsgFormat = (
		'\n\tTime:\t\t{0}ms since start' +
		'\n\tSOQLs:\t{1} since start\t{2} total' +
		'\n\tDMLs:\t{3} since start\t{4} total' +
		'\n\tCPU:\t{5} since start\t{6} total'
	);

	public static String getLimitsMsg(LimitsSnapshot start) {
		LimitsSnapshot now = new LimitsSnapshot();

		return String.format(
			limitsMsgFormat,
			new String[] {
			String.valueOf(now.ts - start.ts),
			String.valueOf(now.queries - start.queries), String.valueOf(now.queries),
			String.valueOf(now.dmlStatements - start.dmlStatements), String.valueOf(now.dmlStatements),
			String.valueOf(now.cpuTime - start.cpuTime), String.valueOf(now.cpuTime)
		}
		);
	}

	public class LimitsSnapshot {
		public Long ts = System.currentTimeMillis();
		public Integer queries = Limits.getQueries();
		public Integer dmlStatements = Limits.getDMLStatements();
		public Integer cpuTime = Limits.getCpuTime();
	}

	class Tuple {
		String className { get; set;}
		APrgSelector plugin { get; set; }

		Tuple(String className, APrgSelector plugin) {
			this.className = className;
			this.plugin = plugin;
		}
	}
}