import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/file_service.dart';
import 'package:HolySheetWeb/src/js.dart';
import 'package:HolySheetWeb/src/routes.dart';
import 'package:HolySheetWeb/src/settings_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:googleapis_auth/auth_browser.dart';
import 'package:js/js.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    routerDirectives,
    FileListComponent,
    NgFor,
    NgIf,
  ],
  providers: [ClassProvider(FileService), ClassProvider(SettingsService)],
  exports: [Routes, RoutePaths],
)
class AppComponent implements OnInit {
  final id = ClientId(
      '916425013479-6jdls4crv26mhurj43eakbs72f5e1m8t.apps.googleusercontent.com',
      null);
  final scopes = [
    'openid',
    'profile',
    'email',
    'https://www.googleapis.com/auth/drive'
  ];

  final FileService fileService;

  bool get signedIn => 'auth2.isSignedIn.get'();

  AppComponent(this.fileService) {
    context['signInChange'] = (bool signedIn) {
      print('Signed in: $signedIn');
    };

    context['userChanged'] = (user) => 'console.log'(user);
  }

  @override
  Future<void> ngOnInit() async {}

  /// Logs in a user
  void loginUser() => 'auth2.grantOfflineAccess'<JsObject>()(
      'then',
      (authResult) => HttpRequest.getString(
          'http://localhost:8090/callback?code=${authResult['code']}'));

  /// Checks if a token is valid. To be removed soon
  void checkShit() {
    if (!signedIn) {
      print('Not signed in!');
      return;
    }

    final token =
        'auth2.currentUser.get'<JsObject>()('getAuthResponse')['id_token'];
    'console.log'(token);

    HttpRequest.postFormData(
        'http://localhost:8090/check', {'Authorization': token});
  }
}
