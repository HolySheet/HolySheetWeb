import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:HolySheetWeb/src/auth_service.dart';
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
  providers: [ClassProvider(FileService), ClassProvider(SettingsService), ClassProvider(AuthService)],
  exports: [Routes, RoutePaths],
)
class AppComponent implements OnInit {
  final FileService fileService;
  final AuthService authService;
  final Router _router;

  NavListData active;

  Map<String, bool> activeClasses = {};
  final sidebarNav = [
    NavListData('Files', 'folder', RoutePaths.files),
    NavListData('Starred', 'star', RoutePaths.starred),
    NavListData('Trash', 'delete', RoutePaths.trash)
  ];

  AppComponent(this.fileService, this.authService, this._router) {
    active = sidebarNav.firstWhere((data) => data.isDefault, orElse: () => null);
    context['signInChange'] = (bool signedIn) {
      print('Signed in: $signedIn');
    };

    context['userChanged'] = (user) => 'console.log'(user);

    print('Hello ${authService.basicProfile.fullName}!!!!');
  }

  Map<String, bool> getClasses(NavListData navListData) => {
        'active': navListData == active,
        'active-primary': navListData == active,
      };

  void navigate(NavListData navListData) {
    active = navListData;
    _router.navigate(navListData.route.toUrl());
  }

  @override
  Future<void> ngOnInit() async {}
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
