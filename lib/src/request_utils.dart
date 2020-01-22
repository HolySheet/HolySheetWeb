import 'dart:async';
import 'dart:convert';
import 'dart:html';

const BASE_URL = 'http://localhost:8090';

/// Makes a GET request with given headers. Returns JSON.
Future<RequestResponse> makeRequest(String url,
    {String baseUrl = BASE_URL,
    Map<String, String> query,
    Map<String, String> requestHeaders,
    void onProgress(ProgressEvent e)}) {
  var queryString = query.isNotEmpty ? '?' : '';
  queryString +=
      query.entries.map((entry) => '${entry.key}=${entry.value}').join('&');

  return HttpRequest.request('$baseUrl$url$queryString',
          method: 'GET', requestHeaders: requestHeaders, onProgress: onProgress)
      .then((HttpRequest xhr) => RequestResponse(xhr.status, jsonDecode(xhr.responseText)));
}

class RequestResponse {
  int status;
  dynamic json;

  bool get success => status == 200;

  RequestResponse(this.status, this.json);
}
