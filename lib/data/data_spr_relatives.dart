//     final dataSprRelatives = dataSprRelativesFromJson(jsonString);

import 'dart:convert';

List<DataSprRelatives> dataSprRelativesFromJson(String str) => List<DataSprRelatives>.from(json.decode(str).map((x) => DataSprRelatives.fromJson(x)));

String dataSprRelativesToJson(List<DataSprRelatives> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprRelatives {
  String id;
  String? name;
  bool? isHidden;

  DataSprRelatives({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprRelatives.fromJson(Map<String, dynamic> json) => DataSprRelatives(
    id: json["id"],
    name: json["name"],
    isHidden: json["IsHidden"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "IsHidden": isHidden,
  };
}
