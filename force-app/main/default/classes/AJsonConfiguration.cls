global virtual with sharing class AJsonConfiguration implements csutil.JsonSettings.SelfValidating {

	public String version { get; set; }

	public virtual void validate() {
		throw new PsiException.MethodNotImplementedException(
			'Method not implemented: void validate()'
		);
	}

	public virtual void upgradeToCurrentVersion() {
		throw new PsiException.MethodNotImplementedException(
			'Method not implemented: void upgradeToCurrentVersion()'
		);
	}

	public void validateVersion() {
		Utils.validateVersion(version);
	}
}