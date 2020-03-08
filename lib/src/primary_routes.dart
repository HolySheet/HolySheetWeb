import 'package:HolySheetWeb/src/dashboard/file_list/file_list_component.dart';
import 'package:angular_router/angular_router.dart';

import 'dashboard/dashboard_component.template.dart' as dashboard_component;
import 'dashboard/file_list/file_list_component.template.dart'
    as file_list_component;
import 'error/error_component.template.dart' as error_component;
import 'home/home_component.template.dart' as home_component;
import 'download/download_component.template.dart' as download_component;

class Routes {
  static final home = RouteDefinition(
      routePath: RoutePaths.home,
      component: home_component.HomeComponentNgFactory,
      additionalData: {
        'compactNavbar': true
      });

  static final download = RouteDefinition(
      routePath: RoutePaths.download,
      component: download_component.DownloadComponentNgFactory,
      additionalData: {
        'compactNavbar': true
      });

  static final files = RouteDefinition(
    routePath: RoutePaths.files,
    additionalData: {
      'listType': ListType.Default,
    },
    component: file_list_component.FileListComponentNgFactory,
  );

  static final starred = RouteDefinition(
    routePath: RoutePaths.starred,
    additionalData: {
      'listType': ListType.Starred,
    },
    component: file_list_component.FileListComponentNgFactory,
  );

  static final trash = RouteDefinition(
    routePath: RoutePaths.trash,
    additionalData: {
      'listType': ListType.Trash,
    },
    component: file_list_component.FileListComponentNgFactory,
  );

  static final error404 = RouteDefinition(
    path: '.+',
    additionalData: {},
    component: error_component.ErrorComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    home,
    download,
    files,
    starred,
    trash,
    error404
  ];

  // Pages in the dashboard will be left when logged out
  static final dashboard = <RouteDefinition>[files, starred, trash];

  static List<String> get dashboardPaths => dashboard.map((def) => def.path).toList();
}

class RoutePaths {
  static final home = RoutePath(path: '/', useAsDefault: true);
  static final download = RoutePath(path: 'download');
  static final files = RoutePath(path: '/files');
  static final starred = RoutePath(path: '/starred');
  static final trash = RoutePath(path: '/trash');
}
