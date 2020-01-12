import 'dart:async';

import 'package:HolySheetWeb/src/fetched_file.dart';
import 'package:angular/core.dart';

@Injectable()
class FileService {
  List<FetchedFile> selected = [];

  // Temporary
  List<FetchedFile> mockFileList = [
    'File1.txt',
    'File2.mp4',
    'File3.ogg',
    'File4.yml',
    'File5.java',
    'File6.zip',
    'File7.png'
  ]
      .map((title) => FetchedFile(title, 'Statistics on the file or whatever'))
      .toList();

  // TODO: Actually fetch these files
  Future<List<FetchedFile>> fetchFiles() async => mockFileList;

  Future<void> deleteSelected() async => deleteFiles(selected);

  Future<void> deleteFiles(List<FetchedFile> files) async {
    selected.removeWhere((file) => files.contains(file));

    // TODO: Actually delete files
    print('Deleting ${files.length} file(s)');
  }
}
