
import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:angular_router/angular_router.dart';

import 'file_list/file_list_component.template.dart' as file_list_component;
import 'home/home_component.template.dart' as home_component;
import 'dashboard/dashboard_component.template.dart' as dashboard_component;

class Routes {
  static final home = RouteDefinition(
    routePath: RoutePaths.home,
    component: home_component.HomeComponentNgFactory,
    additionalData: {
      // By default false
      'compactNavbar': true
    }
  );

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

  static final all = <RouteDefinition>[home, files, starred, trash];
}

class RoutePaths {
  static final home = RoutePath(path: 'home', useAsDefault: true);
  static final files = RoutePath(path: 'files');
  static final starred = RoutePath(path: 'starred');
  static final trash = RoutePath(path: 'trash');
}
