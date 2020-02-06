import 'dart:async';
import 'dart:html';

import 'package:HolySheetWeb/src/routes.dart';
import 'package:HolySheetWeb/src/services/file_service.dart';
import 'package:HolySheetWeb/src/services/settings_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'home',
  styleUrls: ['home_component.css'],
  templateUrl: 'home_component.html',
  directives: [
    NgFor,
    NgIf,
  ],
)
class HomeComponent implements OnInit {
  final SettingsService settingsService;
  final Router _router;

  HomeComponent(this.settingsService, this._router);

  @override
  Future<Null> ngOnInit() async {
  }

  void goToFiles() {
    _router.navigate(RoutePaths.files.path);
  }
}
