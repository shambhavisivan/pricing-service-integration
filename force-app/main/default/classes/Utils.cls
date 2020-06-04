public with sharing class Utils {

	public static void validateVersion(String version) {
		if (String.isBlank(version)) {
			throw new PsiException.InvalidVersionException('Missing "version" value');
		}

		Pattern versionPattern = Pattern.compile('[0-9]{1,2}-[0-9]{1,2}-[0-9]{1,2}');
		Matcher versionMatcher = versionPattern.matcher(version);

		if (!versionMatcher.matches()) {
			throw new PsiException.InvalidVersionException('Invalid "version" value: ' + version);
		}
	}
}
