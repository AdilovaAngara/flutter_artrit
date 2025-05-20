//     final dataSprTreatmentResults = dataSprTreatmentResultsFromJson(jsonString);

import 'dart:convert';

List<DataSprTreatmentResults> dataSprTreatmentResultsFromJson(String str) => List<DataSprTreatmentResults>.from(json.decode(str).map((x) => DataSprTreatmentResults.fromJson(x)));

String dataSprTreatmentResultsToJson(List<DataSprTreatmentResults> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTreatmentResults {
  String id;
  String? name;
  bool? isHidden;

  DataSprTreatmentResults({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTreatmentResults.fromJson(Map<String, dynamic> json) => DataSprTreatmentResults(
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
