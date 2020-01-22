import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/file_service.dart';
import 'package:HolySheetWeb/src/js.dart';
import 'package:HolySheetWeb/src/routes.dart';
import 'package:HolySheetWeb/src/settings_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_router/testing.dart';
import 'package:js/js.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    routerDirectives,
    FileListComponent,
    MaterialIconComponent,
    NgFor,
    NgIf,
    NgClass,
  ],
  providers: [ClassProvider(FileService), ClassProvider(SettingsService)],
  exports: [Routes, RoutePaths],
)
class AppComponent implements OnInit {
  final FileService fileService;
  final Router _router;

  NavListData active;

  Map<String, bool> activeClasses = {};
  final sidebarNav = [
    NavListData('Files', 'folder', RoutePaths.files),
    NavListData('Starred', 'star', RoutePaths.starred),
    NavListData('Trash', 'delete', RoutePaths.trash)
  ];

  bool get signedIn => 'auth2.isSignedIn.get'();

  AppComponent(this.fileService, this._router) {
    active = sidebarNav.firstWhere((data) => data.isDefault, orElse: () => null);
    print('HERE!');
    context['signInChange'] = (bool signedIn) {
      print('Signed in: $signedIn');
    };

    context['userChanged'] = (user) => 'console.log'(user);
  }

  Map<String, bool> getClasses(NavListData navListData) => {
        'active': navListData == active,
        'active-primary': navListData == active,
      };

  void navigate(NavListData navListData) {
    active = navListData;
    _router.navigate(navListData.route.toUrl());
  }

//  String _getRouteUrl(RoutePath route, [Map<String, String> parameters]) =>
//      route.toUrl(parameters: parameters);
//
//  void navigate(RoutePath route) =>
//      _router.navigate(_getRouteUrl(route));

  @override
  Future<void> ngOnInit() async {}

  /// Logs in a user
  void loginUser() => 'auth2.grantOfflineAccess'<JsObject>()(
      'then',
      (authResult) => HttpRequest.getString(
          'http://localhost:8090/callback?code=${authResult['code']}'));

  Future<void> checkShit() async {
    if (!signedIn) {
      print('Not signed in!');
      return;
    }

    final token =
        'auth2.currentUser.get'<JsObject>()('getAuthResponse')['access_token'];

    final response = await makeRequest(
      'http://localhost:8090/list',
      query: {'Authorization': token, 'path': ''},
    );

    if (!response.success) {
      print('Request not successful. Has status code of ${response.status}');
      print(response.json);
      return;
    }

    final encoder = JsonEncoder.withIndent('  ');

    print('Request result: ${response.status}');
    var json = response.json;
    print(encoder.convert(json));
  }

  /// Makes a GET request with given headers. Returns JSON.
  static Future<RequestResponse> makeRequest(String url,
      {Map<String, String> query,
      Map<String, String> requestHeaders,
      void onProgress(ProgressEvent e)}) {
    var queryString = query.isNotEmpty ? '?' : '';
    queryString +=
        query.entries.map((entry) => '${entry.key}=${entry.value}').join('&');

    return HttpRequest.request('$url$queryString',
            method: 'GET',
            requestHeaders: requestHeaders,
            onProgress: onProgress)
        .then((HttpRequest xhr) =>
            RequestResponse(xhr.status, jsonDecode(xhr.responseText)));
  }
}

class RequestResponse {
  int status;
  dynamic json;

  bool get success => status == 200;

  RequestResponse(this.status, this.json);
}

class NavListData {
  String name;
  String icon;
  RoutePath route;

  bool get isDefault => route.useAsDefault;

  NavListData(this.name, this.icon, this.route);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavListData &&
          runtimeType == other.runtimeType &&
          route == other.route;

  @override
  int get hashCode => route.hashCode;
}
