//     final dataTestsOptions = dataTestsOptionsFromJson(jsonString);

import 'dart:convert';

List<DataTestsOptions> dataTestsOptionsFromJson(String str) => List<DataTestsOptions>.from(json.decode(str).map((x) => DataTestsOptions.fromJson(x)));

String dataTestsOptionsToJson(List<DataTestsOptions> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTestsOptions {
  String? name;
  String? keyName;
  String? id;
  String? analysisId;
  String? unitId;
  int? ageMin;
  int? ageMax;
  double? minValue;
  double? maxValue;
  double? refMIn;
  double? refMax;
  String? gender;
  String? unitName;

  DataTestsOptions({
    this.name,
    this.keyName,
    this.id,
    this.analysisId,
    this.unitId,
    this.ageMin,
    this.ageMax,
    this.minValue,
    this.maxValue,
    this.refMIn,
    this.refMax,
    this.gender,
    this.unitName,
  });

  factory DataTestsOptions.fromJson(Map<String, dynamic> json) => DataTestsOptions(
    name: json["Name"],
    keyName: json["KeyName"],
    id: json["id"],
    analysisId: json["AnalysisId"],
    unitId: json["UnitId"],
    ageMin: json["ageMin"],
    ageMax: json["ageMax"],
    minValue: json["minValue"],
    maxValue: json["maxValue"],
    refMIn: json["refMIn"]?.toDouble(),
    refMax: json["refMax"]?.toDouble(),
    gender: json["Gender"],
    unitName: json["unitName"],
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "KeyName": keyName,
    "id": id,
    "AnalysisId": analysisId,
    "UnitId": unitId,
    "ageMin": ageMin,
    "ageMax": ageMax,
    "minValue": minValue,
    "maxValue": maxValue,
    "refMIn": refMIn,
    "refMax": refMax,
    "Gender": gender,
    "unitName": unitName,
  };
}


