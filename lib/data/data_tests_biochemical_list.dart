//     final dataTestsBiochemicalList = dataTestsBiochemicalListFromJson(jsonString);

import 'dart:convert';

List<DataTestsBiochemicalList> dataTestsBiochemicalListFromJson(String str) => List<DataTestsBiochemicalList>.from(json.decode(str).map((x) => DataTestsBiochemicalList.fromJson(x)));

String dataTestsBiochemicalListToJson(List<DataTestsBiochemicalList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTestsBiochemicalList {
  int? dateNew;
  double? bilirubinTotal;
  double? mochevina;
  double? ast;
  double? alt;
  double? creatinine;
  bool? bilirubinTotalnorma;
  bool? mochevinanorma;
  bool? asTnorma;
  bool? alTnorma;
  bool? creatininenorma;
  String? bilirubinTotalUnit;
  String? mochevinaUnit;
  String? astUnit;
  String? altUnit;
  String? creatinineUnit;
  String? bilirubinTotalId;
  String? mochevinaId;
  String? astId;
  String? altId;
  String? creatinineId;
  String? bilirubinTotalName;
  String? mochevinaName;
  String? astName;
  String? altName;
  String? creatinineName;
  int? creationDate;

  DataTestsBiochemicalList({
    required this.dateNew,
    required this.bilirubinTotal,
    required this.mochevina,
    required this.ast,
    required this.alt,
    required this.creatinine,
    required this.bilirubinTotalnorma,
    required this.mochevinanorma,
    required this.asTnorma,
    required this.alTnorma,
    required this.creatininenorma,
    required this.bilirubinTotalUnit,
    required this.mochevinaUnit,
    required this.astUnit,
    required this.altUnit,
    required this.creatinineUnit,
    required this.bilirubinTotalId,
    required this.mochevinaId,
    required this.astId,
    required this.altId,
    required this.creatinineId,
    required this.bilirubinTotalName,
    required this.mochevinaName,
    required this.astName,
    required this.altName,
    required this.creatinineName,
    required this.creationDate,
  });

  factory DataTestsBiochemicalList.fromJson(Map<String, dynamic> json) => DataTestsBiochemicalList(
    dateNew: json["date_new"],
    bilirubinTotal: json["BilirubinTotal"]?.toDouble(),
    mochevina: json["Mochevina"]?.toDouble(),
    ast: json["AST"]?.toDouble(),
    alt: json["ALT"]?.toDouble(),
    creatinine: json["Creatinine"]?.toDouble(),
    bilirubinTotalnorma: json["BilirubinTotalnorma"],
    mochevinanorma: json["Mochevinanorma"],
    asTnorma: json["ASTnorma"],
    alTnorma: json["ALTnorma"],
    creatininenorma: json["Creatininenorma"],
    bilirubinTotalUnit: json["BilirubinTotalUnit"],
    mochevinaUnit: json["MochevinaUnit"],
    astUnit: json["ASTUnit"],
    altUnit: json["ALTUnit"],
    creatinineUnit: json["CreatinineUnit"],
    bilirubinTotalId: json["BilirubinTotalId"],
    mochevinaId: json["MochevinaId"],
    astId: json["ASTId"],
    altId: json["ALTId"],
    creatinineId: json["CreatinineId"],
    bilirubinTotalName: json["BilirubinTotalName"],
    mochevinaName: json["MochevinaName"],
    astName: json["ASTName"],
    altName: json["ALTName"],
    creatinineName: json["CreatinineName"],
    creationDate: json["creation_date"],
  );

  Map<String, dynamic> toJson() => {
    "date_new": dateNew,
    "BilirubinTotal": bilirubinTotal,
    "Mochevina": mochevina,
    "AST": ast,
    "ALT": alt,
    "Creatinine": creatinine,
    "BilirubinTotalnorma": bilirubinTotalnorma,
    "Mochevinanorma": mochevinanorma,
    "ASTnorma": asTnorma,
    "ALTnorma": alTnorma,
    "Creatininenorma": creatininenorma,
    "BilirubinTotalUnit": bilirubinTotalUnit,
    "MochevinaUnit": mochevinaUnit,
    "ASTUnit": astUnit,
    "ALTUnit": altUnit,
    "CreatinineUnit": creatinineUnit,
    "BilirubinTotalId": bilirubinTotalId,
    "MochevinaId": mochevinaId,
    "ASTId": astId,
    "ALTId": altId,
    "CreatinineId": creatinineId,
    "BilirubinTotalName": bilirubinTotalName,
    "MochevinaName": mochevinaName,
    "ASTName": astName,
    "ALTName": altName,
    "CreatinineName": creatinineName,
    "creation_date": creationDate,
  };
}

