//     final dataSprTreatmentUnits = dataSprTreatmentUnitsFromJson(jsonString);

import 'dart:convert';

List<DataSprTreatmentUnits> dataSprTreatmentUnitsFromJson(String str) => List<DataSprTreatmentUnits>.from(json.decode(str).map((x) => DataSprTreatmentUnits.fromJson(x)));

String dataSprTreatmentUnitsToJson(List<DataSprTreatmentUnits> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTreatmentUnits {
  String id;
  String? name;
  bool? isHidden;

  DataSprTreatmentUnits({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTreatmentUnits.fromJson(Map<String, dynamic> json) => DataSprTreatmentUnits(
    id: json["id"],
    name: json["name"],
    isHidden: json["IsHidden"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "IsHidden": isHidden ?? false,
  };
}
