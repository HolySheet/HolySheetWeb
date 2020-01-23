import 'dart:async';
import 'dart:html';

import 'package:HolySheetWeb/src/context_service.dart';
import 'package:HolySheetWeb/src/file_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_router/angular_router.dart';

import '../request_objects.dart';

@Component(
    selector: 'file-list',
    styleUrls: ['file_list_component.css'],
    templateUrl: 'file_list_component.html',
    directives: [
      MaterialIconComponent,
      NgFor,
      NgIf,
    ])
class FileListComponent implements OnInit {
  final FileService fileService;
  final ContextService contextService;
  final Router router;

  List<FetchedFile> files = [];

  // The currently browsing path
  String path = '';

  List<PathElement> get pathElements => 'Documents/$path'
      .split('/')
      .where((path) => path.isNotEmpty)
      .expand((path) => [PathElement(path), PathElement()])
      .toList()
      ..removeLast();

  FileListComponent(this.fileService, this.contextService, this.router) {
    final curr = router.current;
    print('Now at $curr params: ${curr?.routePath?.additionalData ?? {}}');

    print('path = "$path"');
    print(pathElements);
  }

  @override
  Future<void> ngOnInit() async {
    contextService.registerContext('files', '#files-contextmenu');
    contextService.registerContext('file', '#file-contextmenu');
    contextService.registerContext('actions', '#actions-dropdown', '#actions-button');

    print('Fetching!');
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

enum ListType { Default, Starred, Trash }

class PathElement {
  String text;

  bool get icon => text == null;

  PathElement([this.text]);
}
