import 'dart:convert';
import 'blood_test_items.dart';


enum Enum{
  date,
  bilirubinTotal,
  mochevina,
  ast,
  alt,
  creatinine,
}


DataTestsBiochemical dataTestsBiochemicalFromJson(String str) => DataTestsBiochemical.fromJson(json.decode(str));

String dataTestsBiochemicalToJson(DataTestsBiochemical data) => json.encode(data.toJson());

class DataTestsBiochemical {
  Items items;
  String patientId;
  int? date;
  bool isCreate;

  DataTestsBiochemical({
    required this.items,
    required this.patientId,
    required this.date,
    required this.isCreate,
  });

  factory DataTestsBiochemical.fromJson(Map<String, dynamic> json) => DataTestsBiochemical(
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
  BloodTestItems bilirubinTotal;
  BloodTestItems mochevina;
  BloodTestItems ast;
  BloodTestItems alt;
  BloodTestItems creatinine;

  Items({
    required this.bilirubinTotal,
    required this.mochevina,
    required this.ast,
    required this.alt,
    required this.creatinine,
  });

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    bilirubinTotal: BloodTestItems.fromJson(json["BilirubinTotal"]),
    mochevina: BloodTestItems.fromJson(json["Mochevina"]),
    ast: BloodTestItems.fromJson(json["AST"]),
    alt: BloodTestItems.fromJson(json["ALT"]),
    creatinine: BloodTestItems.fromJson(json["Creatinine"]),
  );

  Map<String, dynamic> toJson() => {
    "BilirubinTotal": bilirubinTotal.toJson(),
    "Mochevina": mochevina.toJson(),
    "AST": ast.toJson(),
    "ALT": alt.toJson(),
    "Creatinine": creatinine.toJson(),
  };
}


