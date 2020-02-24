import 'dart:async';
import 'dart:html';

import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/services/context_service.dart';
import 'package:HolySheetWeb/src/services/file_send_service.dart';
import 'package:HolySheetWeb/src/services/file_service.dart';
import 'package:angular/angular.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_router/angular_router.dart';
import 'package:filesize/filesize.dart';
import 'package:intl/intl.dart';

import '../js.dart';
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
  exports: [NavAction, GeneralActions, DropdownActions, SortType, SortOrder],
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class FileListComponent implements OnInit, OnDestroy, OnActivate {
  static final PATH_REGEX = RegExp(r'^\/([\w-]+?(\/[\w-]+?){0,1})*\/$');

  final AuthService authService;
  final FileService fileService;
  final ContextService contextService;
  final FileSendService fileSendService;
  final Router router;
  final ChangeDetectorRef changeRef;
  final NgZone zone;
  final streamSubscriptions = <StreamSubscription>[];

  FetchedFile get contextFile => fileService.files.firstWhere(
      (file) => file.id == contextService.fileContextId,
      orElse: () => null);

  DragType dragType;
  List<FetchedFile> dragging = [];

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

  @Input()
  bool searching = false;

  @Input()
  SortType sortType = SortType.Time;

  @Input()
  SortOrder sortOrder = SortOrder.Desc;

  void Function() update;

  // The currently browsing path
  String _path = '/';

  set path(String path) {
    _path = path;
    var progress = <String>[];
    var p1 = ['', ...'$path'.trimText('/').split('/')];
    print(p1);
    pathElements = p1
        .expand((path) => [PathElement(path, (progress..add(path)).join('/'))])
        .toList()
          ..first.text = 'Documents'
          ..first.absolutePath = '/';
  }

  String get path => _path;

  ListType listType = ListType.Default;

  List<PathElement> pathElements = [PathElement('Documents', '/')];

  FileListComponent(this.authService, this.fileService, this.contextService,
      this.fileSendService, this.changeRef, this.router, this.zone);

  @override
  void onActivate(RouterState previous, RouterState current) {
    fileService.updates.add(update = () => changeRef
      ..markForCheck()
      ..detectChanges());

    listType = current.routePath.additionalData as ListType;

    var urlPath = current.queryParameters['path'] ?? '/';
    if (PATH_REGEX.hasMatch(urlPath)) {
      path = urlPath;
    }

    fileService.selected.clear();
    showRestore = listType == ListType.Trash;

    authService.onSignedIn(() =>
        fileService.fetchFiles(listType, path, true, sortType, sortOrder));
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

      starMode = fileService.selected.any((file) => !(file?.starred ?? false));
    });

    contextService.registerContext('actions', '#actions-dropdown',
        buttonSelector: '#actions-button');

    contextService.registerContext('file-context', '#file-contextmenu',
        buttonSelector: '.file-contextmenu-button');

    contextService.registerContext('sort-dropdown', '#sort-dropdown',
        buttonSelector: '#sort-button');

    Timer waiting;

    void startDrop(MouseEvent event) {
      if (event.dataTransfer.types.contains('Files')) {
        dragType = DragType.FileUpload;
      }

      if (dragType != DragType.FileUpload) {
        return;
      }

      event.preventDefault();
      event.stopPropagation();
      waiting?.cancel();
      if (!showingDrop) {
        showingDrop = true;
        changeRef.markForCheck();
      }
    }

    void stopDrop(MouseEvent event) {
      if (event.dataTransfer.types.contains('Files')) {
        dragType = DragType.FileUpload;
      }

      if (dragType != DragType.FileUpload) {
        return;
      }

      event.preventDefault();
      event.stopPropagation();
      waiting = Timer(Duration(milliseconds: 200), () {
        waiting = null;
        if (showingDrop) {
          showingDrop = false;
          changeRef.markForCheck();
        }
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
        if (event.dataTransfer.types.contains('Files')) {
          dragType = DragType.FileUpload;
        }

        if (dragType == DragType.FileUpload) {
          stopDrop(event);
          uploadFiles(event.dataTransfer.files[0]);
        }
      }),
    ]);
  }

  // Upload/file controls

  void uploadFiles(File file) {
    uploading = true;
    update();
    fileSendService.send(file, path, onProgress: (percentage) {
      uploadPercentage = (percentage * 100).floor();
      update();
    }, onDone: () {
      fileService.fetchFiles(listType, path, true, sortType, sortOrder);
      uploadPercentage = 100;
      update();
      Timer(Duration(seconds: 1), () {
        uploading = false;
        update();
        Timer(Duration(seconds: 1), () => uploadPercentage = 0);
      });
    });
  }

  void dragStart(MouseEvent event) {
    dragType = DragType.InternalMoving;
    dragging = fileService.selected.clone();
    if (dragging.isEmpty) {
      final target = getDataParent(event.target)?.getAttribute('data-id');
      if (target == null) {
        return;
      }

      final clickedFile = fileService.files
          .firstWhere((file) => file.id == target, orElse: () => null);

      if (clickedFile != null) {
        dragging.add(clickedFile);
      }
    }
  }

  void dropEnd(MouseEvent event, [bool absolutePath = false]) {
    event.preventDefault();

    if (dragType == DragType.InternalMoving) {
      dragType = null;

      final target = getDataParent(event.target);
      target?.classes?.remove('drag-over');

      var calculatedPath = target?.getAttribute('data-id') ?? '/';
      if (!absolutePath) {
        calculatedPath = '$path$calculatedPath';
      }

      fileService.moveFiles(dragging, calculatedPath).then((_) => update());
      dragging = [];
    }
  }

  void dragEnter(MouseEvent event) {
    event.preventDefault();
    final target = getDataParent(event.target);

    final id = target.getAttribute('data-id');
    if (dragging.any((file) => file.id == id)) {
      return;
    }

    target?.classes?.add('drag-over');
  }

  void dragLeave(MouseEvent event) {
    event.preventDefault();
    final target = getDataParent(event.target);
    target?.classes?.remove('drag-over');
  }

  void enterFolder(MouseEvent event, String file) {
    file = '$path$file/';
    navigatePath(file);
  }

  /// Gets something like the title of a folder's card and goes up until it hits
  /// anything with the [data-id] attribute. If none is fount, null is returned.
  HtmlElement getDataParent(HtmlElement element) {
    if (element.tagName == 'form') {
      return null;
    }

    if (element.getAttribute('data-id') == null) {
      return getDataParent(element.parentNode);
    }

    return element;
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

  void navigatePath(String path) => router.navigate(
      router.current.routePath.toUrl(),
      NavigationParams(queryParameters: {'path': path}));

  // Dropdown clicks

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
    String path = 'prompt'('Name of folder to create:');
    if (path != null && path.trim().isNotEmpty) {
      fileService.createFolder(path);
    }
  }

  void uploadFile() => querySelector('#fileElem').click();

  // Top bar

  void enableSearch() => searching = true;

  void disableSearch() => searching = false;

  void toggleSortOrder() =>
      fileService.sortFiles(sortType, sortOrder = sortOrder.invert());

  void sortBy(SortType type) =>
      fileService.sortFiles(sortType = type, sortOrder);

  List classIf(bool test, List classes) => test ? classes : [];

  @override
  void ngOnDestroy() {
    for (var stream in streamSubscriptions) {
      stream.cancel();
    }

    fileService.updates.remove(update);
  }

  // Utility methods

  String formatDate(int date) =>
      DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(date));

  String formatTime(int date) =>
      DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(date));

  String fileSize(int size) => filesize(size);

  bool isSelected(FetchedFile file) => fileService.selected.contains(file);
}

/// Icons in the top right of the navigation bar.
enum NavAction { Clear, Star, Download, Delete, Restore, NewFolder, Upload }

/// General blank-space context menu items' actions.
enum GeneralActions { NewFolder, Upload }

/// Actions for file's context menus.
enum DropdownActions { Select, Star, Rename, Download, Delete, Restore }

enum ListType { Default, Starred, Trash }

enum DragType { FileUpload, InternalMoving }

class SortType {
  static const Time = SortType('Time', 'access_time');
  static const Name = SortType('Name', 'title');

  static const values = <SortType>[SortType.Time, SortType.Name];

  final String name;
  final String icon;

  const SortType(this.name, this.icon);
}

class SortOrder {
  static const Asc = SortOrder('Ascend', 'keyboard_arrow_up');
  static const Desc = SortOrder('Descend', 'keyboard_arrow_down');

  static const values = <SortOrder>[SortOrder.Asc, SortOrder.Desc];

  final String name;
  final String icon;

  const SortOrder(this.name, this.icon);

  SortOrder invert() => this == Asc ? Desc : Asc;
}

class PathElement {
  String text;
  String absolutePath;

  bool get icon => text == null;

  PathElement([this.text, this.absolutePath]);
}
