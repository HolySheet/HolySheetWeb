import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/services/context_service.dart';
import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/services/file_service.dart';
import 'package:HolySheetWeb/src/js.dart';
import 'package:HolySheetWeb/src/request_utils.dart';
import 'package:HolySheetWeb/src/routes.dart';
import 'package:HolySheetWeb/src/services/settings_service.dart';
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
  providers: [
    ClassProvider(FileService),
    ClassProvider(SettingsService),
    ClassProvider(RequestService),
    ClassProvider(AuthService),
    ClassProvider(ContextService),
  ],
  exports: [Routes, RoutePaths],
)
class AppComponent implements OnInit, OnDestroy {
  final FileService fileService;
  final AuthService authService;
  final ContextService contextService;
  final Router _router;

  NavListData active;

  bool showNavigation = false;

  Map<String, bool> activeClasses = {};
  final settingsNav = NavListData('Settings', '', RoutePaths.settings);
  final sidebarNav = [
    NavListData('Files', 'folder', RoutePaths.files),
    NavListData('Starred', 'star', RoutePaths.starred),
    NavListData('Trash', 'delete', RoutePaths.trash)
  ];

  AppComponent(this.fileService, this.authService, this.contextService, this._router) {
//    authService.loginUser();
    active =
        sidebarNav.firstWhere((data) => data.isDefault, orElse: () => null);

    context['signInChange'] = (bool signedIn) {
      print('Signed in: ${authService.signedIn = signedIn}');
    };

    context['userChanged'] = (user) {
      authService.signedIn = user != null;
      print('Changed user!!! $user');
      'console.log'('Hello ${authService.basicProfile?.fullName ?? 'unknown'}!');
    };

    'console.log'('Hello ${authService.basicProfile?.fullName ?? 'unknown'}!');

    _router.onRouteActivated.listen((state) {
      var shit = [settingsNav, ...sidebarNav].firstWhere((data) => data.route.path == state.routePath.path, orElse: () => null);
      if (showNavigation = shit != null) {
        active = shit;
      }
    });
  }

  void login() => authService.loginUser();

  void logout() {
    authService.logoutUser();
    home();
  }

  void home() => _router.navigate(RoutePaths.home.path);

  Map<String, bool> getClasses(NavListData navListData) => {
        'is-active': navListData == active,
        'menu-item-primary': navListData == active,
      };

  void navigate(NavListData navListData) {
    active = navListData;
    _router.navigate(navListData.route.toUrl());
  }

  void mobileToggle(String selector) =>
      document.querySelector(selector).classes.toggleAll(['d-none', 'sidebar-mobile']);

  @override
  void ngOnInit() {
    contextService.init();
  }

  @override
  void ngOnDestroy() {
   contextService.destroy();
  }
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
