//     final dataResearchesOther = dataResearchesOtherFromJson(jsonString);

import 'dart:convert';

enum Enum{
  executeDate,
  name,
  files,
  comment,
}


List<DataResearchesOther> dataResearchesOtherFromJson(String str) => List<DataResearchesOther>.from(json.decode(str).map((x) => DataResearchesOther.fromJson(x)));

String dataResearchesOtherToJson(List<DataResearchesOther> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataResearchesOther {
  String? id;
  String? patientId;
  String? name;
  DateTime? executeDate;
  String? comment;
  DateTime? createdOn;
  List<FileElement>? files;

  DataResearchesOther({
    this.id,
    this.patientId,
    required this.name,
    required this.executeDate,
    required this.comment,
    required this.createdOn,
    this.files,
  });

  factory DataResearchesOther.fromJson(Map<String, dynamic> json) => DataResearchesOther(
    id: json["Id"],
    patientId: json["PatientId"],
    name: json["Name"],
    executeDate: DateTime.parse(json["ExecuteDate"]),
    comment: json["Comment"],
    createdOn: DateTime.parse(json["CreatedOn"]),
    files: List<FileElement>.from(json["Files"].map((x) => FileElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PatientId": patientId,
    "Name": name,
    "ExecuteDate": executeDate?.toIso8601String(),
    "Comment": comment,
    "CreatedOn": createdOn?.toIso8601String(),
    "Files": files != null ? List<dynamic>.from(files!.map((x) => x.toJson())) : null,
  };
}

class FileElement {
  String? id;
  String? fileName;

  FileElement({
    required this.id,
    required this.fileName,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
    id: json["Id"],
    fileName: json["FileName"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "FileName": fileName,
  };
}
