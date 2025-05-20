//     final dataSprTreatmentRehabilitationsTypes = dataSprTreatmentRehabilitationsTypesFromJson(jsonString);

import 'dart:convert';

List<DataSprTreatmentRehabilitationsTypes> dataSprTreatmentRehabilitationsTypesFromJson(String str) => List<DataSprTreatmentRehabilitationsTypes>.from(json.decode(str).map((x) => DataSprTreatmentRehabilitationsTypes.fromJson(x)));

String dataSprTreatmentRehabilitationsTypesToJson(List<DataSprTreatmentRehabilitationsTypes> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTreatmentRehabilitationsTypes {
  String id;
  String? name;
  bool? isHidden;

  DataSprTreatmentRehabilitationsTypes({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTreatmentRehabilitationsTypes.fromJson(Map<String, dynamic> json) => DataSprTreatmentRehabilitationsTypes(
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
