//     final dataTestsImmunology = dataTestsImmunologyFromJson(jsonString);

import 'dart:convert';

enum Enum{
  date,
  rheumatoidFactor,
  cReactiveProtein,
  antinuclearFactor,
  antiCcp,
}

DataTestsImmunology dataTestsImmunologyFromJson(String str) => DataTestsImmunology.fromJson(json.decode(str));

String dataTestsImmunologyToJson(DataTestsImmunology data) => json.encode(data.toJson());

class DataTestsImmunology {
  Items items;
  String patientId;
  int? date;
  bool isCreate;

  DataTestsImmunology({
    required this.items,
    required this.patientId,
    required this.date,
    required this.isCreate,
  });

  factory DataTestsImmunology.fromJson(Map<String, dynamic> json) => DataTestsImmunology(
    items: Items.fromJson(json["items"]),
    patientId: json["patientId"],
    date: json["date"],
    isCreate: json["isCreate"],
  );

  Map<String, dynamic> toJson() => {
    "items": items.toJson(),
    "patientId": patientId,
    "date": date,
    "isCreate": isCreate,
  };
}

class Items {
  ItemsChild rheumatoidFactor;
  ItemsChild cReactiveProtein;
  ItemsChild antinuclearFactor;
  ItemsChild antiCcp;

  Items({
    required this.rheumatoidFactor,
    required this.cReactiveProtein,
    required this.antinuclearFactor,
    required this.antiCcp,
  });

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    rheumatoidFactor: ItemsChild.fromJson(json["RheumatoidFactor"]),
    cReactiveProtein: ItemsChild.fromJson(json["C_ReactiveProtein"]),
    antinuclearFactor: ItemsChild.fromJson(json["AntinuclearFactor"]),
    antiCcp: ItemsChild.fromJson(json["AntiCCP"]),
  );

  Map<String, dynamic> toJson() => {
    "RheumatoidFactor": rheumatoidFactor.toJson(),
    "C_ReactiveProtein": cReactiveProtein.toJson(),
    "AntinuclearFactor": antinuclearFactor.toJson(),
    "AntiCCP": antiCcp.toJson(),
  };
}

class ItemsChild {
  dynamic analysisPatientValue;
  String? analysisPatientUnitId;
  bool norma;
  String analysisPatientId;
  int analysisPatientDate;
  String analysisId;
  String? analysisName;
  String analysisKeyName;
  int? creationDate;
  Minmax? minmax;

  ItemsChild({
    required this.analysisPatientValue,
    required this.analysisPatientUnitId,
    required this.norma,
    required this.analysisPatientId,
    required this.analysisPatientDate,
    required this.analysisId,
    required this.analysisName,
    required this.analysisKeyName,
    required this.creationDate,
    this.minmax,
  });

  factory ItemsChild.fromJson(Map<String, dynamic> json) => ItemsChild(
    analysisPatientValue: json["AnalysisPatientValue"],
    analysisPatientUnitId: json["AnalysisPatientUnitId"],
    norma: json["norma"],
    analysisPatientId: json["AnalysisPatientId"],
    analysisPatientDate: json["AnalysisPatientDate"].toInt(),
    analysisId: json["AnalysisId"],
    analysisName: json["AnalysisName"],
    analysisKeyName: json["AnalysisKeyName"],
    creationDate: json["creation_date"],
    minmax: json["minmax"] == null ? null : Minmax.fromJson(json["minmax"]),
  );

  Map<String, dynamic> toJson() => {
    "AnalysisPatientValue": analysisPatientValue,
    "AnalysisPatientUnitId": analysisPatientUnitId,
    "norma": norma,
    "AnalysisPatientId": analysisPatientId,
    "AnalysisPatientDate": analysisPatientDate,
    "AnalysisId": analysisId,
    "AnalysisName": analysisName,
    "AnalysisKeyName": analysisKeyName,
    "creation_date": creationDate,
    "minmax": minmax?.toJson(),
  };
}

class Minmax {
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

  Minmax({
    required this.name,
    required this.keyName,
    required this.id,
    required this.analysisId,
    required this.unitId,
    required this.ageMin,
    required this.ageMax,
    required this.minValue,
    required this.maxValue,
    required this.refMIn,
    required this.refMax,
    required this.gender,
    required this.unitName,
  });

  factory Minmax.fromJson(Map<String, dynamic> json) => Minmax(
    name: json["Name"],
    keyName: json["KeyName"],
    id: json["id"],
    analysisId: json["AnalysisId"],
    unitId: json["UnitId"],
    ageMin: json["ageMin"],
    ageMax: json["ageMax"],
    minValue: json["minValue"],
    maxValue: json["maxValue"],
    refMIn: json["refMIn"],
    refMax: json["refMax"],
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
