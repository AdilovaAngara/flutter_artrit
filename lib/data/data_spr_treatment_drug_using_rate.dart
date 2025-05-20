//     final dataSprTreatmentDrugUsingRate = dataSprTreatmentDrugUsingRateFromJson(jsonString);

import 'dart:convert';

List<DataSprTreatmentDrugUsingRate> dataSprTreatmentDrugUsingRateFromJson(String str) => List<DataSprTreatmentDrugUsingRate>.from(json.decode(str).map((x) => DataSprTreatmentDrugUsingRate.fromJson(x)));

String dataSprTreatmentDrugUsingRateToJson(List<DataSprTreatmentDrugUsingRate> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTreatmentDrugUsingRate {
  String id;
  String? name;
  bool? isHidden;

  DataSprTreatmentDrugUsingRate({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTreatmentDrugUsingRate.fromJson(Map<String, dynamic> json) => DataSprTreatmentDrugUsingRate(
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
