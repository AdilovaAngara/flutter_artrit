//     final dataResearches = dataResearchesFromJson(jsonString);

import 'dart:convert';

enum Enum{
  date,
  name,
  filename,
  comment,
}

List<DataResearches> dataResearchesFromJson(String str) => List<DataResearches>.from(json.decode(str).map((x) => DataResearches.fromJson(x)));

String dataResearchesToJson(List<DataResearches> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataResearches {
  String? id;
  String? patientId;
  int? typeId;
  String? name;
  int? date;
  String? comment;
  List<String>? fileIds;
  TypeName? typeName;
  int? creationDate;
  List<String>? filename;

  DataResearches({
    this.id,
    this.patientId,
    required this.typeId,
    required this.name,
    required this.date,
    required this.comment,
    required this.fileIds,
    this.typeName,
    required this.creationDate,
    this.filename,
  });

  factory DataResearches.fromJson(Map<String, dynamic> json) => DataResearches(
    id: json["id"],
    patientId: json["patient_id"],
    typeId: json["type_id"],
    name: json["name"],
    date: json["date"],
    comment: json["comment"],
    fileIds: List<String>.from(json["file_ids"].map((x) => x)),
    typeName: typeNameValues.map[json["type_name"]]!,
    creationDate: json["creation_date"],
    filename: List<String>.from(json["filename"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient_id": patientId,
    "type_id": typeId,
    "name": name,
    "date": date,
    "comment": comment,
    "file_ids": fileIds != null ? List<dynamic>.from(fileIds!.map((x) => x)) : null,
    "type_name": typeNameValues.reverse[typeName],
    "creation_date": creationDate,
    "filename": filename != null ? List<dynamic>.from(filename!.map((x) => x)) : null,
  };
}

enum TypeName {
  EMPTY,
  FLUFFY,
  PURPLE,
  TYPE_NAME
}

final typeNameValues = EnumValues({
  "КТ": TypeName.EMPTY,
  "Рентген": TypeName.FLUFFY,
  "УЗИ": TypeName.PURPLE,
  "МРТ": TypeName.TYPE_NAME
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
