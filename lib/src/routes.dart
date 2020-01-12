
import 'package:angular_router/angular_router.dart';

import 'file_list/file_list_component.template.dart' as file_list_component;
import 'settings/settings_component.template.dart' as settings_component;

class Routes {
  static final files = RouteDefinition(
    routePath: RoutePaths.files,
    component: file_list_component.FileListComponentNgFactory,
    useAsDefault: true,
  );

  static final settings = RouteDefinition(
    routePath: RoutePaths.settings,
    component: settings_component.SettingsComponentNgFactory,
  );

  static final all = <RouteDefinition>[files, settings];
}

class RoutePaths {
  static final files = RoutePath(path: 'files');
  static final settings = RoutePath(path: 'settings');
}
