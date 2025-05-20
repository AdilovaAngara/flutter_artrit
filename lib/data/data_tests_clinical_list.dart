//     final dataTestClinical = dataTestClinicalFromJson(jsonString);

import 'dart:convert';

List<DataTestsClinicalList> dataTestsClinicalListFromJson(String str) => List<DataTestsClinicalList>.from(json.decode(str).map((x) => DataTestsClinicalList.fromJson(x)));

String dataTestsClinicalListToJson(List<DataTestsClinicalList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTestsClinicalList {
  int? dateNew;
  double? thrombocytes;
  double? erythrocytes;
  double? basophils;
  double? eosinophils;
  double? monocytes;
  double? neutrophils;
  double? hemoglobin;
  double? lymphocytes;
  double? soe;
  double? leukocytes;
  bool? thrombocytesnorma;
  bool? erythrocytesnorma;
  bool? basophilsnorma;
  bool? eosinophilsnorma;
  bool? monocytesnorma;
  bool? neutrophilsnorma;
  bool? hemoglobinnorma;
  bool? lymphocytesnorma;
  bool? soEnorma;
  bool? leukocytesnorma;
  String? thrombocytesUnit;
  String? erythrocytesUnit;
  String? basophilsUnit;
  String? eosinophilsUnit;
  String? monocytesUnit;
  String? neutrophilsUnit;
  String? hemoglobinUnit;
  String? lymphocytesUnit;
  String? soeUnit;
  String? leukocytesUnit;
  String? thrombocytesId;
  String? erythrocytesId;
  String? basophilsId;
  String? eosinophilsId;
  String? monocytesId;
  String? neutrophilsId;
  String? hemoglobinId;
  String? lymphocytesId;
  String? soeId;
  String? leukocytesId;
  String? thrombocytesName;
  String? erythrocytesName;
  String? basophilsName;
  String? eosinophilsName;
  String? monocytesName;
  String? neutrophilsName;
  String? hemoglobinName;
  String? lymphocytesName;
  String? soeName;
  String? leukocytesName;
  int? creationDate;

  DataTestsClinicalList({
    required this.dateNew,
    required this.thrombocytes,
    required this.erythrocytes,
    required this.basophils,
    required this.eosinophils,
    required this.monocytes,
    required this.neutrophils,
    required this.hemoglobin,
    required this.lymphocytes,
    required this.soe,
    required this.leukocytes,
    required this.thrombocytesnorma,
    required this.erythrocytesnorma,
    required this.basophilsnorma,
    required this.eosinophilsnorma,
    required this.monocytesnorma,
    required this.neutrophilsnorma,
    required this.hemoglobinnorma,
    required this.lymphocytesnorma,
    required this.soEnorma,
    required this.leukocytesnorma,
    required this.thrombocytesUnit,
    required this.erythrocytesUnit,
    required this.basophilsUnit,
    required this.eosinophilsUnit,
    required this.monocytesUnit,
    required this.neutrophilsUnit,
    required this.hemoglobinUnit,
    required this.lymphocytesUnit,
    required this.soeUnit,
    required this.leukocytesUnit,
    required this.thrombocytesId,
    required this.erythrocytesId,
    required this.basophilsId,
    required this.eosinophilsId,
    required this.monocytesId,
    required this.neutrophilsId,
    required this.hemoglobinId,
    required this.lymphocytesId,
    required this.soeId,
    required this.leukocytesId,
    required this.thrombocytesName,
    required this.erythrocytesName,
    required this.basophilsName,
    required this.eosinophilsName,
    required this.monocytesName,
    required this.neutrophilsName,
    required this.hemoglobinName,
    required this.lymphocytesName,
    required this.soeName,
    required this.leukocytesName,
    required this.creationDate,
  });

  factory DataTestsClinicalList.fromJson(Map<String, dynamic> json) => DataTestsClinicalList(
    dateNew: json["date_new"],
    thrombocytes: json["Thrombocytes"]?.toDouble(),
    erythrocytes: json["Erythrocytes"]?.toDouble(),
    basophils: json["Basophils"]?.toDouble(),
    eosinophils: json["Eosinophils"]?.toDouble(),
    monocytes: json["Monocytes"]?.toDouble(),
    neutrophils: json["Neutrophils"]?.toDouble(),
    hemoglobin: json["Hemoglobin"]?.toDouble(),
    lymphocytes: json["Lymphocytes"]?.toDouble(),
    soe: json["SOE"]?.toDouble(),
    leukocytes: json["Leukocytes"]?.toDouble(),
    thrombocytesnorma: json["Thrombocytesnorma"],
    erythrocytesnorma: json["Erythrocytesnorma"],
    basophilsnorma: json["Basophilsnorma"],
    eosinophilsnorma: json["Eosinophilsnorma"],
    monocytesnorma: json["Monocytesnorma"],
    neutrophilsnorma: json["Neutrophilsnorma"],
    hemoglobinnorma: json["Hemoglobinnorma"],
    lymphocytesnorma: json["Lymphocytesnorma"],
    soEnorma: json["SOEnorma"],
    leukocytesnorma: json["Leukocytesnorma"],
    thrombocytesUnit: json["ThrombocytesUnit"],
    erythrocytesUnit: json["ErythrocytesUnit"],
    basophilsUnit: json["BasophilsUnit"],
    eosinophilsUnit: json["EosinophilsUnit"],
    monocytesUnit: json["MonocytesUnit"],
    neutrophilsUnit: json["NeutrophilsUnit"],
    hemoglobinUnit: json["HemoglobinUnit"],
    lymphocytesUnit: json["LymphocytesUnit"],
    soeUnit: json["SOEUnit"],
    leukocytesUnit: json["LeukocytesUnit"],
    thrombocytesId: json["ThrombocytesId"],
    erythrocytesId: json["ErythrocytesId"],
    basophilsId: json["BasophilsId"],
    eosinophilsId: json["EosinophilsId"],
    monocytesId: json["MonocytesId"],
    neutrophilsId: json["NeutrophilsId"],
    hemoglobinId: json["HemoglobinId"],
    lymphocytesId: json["LymphocytesId"],
    soeId: json["SOEId"],
    leukocytesId: json["LeukocytesId"],
    thrombocytesName: json["ThrombocytesName"],
    erythrocytesName: json["ErythrocytesName"],
    basophilsName: json["BasophilsName"],
    eosinophilsName: json["EosinophilsName"],
    monocytesName: json["MonocytesName"],
    neutrophilsName: json["NeutrophilsName"],
    hemoglobinName: json["HemoglobinName"],
    lymphocytesName: json["LymphocytesName"],
    soeName: json["SOEName"],
    leukocytesName: json["LeukocytesName"],
    creationDate: json["creation_date"],
  );

  Map<String, dynamic> toJson() => {
    "date_new": dateNew,
    "Thrombocytes": thrombocytes,
    "Erythrocytes": erythrocytes,
    "Basophils": basophils,
    "Eosinophils": eosinophils,
    "Monocytes": monocytes,
    "Neutrophils": neutrophils,
    "Hemoglobin": hemoglobin,
    "Lymphocytes": lymphocytes,
    "SOE": soe,
    "Leukocytes": leukocytes,
    "Thrombocytesnorma": thrombocytesnorma,
    "Erythrocytesnorma": erythrocytesnorma,
    "Basophilsnorma": basophilsnorma,
    "Eosinophilsnorma": eosinophilsnorma,
    "Monocytesnorma": monocytesnorma,
    "Neutrophilsnorma": neutrophilsnorma,
    "Hemoglobinnorma": hemoglobinnorma,
    "Lymphocytesnorma": lymphocytesnorma,
    "SOEnorma": soEnorma,
    "Leukocytesnorma": leukocytesnorma,
    "ThrombocytesUnit": thrombocytesUnit,
    "ErythrocytesUnit": erythrocytesUnit,
    "BasophilsUnit": basophilsUnit,
    "EosinophilsUnit": eosinophilsUnit,
    "MonocytesUnit": monocytesUnit,
    "NeutrophilsUnit": neutrophilsUnit,
    "HemoglobinUnit": hemoglobinUnit,
    "LymphocytesUnit": lymphocytesUnit,
    "SOEUnit": soeUnit,
    "LeukocytesUnit": leukocytesUnit,
    "ThrombocytesId": thrombocytesId,
    "ErythrocytesId": erythrocytesId,
    "BasophilsId": basophilsId,
    "EosinophilsId": eosinophilsId,
    "MonocytesId": monocytesId,
    "NeutrophilsId": neutrophilsId,
    "HemoglobinId": hemoglobinId,
    "LymphocytesId": lymphocytesId,
    "SOEId": soeId,
    "LeukocytesId": leukocytesId,
    "ThrombocytesName": thrombocytesName,
    "ErythrocytesName": erythrocytesName,
    "BasophilsName": basophilsName,
    "EosinophilsName":eosinophilsName,
    "MonocytesName": monocytesName,
    "NeutrophilsName": neutrophilsName,
    "HemoglobinName": hemoglobinName,
    "LymphocytesName": lymphocytesName,
    "SOEName": soeName,
    "LeukocytesName": leukocytesName,
    "creation_date": creationDate,
  };
}



//
//  sUnitValues ({
//   "тыс/мкл",
//   "%",
//   "10^9/л",
//       "млн/мкл",
//       "10^12/л",
//   "г/дл",
//   "г/л",
//   "мм/час",
// });



