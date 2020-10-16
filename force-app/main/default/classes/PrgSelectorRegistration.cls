global with sharing class PrgSelectorRegistration extends AJsonConfiguration {
	global String className { get; set; }
	global String configuration { get; set; }

	global PrgSelectorRegistration() {
	}

	global override void validate() {
		validateVersion();
		validateClassName();
	}

	private void validateClassName() {
		if (String.isBlank(className)) {
			throw new PsiException.PluginRegistrationException('Missing "className" value');
		}

		Type classType = csutil.MiscUtils.findType(className);
		if (classType == null) {
			throw new PsiException.PluginRegistrationException('Could not find apex class: ' + className);
		}

		Object classInstance = classType.newInstance();
		Boolean isInstance = classInstance instanceof APrgSelector;
		if (!isInstance) {
			throw new PsiException.PluginRegistrationException('Class does not extend the "APrgSelector" class');
		}
	}
}
