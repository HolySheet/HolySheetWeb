import 'dart:async';
import 'dart:html';

import 'package:HolySheetWeb/src/fetched_file.dart';
import 'package:HolySheetWeb/src/file_service.dart';
import 'package:HolySheetWeb/src/settings_service.dart';
import 'package:angular/angular.dart';

@Component(
  selector: 'settings',
  styleUrls: ['settings_component.css'],
  templateUrl: 'settings_component.html',
  directives: [
    NgFor,
    NgIf,
  ],
)
class SettingsComponent implements OnInit {
  final SettingsService settingsService;

  SettingsComponent(this.settingsService);

  @override
  Future<Null> ngOnInit() async {
  }
}
