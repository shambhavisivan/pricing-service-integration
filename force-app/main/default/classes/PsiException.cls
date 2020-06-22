global virtual with sharing class PsiException extends Exception {

	public class MethodNotImplementedException extends PsiException {}
	public class PluginRegistrationException extends PsiException {}
	public class PluginExecutionException extends PsiException {}
	public class InvalidVersionException extends PsiException {}
	public class DeserializationException extends PsiException {}

	public class Rest4xxException extends PsiException {
		Integer statusCode { get; set; }

		public Rest4xxException(String message, Integer statusCode) {
			this.setMessage(message);
			this.statusCode = statusCode;
		}
	}
	public class Rest5xxException extends PsiException {
		Integer statusCode { get; set; }

		public Rest5xxException(String message, Integer statusCode) {
			this.setMessage(message);
			this.statusCode = statusCode;
		}
	}
}