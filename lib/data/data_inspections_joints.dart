
//     final inspectionsJointsData = inspectionsJointsDataFromJson(jsonString);

import 'dart:convert';

List<DataInspectionsJoints> dataInspectionsJointsFromJson(String str) => List<DataInspectionsJoints>.from(json.decode(str).map((x) => DataInspectionsJoints.fromJson(x)));

String dataInspectionsJointsToJson(List<DataInspectionsJoints> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataInspectionsJoints {
  String id;
  int numericId;
  String name;
  String? code;
  String type;
  dynamic subtype;
  int hasPictures;
  int picturesCount;

  DataInspectionsJoints({
    required this.id,
    required this.numericId,
    required this.name,
    required this.code,
    required this.type,
    required this.subtype,
    required this.hasPictures,
    required this.picturesCount,
  });

  factory DataInspectionsJoints.fromJson(Map<String, dynamic> json) => DataInspectionsJoints(
    id: json["id"],
    numericId: json["numeric_id"],
    name: json["name"],
    code: json["code"],
    type: json["type"],
    subtype: json["subtype"],
    hasPictures: json["HasPictures"],
    picturesCount: json["PicturesCount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "numeric_id": numericId,
    "name": name,
    "code": code,
    "type": type,
    "subtype": subtype,
    "HasPictures": hasPictures,
    "PicturesCount": picturesCount,
  };
}


