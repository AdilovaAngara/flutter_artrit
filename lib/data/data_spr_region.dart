
//     final regionData = regionDataFromJson(jsonString);

import 'dart:convert';

List<DataSprRegion> dataSprRegionFromJson(String str) => List<DataSprRegion>.from(json.decode(str).map((x) => DataSprRegion.fromJson(x)));

String dataSprRegionToJson(List<DataSprRegion> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprRegion {
  String id;
  String name;
  bool isHidden;

  DataSprRegion({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprRegion.fromJson(Map<String, dynamic> json) => DataSprRegion(
    id: json["id"],
    name: json["Name"],
    isHidden: json["IsHidden"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "Name": name,
    "IsHidden": isHidden,
  };
}
