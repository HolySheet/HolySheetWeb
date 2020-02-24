import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:HolySheetWeb/src/constants.dart';
import 'package:HolySheetWeb/src/request_objects.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:angular/angular.dart';
import 'js.dart';

class FetchedList {
  List<FetchedFile> files;
  List<String> folders;

  FetchedList([this.files = const [], this.folders = const []]);
}

@Injectable()
class RequestService {
  final AuthService authService;

  RequestService(this.authService);

  /// Makes a GET request with given headers. Returns JSON.
  Future<RequestResponse> makeRequest(String url,
          {String baseUrl = BASE_URL,
          Map<String, String> query,
          Map<String, String> requestHeaders,
          void onProgress(ProgressEvent e)}) =>
      HttpRequest.request('$baseUrl$url${joinQuery(query)}',
              method: 'GET',
              requestHeaders: requestHeaders,
              onProgress: onProgress)
          .then((HttpRequest xhr) =>
              RequestResponse(xhr.status, jsonDecode(xhr.responseText)));

  Future<RequestResponse> makeAuthedRequest(String url,
          {String baseUrl = BASE_URL,
          Map<String, dynamic> query = const {},
          Map<String, String> requestHeaders = const {}}) async =>
      makeRequest(url,
          baseUrl: baseUrl,
          query: query
              .map((k, v) => MapEntry(k, Uri.encodeComponent('${v ?? ''}'))),
          requestHeaders: {
            ...requestHeaders,
            ...{'Authorization': authService.accessToken}
          });

  void downloadRequest(String url,
      {String baseUrl = BASE_URL, Map<String, dynamic> query = const {}}) {
    final body = document.querySelector('body');
    final anchor = AnchorElement(
        href: '$baseUrl$url${joinQuery(query..addAll({
            'Authorization': authService.accessToken
          }))}');
    anchor.classes = ['downloader'];
    anchor.download = 'test';
    body.append(anchor);
    anchor.click();
  }

  String joinQuery(Map<String, dynamic> query) =>
      (query.isNotEmpty ? '?' : '') +
      query.entries.map((entry) => '${entry.key}=${entry.value}').join('&');

  Future<FetchedList> listFiles(
      {String path = '', bool starred = false, bool trashed = false}) async {
    var response = await makeAuthedRequest('/list',
        query: {'path': path, 'starred': starred, 'trashed': trashed});

    if (!response.success) {
      throw 'List request not successful. Code ${response.status}\n${response.json}';
    }

    return FetchedList(List.of(response.json['files'])
        .map<FetchedFile>((item) => FetchedFile.fromJson(item)).toList(),
        response.json['folders'].cast<String>()..remove(''));
  }

  Future<void> deleteFiles(List<FetchedFile> files, [bool permanent = false]) =>
      makeAuthedRequest('/delete',
          query: {'id': getIdList(files), 'permanent': permanent});

  Future<void> restoreFiles(List<FetchedFile> files) =>
      makeAuthedRequest('/restore', query: {'id': getIdList(files)});

  Future<void> starFiles(List<FetchedFile> files, bool starred) =>
      makeAuthedRequest('/star',
          query: {'id': getIdList(files), 'starred': starred.toString()});

  void downloadFile(FetchedFile file) =>
      downloadRequest('/download', query: {'id': file.id});

  Future<void> moveFiles(List<FetchedFile> files, String path) =>
      makeAuthedRequest('/move', query: {'id': getIdList(files), 'path': path});

  Future<void> createFolder(String path) =>
      makeAuthedRequest('/createfolder', query: {'path': path});

  String getIdList(List<FetchedFile> files) =>
      files.map((file) => file.id).join(',');
}

class RequestResponse {
  int status;
  dynamic json;

  bool get success => status == 200;

  RequestResponse(this.status, this.json);
}
