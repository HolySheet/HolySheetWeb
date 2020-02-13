import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:HolySheetWeb/src/constants.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/request_objects.dart';
import 'package:angular/angular.dart';

@Injectable()
class RequestService {
  final AuthService authService;

  RequestService(this.authService);

  /// Makes a GET request with given headers. Returns JSON.
  Future<RequestResponse> makeRequest(String url,
      {String baseUrl = 'https://$API_URL',
      Map<String, String> query,
      Map<String, String> requestHeaders,
      void onProgress(ProgressEvent e)}) {
    var queryString = query.isNotEmpty ? '?' : '';
    queryString +=
        query.entries.map((entry) => '${entry.key}=${entry.value}').join('&');

    return HttpRequest.request('$baseUrl$url$queryString',
            method: 'GET',
            requestHeaders: requestHeaders,
            onProgress: onProgress)
        .then((HttpRequest xhr) =>
            RequestResponse(xhr.status, jsonDecode(xhr.responseText)));
  }

  Future<RequestResponse> makeAuthedRequest(String url,
          {String baseUrl = 'https://$API_URL',
          Map<String, dynamic> query = const {},
          Map<String, String> requestHeaders = const {}}) async =>
      makeRequest(url,
          baseUrl: baseUrl,
          query: query.map((k, v) => MapEntry(k, '${v ?? ''}')),
          requestHeaders: {
            ...requestHeaders,
            ...{'Authorization': authService.accessToken}
          });

  Future<List<FetchedFile>> listFiles(
      {String path = '', bool starred = false, bool trashed = false}) async {
    var response = await makeAuthedRequest('/list',
        query: {'path': path, 'starred': starred, 'trashed': trashed});

    if (!response.success) {
      throw ('List request not successful. Code ${response.status}\n${response.json}');
    }

    print(response.json);
    return List.of(response.json)
        .map((item) => FetchedFile.fromJson(item))
        .toList()
          ..add(FetchedFile(
              'Movies', '', '', true, 0, 0, 0, true, '', '', false, false));
  }

  Future<void> deleteFiles(List<FetchedFile> files, [bool permanent = false]) =>
      makeAuthedRequest('/delete', query: {
        'id': files.map((file) => file.id).join(','),
        'permanent': permanent
      });

  Future<void> restoreFiles(List<FetchedFile> files) =>
      makeAuthedRequest('/restore',
          query: {'id': files.map((file) => file.id).join(',')});

  Future<void> starFiles(List<FetchedFile> files, bool starred) =>
      makeAuthedRequest('/star', query: {
        'id': files.map((file) => file.id).join(','),
        'starred': starred.toString()
      });
}

class RequestResponse {
  int status;
  dynamic json;

  bool get success => status == 200;

  RequestResponse(this.status, this.json);
}
