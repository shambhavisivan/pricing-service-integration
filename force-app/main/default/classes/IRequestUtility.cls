public interface IRequestUtility {
    HttpResponse sendRequest(String method, String endpoint, String payload);
}
