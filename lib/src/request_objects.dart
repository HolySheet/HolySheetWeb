import 'package:HolySheetWeb/src/utility.dart';

class FetchedFile {
  String name;
  String id;
  int sheets;
  int size;
  int date;
  bool selfOwned;
  String owner;
  String driveLink;

  FetchedFile(this.name, this.id, this.sheets, this.size, this.date,
      this.selfOwned, this.owner, this.driveLink);

  FetchedFile.fromJson(Map<String, dynamic> json) :
      name = json['name'],
      id = json['id'],
      sheets = json['sheets'],
      size = toInt(json['size']),
      date = toInt(json['date']),
      selfOwned = json['selfOwned'],
      owner = json['owner'],
      driveLink = json['driveLink'];
}
