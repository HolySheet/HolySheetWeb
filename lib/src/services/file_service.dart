import 'dart:async';

import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/request_objects.dart';
import 'package:HolySheetWeb/src/request_utils.dart';
import 'package:HolySheetWeb/src/services/auth_service.dart';
import 'package:HolySheetWeb/src/utility.dart';
import 'package:angular/core.dart';

@Injectable()
class FileService {
  final AuthService authService;
  final RequestService requestService;

  final updates = <void Function()>[];

  final files = <FetchedFile>[];
  final folders = <String>[];

  final List<FetchedFile> selected = [];

  FileService(this.authService, this.requestService);

  Future<FetchedList> fetchFiles(
      [ListType type = ListType.Default,
      String path = '',
      bool update = true]) async {
    if (!authService.checkSignedIn) {
      print('User not logged in');
      return FetchedList();
    }

    return requestService
        .listFiles(
            path: path,
            starred: type == ListType.Starred,
            trashed: type == ListType.Trash)
        .then((fetched) {
      if (update) {
        var baseParts = path.trimText('/').split('/');
        if (baseParts.length == 1 && baseParts[0].isEmpty) {
          baseParts = [];
        }

        folders
          ..clear()
          ..addAll(fetched.folders.map((folder) {
            var parts = folder.trimText('/').split('/');

            for (var i in baseParts.asMap().keys) {
              if (baseParts[i] != parts.elementAt(i)) {
                return null;
              }
            }

            parts.removeRange(0, baseParts.length);

            return parts.length == 1 ? parts.single : null;
          }).where((i) => i != null));

        files
          ..clear()
          ..addAll(fetched.files);
        _triggerUpdate();
      }

      return fetched;
    });
  }

  Future<void> deleteSelected() async => deleteFiles(selected);

  Future<void> deleteFiles(List<FetchedFile> files) async =>
      requestService.deleteFiles(files).then((_) {
        this.files.removeAll(files);
        selected.removeAll(files);
        _triggerUpdate();
      });

  Future<void> restoreSelected() async => restoreFiles(selected);

  Future<void> restoreFiles(List<FetchedFile> files) async =>
      requestService.restoreFiles(files).then((_) {
        this.files.removeAll(files);
        selected.removeAll(files);
        _triggerUpdate();
      });

  Future<void> starSelected(bool starred) async => starFiles(selected, starred);

  Future<void> starFiles(List<FetchedFile> files, bool starred) async =>
      requestService
          .starFiles(files, starred)
          .then((_) => files.forEach((file) => file.starred = starred));

  void downloadSelected() => downloadFile(selected.start());

  void downloadFile(FetchedFile file) => requestService.downloadFile(file);

  Future<void> moveSelected(String path) async => moveFiles(selected, path);

  Future<void> moveFiles(List<FetchedFile> files, String path) async =>
      requestService
          .moveFiles(files, path)
          .then((_) => this.files.removeAll(files));

  Future<void> createFolder(String path) async =>
      requestService.createFolder(path).then((_) {
        print('folders add "$path"');
        folders.add(path);
      });

  void _triggerUpdate() {
    for (var callback in updates) {
      callback();
    }
  }
}
