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
  bool starred;
  bool trashed;

  FetchedFile(this.name, this.id, this.path, this.folder, this.sheets, this.size, this.date,
      this.selfOwned, this.owner, this.driveLink, this.starred, this.trashed);

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
        driveLink = json['driveLink'],
        starred = json['starred'] ?? false,
        trashed = json['trashed'] ?? false;


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchedFile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FetchedFile{name: $name, id: $id, path: $path, folder: $folder, sheets: $sheets, size: $size, date: $date, selfOwned: $selfOwned, owner: $owner, driveLink: $driveLink, starred: $starred, trashed: $trashed}';
  }
}
