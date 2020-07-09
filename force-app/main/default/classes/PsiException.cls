global virtual with sharing class PsiException extends Exception {

	public class MethodNotImplementedException extends PsiException {}
	public class PluginRegistrationException extends PsiException {}
	public class PluginExecutionException extends PsiException {}
	public class InvalidVersionException extends PsiException {}
}