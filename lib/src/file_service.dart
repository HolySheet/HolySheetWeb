import 'dart:async';

import 'package:HolySheetWeb/src/auth_service.dart';
import 'package:HolySheetWeb/src/file_list/file_list_component.dart';
import 'package:HolySheetWeb/src/request_objects.dart';
import 'package:angular/core.dart';
import 'package:HolySheetWeb/src/utility.dart';

@Injectable()
class FileService {
  final AuthService authService;

  @Input()
  final List<FetchedFile> files = [];

  @Input()
  final List<FetchedFile> folders = [];

  final List<FetchedFile> selected = [];

  FileService(this.authService);

  Future<List<FetchedFile>> fetchFiles([ListType type = ListType.Default, bool update = true]) async {
    if (!authService.signedIn) {
      print('User not logged in');
      return [];
    }

    print('Fetcghing starred: ${type == ListType.Starred}');

    return authService
        .makeAuthedRequest('/list', query: {'path': '', 'starred': (type == ListType.Starred).toString()}).then((response) {
      if (!response.success) {
        print(
            'List request not successful. Code ${response.status}\n${response.json}');
        return [];
      }

      print(response.json);
      return List.of(response.json)
          .map((item) => FetchedFile.fromJson(item))
          .toList()
            ..add(FetchedFile('Movies', '', '', true, 0, 0, 0, true, '', '', false));
    }).then((res) {
      final files = res as List<FetchedFile>;

      if (update) {
        folders.clear();
        this.files.clear();
        files.forEach((file) => (file.folder ? folders : this.files).add(file));
      }

      return files;
    });
  }

  Future<void> deleteSelected() async => deleteFiles(selected);

  Future<void> deleteFiles(List<FetchedFile> files) async {
    files = List.of(files);

    selected.removeWhere((file) => files.contains(file));

    await authService.makeAuthedRequest('/delete',
        query: {'id': files.map((file) => file.id).join(',')}).then((_) {
      folders.removeAll(files);
      this.files.removeAll(files);
    });
  }

  Future<void> starSelected(bool starred) async => starFiles(starred, selected);

  Future<void> starFiles(bool starred, List<FetchedFile> files) async {
    files = List.of(files);

    await authService.makeAuthedRequest('/star',
        query: {'id': files.map((file) => file.id).join(','), 'starred': starred.toString()}).then((_) =>
        files.forEach((file) => file.starred = starred));
  }
}
