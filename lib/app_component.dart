import 'dart:html';
import 'dart:js';

import 'package:HolySheetWeb/src/dashboard/dashboard_component.dart';
import 'package:HolySheetWeb/src/dashboard/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/icon/icon_component.dart';
import 'package:HolySheetWeb/src/primary_routes.dart';
import 'package:HolySheetWeb/src/request_utils.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/services/context_service.dart';
import 'package:HolySheetWeb/src/services/file_send_service.dart';
import 'package:HolySheetWeb/src/services/file_service.dart';
import 'package:HolySheetWeb/src/services/settings_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'hs-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    routerDirectives,
    FileListComponent,
    Icon,
    DashboardComponent,
    NgFor,
    NgIf,
    NgClass,
  ],
  providers: [
    ClassProvider(FileService),
    ClassProvider(SettingsService),
    ClassProvider(RequestService),
    ClassProvider(AuthService),
    ClassProvider(ContextService),
    ClassProvider(FileSendService),
  ],
  exports: [Routes, RoutePaths],
)
class AppComponent {
  final FileService fileService;
  final AuthService authService;
  final ContextService contextService;
  final Router _router;
  final ChangeDetectorRef changeRef;

  @Input()
  bool compactNavbar = false;

  AppComponent(this.fileService, this.authService, this.contextService,
      this._router, this.changeRef) {
    context['signInChange'] = (bool signedIn) {
      authService.signedIn = signedIn;
      changeRef
        ..markForCheck()
        ..detectChanges();
      if (signedIn) {
        authService.updateCallbacks();
      }
    };

    context['userChanged'] = (user) => changeRef
      ..markForCheck()
      ..detectChanges();

    authService.basicProfile;

    _router.onRouteActivated.listen((state) {
      compactNavbar = state.routePath.additionalData['compactNavbar'] ?? false;
    });
  }

  void mobileToggle(String selector) => window.document
      .querySelector(selector)
      ?.classes
      ?.toggle('is-active');

  void home() => _router.navigate(RoutePaths.home.path);

  void login() => authService.loginUser().then((d) => print('fuck $d'));

  void logout() {
    authService.logoutUser().then((_) {
      authService.checkSignedIn;
      if (Routes.dashboardPaths.contains(_router.current.routePath.path)) {
        home();
      }

      changeRef
        ..markForCheck()
        ..detectChanges();
    });
  }
}
