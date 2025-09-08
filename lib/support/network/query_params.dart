class Payload {
  final Map<String, String> _queryParams = {};
  final Map<String, dynamic> _bodyParams = {};

  // Method to add a single query parameter
  Payload addQuery<T>(String key, T value) {
    _queryParams[key] = value.toString();
    return this;
  }

  // Method to add multiple query parameters
  Payload addAllQuery(Map<String, dynamic> params) {
    params.forEach((key, value) {
      _queryParams[key] = value.toString();
    });
    return this;
  }

  // Method to return the query parameters as a map
  Map<String, String> toQueryMap() {
    return _queryParams;
  }

  // Method to add a single body parameter
  Payload addBody<T>(String key, T value) {
    _bodyParams[key] = value;
    return this;
  }

  // Method to add multiple body parameters
  Payload addAllBody(Map<String, dynamic> params) {
    _bodyParams.addAll(params);
    return this;
  }

  // Method to return the body parameters as a map
  Map<String, dynamic> toBodyMap() {
    return _bodyParams;
  }
}
