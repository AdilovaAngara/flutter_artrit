//     final dataSprSideEffects = dataSprSideEffectsFromJson(jsonString);

import 'dart:convert';

List<DataSprSideEffects> dataSprSideEffectsFromJson(String str) => List<DataSprSideEffects>.from(json.decode(str).map((x) => DataSprSideEffects.fromJson(x)));

String dataSprSideEffectsToJson(List<DataSprSideEffects> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprSideEffects {
  String id;
  String name;
  bool isHidden;

  DataSprSideEffects({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprSideEffects.fromJson(Map<String, dynamic> json) => DataSprSideEffects(
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
