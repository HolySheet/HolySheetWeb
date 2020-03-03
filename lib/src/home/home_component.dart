import 'dart:async';

import 'package:HolySheetWeb/src/routes.dart';
import 'package:HolySheetWeb/src/js.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'home',
  styleUrls: ['home_component.css'],
  templateUrl: 'home_component.html',
  directives: [
    NgFor,
    NgIf,
    MaterialIconComponent,
  ],
)
class HomeComponent implements OnInit {
  final AuthService authService;
  final Router _router;

  HomeComponent(this.authService, this._router);

  @override
  Future<Null> ngOnInit() async {
  }

  void goToFiles() {
    _router.navigate(RoutePaths.files.path);
  }

  void launch() {
    if (authService.checkSignedIn) {
      _router.navigate(RoutePaths.files.path);
    } else {
      authService.loginUser().then((user) {
        if (authService.checkSignedIn) {
          _router.navigate(RoutePaths.files.path);
        }
      });
    }
  }
}
