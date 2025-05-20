//     final dataSprTestsGroup = dataSprTestsGroupFromJson(jsonString);

import 'dart:convert';

List<DataSprTestsGroup> dataSprTestsGroupFromJson(String str) => List<DataSprTestsGroup>.from(json.decode(str).map((x) => DataSprTestsGroup.fromJson(x)));

String dataSprTestsGroupToJson(List<DataSprTestsGroup> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTestsGroup {
  String id;
  String name;
  bool isHidden;

  DataSprTestsGroup({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTestsGroup.fromJson(Map<String, dynamic> json) => DataSprTestsGroup(
    id: json["Id"],
    name: json["name"],
    isHidden: json["IsHidden"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "name": name,
    "IsHidden": isHidden,
  };
}