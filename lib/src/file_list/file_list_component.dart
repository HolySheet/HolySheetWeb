import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:HolySheetWeb/src/constants.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/services/context_service.dart';
import 'package:HolySheetWeb/src/services/file_service.dart';
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
  directives: [
    MaterialIconComponent,
    NgClass,
    NgFor,
    NgIf,
  ],
  exports: [NavAction, GeneralActions, DropdownActions],
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class FileListComponent implements OnInit, OnDestroy, OnActivate {
  final AuthService authService;
  final FileService fileService;
  final ContextService contextService;
  final Router router;
  final ChangeDetectorRef changeRef;
  final NgZone zone;
  final streamSubscriptions = <StreamSubscription>[];

  FetchedFile get contextFile => fileService.files.firstWhere(
      (file) => file.id == contextService.fileContextId,
      orElse: () => null);

  @Input()
  bool showingDrop = false;

  @Input()
  bool ctrlDown = false;

  @Input()
  bool showRestore = false;

  @Input()
  bool uploading = false;

  // true - "Star"
  // false - "Unstar"
  //
  // true when at least one selected is unstarred
  @Input()
  bool starMode = true;

  @Input()
  int uploadPercentage = 0;

  void Function() update;

  // The currently browsing path
  String path = '';

  ListType listType = ListType.Default;

  List<PathElement> get pathElements => 'Documents/$path'
      .split('/')
      .where((path) => path.isNotEmpty)
      .expand((path) => [PathElement(path), PathElement()])
      .toList()
        ..removeLast();

  FileListComponent(this.authService, this.fileService, this.contextService,
      this.changeRef, this.router, this.zone);

  @override
  void onActivate(RouterState previous, RouterState current) {
    fileService.updates.add(update = () => changeRef
      ..markForCheck()
      ..detectChanges());

    listType = current.routePath.additionalData as ListType;

    fileService.selected.clear();
    showRestore = listType == ListType.Trash;

    authService.onSignedIn(() {
      fileService.fetchFiles(listType);
    });
  }

  @override
  void ngOnInit() {
    contextService.registerContext('files', '#files-contextmenu');
    contextService.registerContext('file', '#file-contextmenu',
        onShowContext: (fileID) {
      final clickedFile = fileService.files
          .firstWhere((file) => file.id == fileID, orElse: () => null);

      if (!fileService.selected.contains(clickedFile)) {
        fileService.selected
          ..clear()
          ..add(clickedFile);
      }

      starMode = fileService.selected.any((file) => !file.starred);
    });
    contextService.registerContext('actions', '#actions-dropdown',
        buttonSelector: '#actions-button');

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
    request.open(
        'POST', 'https://$API_URL/upload?t=${Random().nextInt(99999999)}',
        async: true);
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
          'wss://$API_URL/websocket?processingToken=$processingToken');
      ws.onClose.listen((event) {
        final code = event.code;
        final reason = event.reason;

        if (code == 1000 && reason == 'Success') {
          print('Successful listing, refreshing listings');

          fileService.fetchFiles(listType);

          if (uploading) {
            uploading = false;
            Timer(Duration(seconds: 1), () => uploadPercentage = 0);
          }
        } else if (code == 1011) {
          print('The upload status socket has closed with an error:');
          print(reason);
        } else {
          print('Unknown close response "$reason" with code $code');
        }
      });

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
      });
    });

    request.send(FormData()..set('file', file));
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
      fileService.files.where((file) => file.folder == folders).toList();

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
        if (!fileService.selected.contains(contextFile)) {
          fileService.selected.add(contextFile);
        }
        break;
      case DropdownActions.Star:
        fileService.starSelected(starMode);
        break;
      case DropdownActions.Rename:
        rename();
        break;
      case DropdownActions.Download:
        fileService.downloadSelected();
        break;
      case DropdownActions.Delete:
        fileService.deleteSelected();
        break;
      case DropdownActions.Restore:
        fileService.restoreSelected();
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
        fileService.starSelected(starMode);
        break;
      case NavAction.Download:
        fileService.downloadSelected();
        break;
      case NavAction.Delete:
        fileService.deleteSelected();
        break;
      case NavAction.Restore:
        fileService.restoreSelected();
        break;
      case NavAction.NewFolder:
        createFolder();
        break;
      case NavAction.Upload:
        uploadFile();
        break;
    }
  }

  void rename() {
    print('Rename ${contextService.fileContextId}');
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

    fileService.updates.remove(update);
  }
}

/// Icons in the top right of the navigation bar.
enum NavAction { Clear, Star, Download, Delete, Restore, NewFolder, Upload }

/// General blank-space context menu items' actions.
enum GeneralActions { NewFolder, Upload }

/// Actions for file's context menus.
enum DropdownActions { Select, Star, Rename, Download, Delete, Restore }

enum ListType { Default, Starred, Trash }

class PathElement {
  String text;

  bool get icon => text == null;

  PathElement([this.text]);
}
