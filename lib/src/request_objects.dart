import 'package:HolySheetWeb/src/utility.dart';

class FetchedFile {
  String name;
  String id;
  String path;
  bool folder;
  int sheets;
  int size;
  int date;
  bool selfOwned;
  String owner;
  String driveLink;

  FetchedFile(this.name, this.id, this.path, this.folder, this.sheets, this.size, this.date,
      this.selfOwned, this.owner, this.driveLink);

  FetchedFile.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        path = json['path'],
        folder = json['folder'] ?? false,
        sheets = json['sheets'],
        size = toInt(json['size']),
        date = toInt(json['date']),
        selfOwned = json['selfOwned'],
        owner = json['owner'],
        driveLink = json['driveLink'];
}
