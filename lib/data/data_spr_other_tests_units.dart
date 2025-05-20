//     final dataTestsOtherTestsUnits = dataTestsOtherTestsUnitsFromJson(jsonString);

import 'dart:convert';

List<DataSprOtherTestsUnits> dataSprOtherTestsUnitsFromJson(String str) => List<DataSprOtherTestsUnits>.from(json.decode(str).map((x) => DataSprOtherTestsUnits.fromJson(x)));

String dataSprOtherTestsUnitsToJson(List<DataSprOtherTestsUnits> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprOtherTestsUnits {
  String id;
  String name;

  DataSprOtherTestsUnits({
    required this.id,
    required this.name,
  });

  factory DataSprOtherTestsUnits.fromJson(Map<String, dynamic> json) => DataSprOtherTestsUnits(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
