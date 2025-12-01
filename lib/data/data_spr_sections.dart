// To parse this JSON data, do
//
//     final dataSprSections = dataSprSectionsFromJson(jsonString);

import 'dart:convert';

List<DataSprSections> dataSprSectionsFromJson(String str) => List<DataSprSections>.from(json.decode(str).map((x) => DataSprSections.fromJson(x)));

String dataSprSectionsToJson(List<DataSprSections> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprSections {
  int id;
  String name;

  DataSprSections({
    required this.id,
    required this.name,
  });

  factory DataSprSections.fromJson(Map<String, dynamic> json) => DataSprSections(
    id: json["Id"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
  };
}
