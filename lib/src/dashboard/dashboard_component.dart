import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/modal/modal_component.dart';
import 'package:HolySheetWeb/src/routes.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/services/context_service.dart';
import 'package:HolySheetWeb/src/services/file_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

/// The dashboard simply provides sidebar navigation and whatever other stuff is
/// needed for a (usually) authed user to use the service.
@Component(
  selector: 'dashboard',
  styleUrls: ['dashboard_component.css'],
  templateUrl: 'dashboard_component.html',
  directives: [
    NgFor,
    NgIf,
    FileListComponent,
    HSModalComponent,
    MaterialIconComponent,
    NgClass,
  ],
  exports: [Routes, RoutePaths],
)
class DashboardComponent implements OnInit {
  final FileService fileService;
  final AuthService authService;
  final ContextService contextService;
  final Router _router;
  final ChangeDetectorRef changeRef;

  @ViewChild('shit')
  set outlet(HtmlElement out) {
    final outlet = out as RouterOutlet;
    print('setting out! $outlet');
    _router.registerRootOutlet(outlet);
  }
//  RouterOutlet outlet;

  NavListData active;

  Map<String, bool> activeClasses = {};
  final sidebarNav = [
    NavListData('Files', 'folder', RoutePaths.files),
    NavListData('Starred', 'star', RoutePaths.starred),
    NavListData('Trash', 'delete', RoutePaths.trash)
  ];

  DashboardComponent(this.fileService, this.authService, this.contextService,
      this._router, this.changeRef) {
    active =
        sidebarNav.firstWhere((data) => data.isDefault, orElse: () => null);

    context['signInChange'] = (bool signedIn) {
      print('Signed in: ${authService.signedIn = signedIn}');
      if (signedIn) {
        changeRef
          ..markForCheck()
          ..detectChanges();
        authService.updateCallbacks();
      }
    };

    context['userChanged'] = (user) => changeRef
      ..markForCheck()
      ..detectChanges();

    _router.onRouteActivated.listen((state) {
      var activeNav = sidebarNav.firstWhere(
              (data) => data.route.path == state.routePath.path,
          orElse: () => null);
      if (activeNav != null) {
        active = activeNav;
      }
    });
  }

  Map<String, bool> getClasses(NavListData navListData) => {
    'is-active': navListData == active,
    'menu-item-primary': navListData == active,
  };

  void navigate(NavListData navListData) {
    active = navListData;
    _router.navigate(navListData.route.toUrl());
  }

  void mobileToggle(String selector) => document
      .querySelector(selector)
      ?.classes
//      .toggleAll(['d-none', 'sidebar-mobile']);
      ?.toggle('is-active');

  void toggleSidebar() => document.getElementById('sidebar')?.classes?.toggle('is-collapsed');

  void closeMobileSidebar() => mobileToggle('#sidebar-mobile');

  void sidebarExit(MouseEvent event) {
    if ((event.target as HtmlElement).id == 'sidebar-mobile') {
      closeMobileSidebar();
    }
  }

  void home() => _router.navigate(RoutePaths.home.path);

  void login() => authService.loginUser();

  void logout() {
    authService.logoutUser();
    home();
  }

  @override
  void ngOnInit() {
    contextService.init();

//    print('outlet: $outlet');

//    _router.registerRootOutlet(outlet);
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
