//     final dataTreatmentDrugForms = dataTreatmentDrugFormsFromJson(jsonString);

import 'dart:convert';

List<DataSprTreatmentDrugForms> dataSprTreatmentDrugFormsFromJson(String str) => List<DataSprTreatmentDrugForms>.from(json.decode(str).map((x) => DataSprTreatmentDrugForms.fromJson(x)));

String dataSprTreatmentDrugFormsToJson(List<DataSprTreatmentDrugForms> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTreatmentDrugForms {
  String id;
  String? name;
  bool? isHidden;

  DataSprTreatmentDrugForms({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTreatmentDrugForms.fromJson(Map<String, dynamic> json) => DataSprTreatmentDrugForms(
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
