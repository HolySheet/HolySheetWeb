import 'dart:html';
import 'dart:js';

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

  final FileService fileService;

  AppComponent(this.fileService);

  @override
  Future<void> ngOnInit() async {
    var id = ClientId('916425013479-6jdls4crv26mhurj43eakbs72f5e1m8t.apps.googleusercontent.com', null);
    var scopes = ['profile', 'email', 'https://www.googleapis.com/auth/drive'];

    await createImplicitBrowserFlow(id, scopes).then((BrowserOAuth2Flow flow) {
      flow.runHybridFlow(force: true).then((hybrid) {
        final code = hybrid.authorizationCode;
        print('code = $code');
        HttpRequest.getString('http://localhost:8090/callback?code=$code');
      });
    });
  }

}
