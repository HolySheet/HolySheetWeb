import 'dart:async';
import 'dart:html';

import 'package:HolySheetWeb/src/primary_routes.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'download',
  styleUrls: ['download_component.css', '../home/landing_styles.css'],
  templateUrl: 'download_component.html',
  directives: [],
  exports: [],
)
class DownloadComponent {
  final AuthService authService;
  final Router router;

  DownloadComponent(this.authService, this.router);
}
