import 'package:HolySheetWeb/src/file_service.dart';
import 'package:HolySheetWeb/src/sidebar/file_list_component.dart';
import 'package:angular/angular.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [
    FileListComponent,
    NgFor,
    NgIf,
  ],
  providers: [ClassProvider(FileService)],
)
class AppComponent implements OnInit {

  final FileService fileService;

  AppComponent(this.fileService);

  @override
  void ngOnInit() {
    print('Authenticating here or whatever');
  }

  void onDeselect() => fileService.selected.clear();

  void onDelete() => fileService.deleteSelected();

}
