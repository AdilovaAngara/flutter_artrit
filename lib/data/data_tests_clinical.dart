//     final dataTestClinical = dataTestClinicalFromJson(jsonString);

import 'dart:convert';

enum Enum{
  date,
  erythrocytes,
  thrombocytes,
  hemoglobin,
  soe,
  leukocytes,
  neutrophils,
  lymphocytes,
  monocytes,
  basophils,
  eosinophils,
}


DataTestsClinical dataTestsClinicalFromJson(String str) => DataTestsClinical.fromJson(json.decode(str));

String dataTestsClinicalToJson(DataTestsClinical data) => json.encode(data.toJson());

class DataTestsClinical {
  Items items;
  String patientId;
  int? date;
  bool isCreate;

  DataTestsClinical({
    required this.items,
    required this.patientId,
    required this.date,
    required this.isCreate,
  });

  factory DataTestsClinical.fromJson(Map<String, dynamic> json) => DataTestsClinical(
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
  ItemsChild thrombocytes;
  ItemsChild basophils;
  ItemsChild erythrocytes;
  ItemsChild eosinophils;
  ItemsChild monocytes;
  ItemsChild neutrophils;
  ItemsChild hemoglobin;
  ItemsChild lymphocytes;
  ItemsChild soe;
  ItemsChild leukocytes;

  Items({
    required this.thrombocytes,
    required this.basophils,
    required this.erythrocytes,
    required this.eosinophils,
    required this.monocytes,
    required this.neutrophils,
    required this.hemoglobin,
    required this.lymphocytes,
    required this.soe,
    required this.leukocytes,
  });

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    thrombocytes: ItemsChild.fromJson(json["Thrombocytes"]),
    basophils: ItemsChild.fromJson(json["Basophils"]),
    erythrocytes: ItemsChild.fromJson(json["Erythrocytes"]),
    eosinophils: ItemsChild.fromJson(json["Eosinophils"]),
    monocytes: ItemsChild.fromJson(json["Monocytes"]),
    neutrophils: ItemsChild.fromJson(json["Neutrophils"]),
    hemoglobin: ItemsChild.fromJson(json["Hemoglobin"]),
    lymphocytes: ItemsChild.fromJson(json["Lymphocytes"]),
    soe: ItemsChild.fromJson(json["SOE"]),
    leukocytes: ItemsChild.fromJson(json["Leukocytes"]),
  );

  Map<String, dynamic> toJson() => {
    "Thrombocytes": thrombocytes.toJson(),
    "Basophils": basophils.toJson(),
    "Erythrocytes": erythrocytes.toJson(),
    "Eosinophils": eosinophils.toJson(),
    "Monocytes": monocytes.toJson(),
    "Neutrophils": neutrophils.toJson(),
    "Hemoglobin": hemoglobin.toJson(),
    "Lymphocytes": lymphocytes.toJson(),
    "SOE": soe.toJson(),
    "Leukocytes": leukocytes.toJson(),
  };
}

class ItemsChild {
  double? analysisPatientValue;
  bool norma;
  String analysisPatientId;
  int analysisPatientDate;
  String? analysisPatientUnitId;
  String analysisId;
  String? analysisName;
  String analysisKeyName;
  int? creationDate;
  Minmax? minmax;

  ItemsChild({
    required this.analysisPatientValue,
    required this.norma,
    required this.analysisPatientId,
    required this.analysisPatientDate,
    required this.analysisPatientUnitId,
    required this.analysisId,
    required this.analysisName,
    required this.analysisKeyName,
    required this.creationDate,
    this.minmax,
  });

  factory ItemsChild.fromJson(Map<String, dynamic> json) => ItemsChild(
    analysisPatientValue: json["AnalysisPatientValue"]?.toDouble(),
    norma: json["norma"],
    analysisPatientId: json["AnalysisPatientId"],
    analysisPatientDate: json["AnalysisPatientDate"].toInt(),
    analysisPatientUnitId: json["AnalysisPatientUnitId"],
    analysisId: json["AnalysisId"],
    analysisName: json["AnalysisName"],
    analysisKeyName: json["AnalysisKeyName"],
    creationDate: json["creation_date"],
    minmax: json["minmax"] == null ? null : Minmax.fromJson(json["minmax"]),
  );

  Map<String, dynamic> toJson() => {
    "AnalysisPatientValue": analysisPatientValue,
    "norma": norma,
    "AnalysisPatientId": analysisPatientId,
    "AnalysisPatientDate": analysisPatientDate,
    "AnalysisPatientUnitId": analysisPatientUnitId,
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
