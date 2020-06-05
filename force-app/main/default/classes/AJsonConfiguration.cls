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
		if (String.isBlank(version)) {
			throw new PsiException.InvalidVersionException('Missing "version" value');
		}

		Pattern versionPattern = Pattern.compile('[0-9]{1,2}-[0-9]{1,2}-[0-9]{1,2}');
		Matcher versionMatcher = versionPattern.matcher(this.version);

		if (!versionMatcher.matches()) {
			throw new PsiException.InvalidVersionException('Invalid "version" value: ' + this.version);
		}
	}
}