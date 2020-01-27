import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:HolySheetWeb/src/auth_service.dart';
import 'package:HolySheetWeb/src/context_service.dart';
import 'package:HolySheetWeb/src/file_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_router/angular_router.dart';
import 'package:filesize/filesize.dart';
import 'package:intl/intl.dart';

import '../request_objects.dart';
import '../utility.dart';

@Component(
    selector: 'file-list',
    styleUrls: ['file_list_component.css'],
    templateUrl: 'file_list_component.html',
//    changeDetection: ChangeDetectionStrategy.OnPush,
    directives: [
      MaterialIconComponent,
      NgClass,
      NgFor,
      NgIf,
    ],
    exports: [NavAction, GeneralActions, DropdownActions])
class FileListComponent implements OnInit, OnDestroy {
  final AuthService authService;
  final FileService fileService;
  final ContextService contextService;
  final Router router;
  final streamSubscriptions = <StreamSubscription>[];

  FetchedFile get contextFile =>
      files.firstWhere((file) => file.id == contextService.fileContextId,
          orElse: () => null);

  bool showingDrop = false;
  bool ctrlDown = false;

  bool uploading = false;

  @Input()
  int uploadPercentage = 0;

  set allFiles(List<FetchedFile> files) {
    files.forEach((file) => (file.folder ? folders : this.files).add(file));
  }

  List<FetchedFile> files = [];
  List<FetchedFile> folders = [];
//  List<>

  // The currently browsing path
  String path = '';

  List<PathElement> get pathElements => 'Documents/$path'
      .split('/')
      .where((path) => path.isNotEmpty)
      .expand((path) => [PathElement(path), PathElement()])
      .toList()
        ..removeLast();

  FileListComponent(
      this.authService, this.fileService, this.contextService, this.router) {
    final curr = router.current;
    print('Now at $curr params: ${curr?.routePath?.additionalData ?? {}}');

    print('path = "$path"');
    print(pathElements);
  }

  @override
  void ngOnInit() {
    fileService.fetchFiles().then((fetched) => allFiles = fetched);

    contextService.registerContext('files', '#files-contextmenu');
    contextService.registerContext('file', '#file-contextmenu');
    contextService.registerContext(
        'actions', '#actions-dropdown', '#actions-button');

    Timer waiting;

    void startDrop(MouseEvent event) {
      event.preventDefault();
      event.stopPropagation();
      waiting?.cancel();
      showingDrop = true;
    }

    void stopDrop(MouseEvent event) {
      event.preventDefault();
      event.stopPropagation();
      waiting = Timer(Duration(milliseconds: 200), () {
        waiting = null;
        showingDrop = false;
      });
    }

    streamSubscriptions.addAll([
      document.onKeyDown.listen((event) => ctrlDown = event.ctrlKey),
      document.onKeyUp.listen((event) => ctrlDown = event.ctrlKey),
      document.onKeyDown.listen((event) {
        // Escape
        if (event.key == 'Escape') {
          fileService.selected.clear();
        }
      }),
      document.onDragEnter.listen(startDrop),
      document.onDragOver.listen(startDrop),
      document.onDragLeave.listen(stopDrop),
      document.onDrop.listen((event) {
        stopDrop(event);
        uploadFiles(event.dataTransfer.files[0]);
      }),
    ]);
  }

  void uploadFiles(File file) {
    final request = HttpRequest();
    request.open('POST', 'http://localhost:8090/upload?t=${Random().nextInt(99999999)}', async: true);
    request.setRequestHeader('Authorization', authService.accessToken);

    // Percentage bar logic:
    // [0-50] is for uploading the file to the server
    // (51-100] is for server processing and uploading

    request.onLoadStart.listen((e) {
      uploadPercentage = 0;
      uploading = true;
    });
    request.upload.onProgress.listen((ProgressEvent e) {
      uploadPercentage = e.loaded * 50 ~/ e.total;
    });
    request.onLoad.listen((e) {
      uploadPercentage = 50;

      final response = jsonDecode(request.response);

      print('Upload response: ${response['message']}');

      final processingToken = response['processingToken'];

      print('processingToken = $processingToken');

      var ws = WebSocket(
          'ws://localhost:8090/websocket?processingToken=$processingToken');
      ws.onMessage.listen((event) {
        // 0-1 percentage
        final percentage = double.tryParse(event.data);
        if (percentage == null) {
          return;
        }

        uploadPercentage = 50 + (percentage * 50).ceil();
        print('second $uploadPercentage');

        if (uploadPercentage == 100) {
          print('upload percentage hit 100');

          uploading = false;
          Timer(Duration(seconds: 1), () => uploadPercentage = 0);
        }
      }, onDone: () {
        print('Done websocket!');
        if (uploading) {
          uploading = false;
          Timer(Duration(seconds: 1), () => uploadPercentage = 0);
        }
      });
    });

    request.send(FormData()
      ..set('file', file));
  }

  void clickFile(FetchedFile file) {
    if (ctrlDown) {
      fileService.selected.toggle(file);
    } else {
      final selected = fileService.selected;
      if (selected.length == 1 && selected[0] == file) {
        selected.clear();
      } else {
        selected
          ..clear()
          ..add(file);
      }
    }
  }

  List<FetchedFile> getFiles([bool folders = false]) =>
    files.where((file) => file.folder == folders).toList();

  String formatDate(int date) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(date);
//    var format = DateFormat.yMd().add_jm();
    var format = DateFormat.yMd();
    return format.format(dateTime);
  }

  String formatTime(int date) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(date);
    var format = DateFormat.jm();
    return format.format(dateTime);
  }

  String fileSize(int size) => filesize(size);

  bool isSelected(FetchedFile file) => fileService.selected.contains(file);

  void dropdownClick(DropdownActions action) {
    contextService.hideContext();

    switch (action) {
      case DropdownActions.Select:
        fileService.selected.add(contextFile);
        break;
      case DropdownActions.Star:
        print('Star ${contextService.fileContextId}');
        break;
      case DropdownActions.Rename:
        print('Rename ${contextService.fileContextId}');
        break;
      case DropdownActions.Download:
        print('Download ${contextService.fileContextId}');
        break;
      case DropdownActions.Delete:
        print('Delete ${contextService.fileContextId}');
        break;
    }
  }

  void generalClick(GeneralActions action) {
    contextService.hideContext();

    switch (action) {
      case GeneralActions.NewFolder:
        createFolder();
        break;
      case GeneralActions.Upload:
        uploadFile();
        break;
    }
  }

  void navItemClick(NavAction action) {
    contextService.hideContext();

    switch (action) {
      case NavAction.Clear:
        fileService.selected.clear();
        break;
      case NavAction.Star:
        print('Star');
        break;
      case NavAction.Download:
        print('Download');
        break;
      case NavAction.Delete:
        print('Delete');
        break;
      case NavAction.NewFolder:
        createFolder();
        break;
      case NavAction.Upload:
        uploadFile();
        break;
    }
  }

  void createFolder() {
    print('Creating folder');
  }

  void uploadFile() {
    print('Uploading file');
  }

  @override
  void ngOnDestroy() {
    for (var stream in streamSubscriptions) {
      stream.cancel();
    }
  }
}

/// Icons in the top right of the navigation bar.
enum NavAction { Clear, Star, Download, Delete, NewFolder, Upload }

/// General blank-space context menu items' actions.
enum GeneralActions { NewFolder, Upload }

/// Actions for file's context menus.
enum DropdownActions { Select, Star, Rename, Download, Delete }

enum ListType { Default, Starred, Trash }

class PathElement {
  String text;

  bool get icon => text == null;

  PathElement([this.text]);
}
