import 'dart:async';

import 'package:HolySheetWeb/src/auth_service.dart';
import 'package:HolySheetWeb/src/request_objects.dart';
import 'package:angular/core.dart';

@Injectable()
class FileService {

  final AuthService authService;

  final List<FetchedFile> selected = [];

  FileService(this.authService);

  Future<List<FetchedFile>> fetchFiles() async {
    if (!authService.signedIn) {
      print('User not logged in');
      return [];
    }

    return authService.makeAuthedRequest('/list', query: {'path': ''}).then((response) {
    if (!response.success) {
      print('List request not successful. Code ${response.status}\n${response.json}');
      return [];
    }

    print(response.json);

      return List.of(response.json).map((item) {
        return FetchedFile.fromJson(item);
    }).toList();
  });
  }

  Future<void> deleteSelected() async => deleteFiles(selected);

  Future<void> deleteFiles(List<FetchedFile> files) async {
    selected.removeWhere((file) => files.contains(file));

    // TODO: Actually delete files
    print('Deleting ${files.length} file(s)');
  }
}
