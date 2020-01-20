import 'dart:async';
import 'dart:html';

import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/file_service.dart';
import 'package:HolySheetWeb/src/routes.dart';
import 'package:HolySheetWeb/src/settings_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:googleapis_auth/auth_browser.dart';

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

  AppComponent(this.fileService);

  @override
  Future<void> ngOnInit() async {
    await getIdToken().then((idToken) async {
      print('idToken = $idToken');

      await HttpRequest.postFormData('http://localhost:8090/check', {
        'Authorization': idToken,
      });
    });
  }

  /// Logs in a user
  Future<void> loginUser() async =>
      await createImplicitBrowserFlow(id, scopes).then((BrowserOAuth2Flow flow) {
        flow.runHybridFlow(immediate: false, force: true).then((hybrid) {
          final code = hybrid.authorizationCode;

          HttpRequest.getString('http://localhost:8090/callback?code=$code');
        });
      });

  /// Gets the token. If not null, it should then be sent to :api:/check to
  /// verify it has been stored in the system. If not, the user is not
  /// considered authenticated.
  Future<String> getIdToken() async =>
      await createImplicitBrowserFlow(id, scopes)
          .then((BrowserOAuth2Flow flow) {
        try {
          return flow.obtainAccessCredentialsViaUserConsent(
              immediate: true,
              force: true,
              responseTypes: [
                ResponseType.idToken,
                ResponseType.token
              ]).then((hybrid) => hybrid.idToken);
        } catch (e) {
          print('An error happened, user not signed in');
          return null;
        }
      });
}
