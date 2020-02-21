
import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:angular_router/angular_router.dart';

import 'file_list/file_list_component.template.dart' as file_list_component;
import 'home/home_component.template.dart' as home_component;
import 'settings/settings_component.template.dart' as settings_component;

class Routes {
  static final home = RouteDefinition(
    routePath: RoutePaths.home,
    component: home_component.HomeComponentNgFactory,
  );

  static final files = RouteDefinition(
    routePath: RoutePaths.files,
    additionalData: ListType.Default,
    component: file_list_component.FileListComponentNgFactory,
  );

  static final starred = RouteDefinition(
    routePath: RoutePaths.starred,
    additionalData: ListType.Starred,
    component: file_list_component.FileListComponentNgFactory,
  );

  static final trash = RouteDefinition(
    routePath: RoutePaths.trash,
    additionalData: ListType.Trash,
    component: file_list_component.FileListComponentNgFactory,
  );

  static final settings = RouteDefinition(
    routePath: RoutePaths.settings,
    component: settings_component.SettingsComponentNgFactory,
  );

  static final all = <RouteDefinition>[home, files, starred, trash, settings];
}

class RoutePaths {
  static final home = RoutePath(path: 'home', useAsDefault: true);
  static final files = RoutePath(path: 'files');
  static final starred = RoutePath(path: 'starred');
  static final trash = RoutePath(path: 'trash');
  static final settings = RoutePath(path: 'settings');
}
