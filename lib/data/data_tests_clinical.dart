import 'dart:convert';
import 'blood_test_items.dart';

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
  BloodTestItems thrombocytes;
  BloodTestItems basophils;
  BloodTestItems erythrocytes;
  BloodTestItems eosinophils;
  BloodTestItems monocytes;
  BloodTestItems neutrophils;
  BloodTestItems hemoglobin;
  BloodTestItems lymphocytes;
  BloodTestItems soe;
  BloodTestItems leukocytes;

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
    thrombocytes: BloodTestItems.fromJson(json["Thrombocytes"]),
    basophils: BloodTestItems.fromJson(json["Basophils"]),
    erythrocytes: BloodTestItems.fromJson(json["Erythrocytes"]),
    eosinophils: BloodTestItems.fromJson(json["Eosinophils"]),
    monocytes: BloodTestItems.fromJson(json["Monocytes"]),
    neutrophils: BloodTestItems.fromJson(json["Neutrophils"]),
    hemoglobin: BloodTestItems.fromJson(json["Hemoglobin"]),
    lymphocytes: BloodTestItems.fromJson(json["Lymphocytes"]),
    soe: BloodTestItems.fromJson(json["SOE"]),
    leukocytes: BloodTestItems.fromJson(json["Leukocytes"]),
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



