//     final dataSprTreatmentDrugProvision = dataSprTreatmentDrugProvisionFromJson(jsonString);

import 'dart:convert';

List<DataSprTreatmentDrugProvision> dataSprTreatmentDrugProvisionFromJson(String str) => List<DataSprTreatmentDrugProvision>.from(json.decode(str).map((x) => DataSprTreatmentDrugProvision.fromJson(x)));

String dataSprTreatmentDrugProvisionToJson(List<DataSprTreatmentDrugProvision> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTreatmentDrugProvision {
  String id;
  String? name;
  bool? isHidden;

  DataSprTreatmentDrugProvision({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTreatmentDrugProvision.fromJson(Map<String, dynamic> json) => DataSprTreatmentDrugProvision(
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
