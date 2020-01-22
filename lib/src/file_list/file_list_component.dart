import 'dart:async';
import 'dart:html';

import 'package:HolySheetWeb/src/fetched_file.dart';
import 'package:HolySheetWeb/src/file_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'file-list',
  styleUrls: ['file_list_component.css'],
  templateUrl: 'file_list_component.html',
  directives: [
    MaterialIconComponent,
    NgFor,
    NgIf,
  ],
)
class FileListComponent implements OnInit {
  final FileService fileService;
  final Router router;

  List<FetchedFile> files = [];

  FileListComponent(this.fileService, this.router) {
    final curr = router.current;
    print('Now at $curr params: ${curr?.routePath?.additionalData ?? {}}');
  }

  @override
  Future<Null> ngOnInit() async {
    files = await fileService.fetchFiles();
  }

  void clickFile(FetchedFile file) {
    var selected = fileService.selected;
    if (selected.contains(file)) {
      selected.remove(file);
    } else {
      selected.add(file);
    }
  }

  void onDeselect() => fileService.selected.clear();

  void onDelete() => fileService.deleteSelected();

  bool isSelected(FetchedFile file) => fileService.selected.contains(file);
}

enum ListType {
  Default, Starred, Trash
}
