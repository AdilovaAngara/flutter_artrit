//     final dataInspectionsPhotoRash = dataInspectionsPhotoRashFromJson(jsonString);

import 'dart:convert';

enum Enum {
  comments,
  angle1,
  angle2,
}



List<DataInspectionsPhoto> dataInspectionsPhotoFromJson(String str) => List<DataInspectionsPhoto>.from(json.decode(str).map((x) => DataInspectionsPhoto.fromJson(x)));

String dataInspectionsPhotoToJson(List<DataInspectionsPhoto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataInspectionsPhoto {
  String id;
  String patientsId;
  String? inspectionId;
  String jointsId;
  int? date;
  String comments;
  int? angle1;
  int? angle2;
  int? creationDate;
  int? numericId;
  String? name;
  dynamic code;
  String? type;
  dynamic subtype;
  dynamic isDas28;
  DateTime? filedate;
  String? filename;
  String? filetype;
  int? filesize;

  DataInspectionsPhoto({
    required this.id,
    required this.patientsId,
    this.inspectionId,
    required this.jointsId,
    required this.date,
    required this.comments,
    this.angle1,
    this.angle2,
    required this.creationDate,
    this.numericId,
    this.name,
    this.code,
    this.type,
    this.subtype,
    this.isDas28,
    this.filedate,
    this.filename,
    this.filetype,
    this.filesize,
  });

  factory DataInspectionsPhoto.fromJson(Map<String, dynamic> json) => DataInspectionsPhoto(
    id: json["id"],
    patientsId: json["patients_id"],
    inspectionId: json["inspections_id"],
    jointsId: json["joints_id"],
    date: json["date"],
    comments: json["comments"],
    angle1: json["angle1"],
    angle2: json["angle2"],
    creationDate: json["creation_date"],
    numericId: json["numeric_id"],
    name: json["name"],
    code: json["code"],
    type: json["type"],
    subtype: json["subtype"],
    isDas28: json["IsDas28"],
    filedate: DateTime.parse(json["filedate"]),
    filename: json["filename"],
    filetype: json["filetype"],
    filesize: json["filesize"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patients_id": patientsId,
    "inspections_id": inspectionId,
    "joints_id": jointsId,
    "date": date,
    "comments": comments,
    "angle1": angle1,
    "angle2": angle2,
    "creation_date": creationDate,
    "numeric_id": numericId,
    "name": name,
    "code": code,
    "type": type,
    "subtype": subtype,
    "IsDas28": isDas28,
    "filedate": filedate?.toIso8601String(),
    "filename": filename,
    "filetype": filetype,
    "filesize": filesize,
  };
}


