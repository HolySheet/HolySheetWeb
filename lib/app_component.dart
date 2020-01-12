import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/file_service.dart';
import 'package:HolySheetWeb/src/routes.dart';
import 'package:HolySheetWeb/src/settings_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    routerDirectives,
    FileListComponent,
    NgFor,
    NgIf,
  ],
  providers: [ClassProvider(FileService), ClassProvider(SettingsService)],
  exports: [Routes, RoutePaths],
)
class AppComponent implements OnInit {

  final FileService fileService;

  AppComponent(this.fileService);

  @override
  Future<void> ngOnInit() async {
    print('Authenticating here or whatever');
  }

}
