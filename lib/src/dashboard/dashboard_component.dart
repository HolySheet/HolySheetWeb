import 'dart:html';

import 'package:HolySheetWeb/src/dashboard/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/icon/icon_component.dart';
import 'package:HolySheetWeb/src/modal/modal_component.dart';
import 'package:HolySheetWeb/src/primary_routes.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/services/context_service.dart';
import 'package:HolySheetWeb/src/services/file_service.dart';
import 'package:angular/angular.dart';
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
    Icon,
    NgClass,
  ],
  exports: [Routes, RoutePaths],
)
class DashboardComponent implements OnInit, OnDestroy {
  final FileService fileService;
  final AuthService authService;
  final ContextService contextService;
  final Router _router;
  final ChangeDetectorRef changeRef;

  @Input()
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

    _router.onRouteActivated.listen((state) {
      var activeNav = sidebarNav.firstWhere(
              (data) => data.route.path == state.routePath.path,
          orElse: () => null);
      if (activeNav != null) {
        active = activeNav;
        changeRef.markForCheck();
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
      ?.toggle('is-active');

  void toggleSidebar() => document.getElementById('sidebar')?.classes?.toggle('is-collapsed');

  void closeMobileSidebar() => mobileToggle('#sidebar-mobile');

  void sidebarExit(MouseEvent event) {
    if ((event.target as HtmlElement).id == 'sidebar-mobile') {
      closeMobileSidebar();
    }
  }

  void home() => _router.navigate(RoutePaths.home.path);

  void login() => authService.loginUser().then((d) => print('fuck $d'));

  void logout() {
    authService.logoutUser();
    home();
  }

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
