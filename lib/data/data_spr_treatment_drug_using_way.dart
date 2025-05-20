//     final dataSprTreatmentDrugUsingWay = dataSprTreatmentDrugUsingWayFromJson(jsonString);

import 'dart:convert';

List<DataSprTreatmentDrugUsingWay> dataSprTreatmentDrugUsingWayFromJson(String str) => List<DataSprTreatmentDrugUsingWay>.from(json.decode(str).map((x) => DataSprTreatmentDrugUsingWay.fromJson(x)));

String dataSprTreatmentDrugUsingWayToJson(List<DataSprTreatmentDrugUsingWay> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTreatmentDrugUsingWay {
  String id;
  String? name;
  bool? isHidden;

  DataSprTreatmentDrugUsingWay({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTreatmentDrugUsingWay.fromJson(Map<String, dynamic> json) => DataSprTreatmentDrugUsingWay(
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
