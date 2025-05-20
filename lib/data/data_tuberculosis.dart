// To parse this JSON data, do
//
//     final dataTuberculosis = dataTuberculosisFromJson(jsonString);

import 'dart:convert';


enum Enum{
  treatmentBeginDate,
  treatmentEndDate,
  drugs,
  sideEffects,
  customSideEffects,
}

List<DataTuberculosis> dataTuberculosisFromJson(String str) => List<DataTuberculosis>.from(json.decode(str).map((x) => DataTuberculosis.fromJson(x)));

String dataTuberculosisToJson(List<DataTuberculosis> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTuberculosis {
  String? id;
  String? patientId;
  DateTime? treatmentBeginDate;
  DateTime? treatmentEndDate;
  DateTime? createdOn;
  List<Drug>? drugs;
  List<dynamic>? drugIds;
  List<SideEffect>? sideEffects;
  List<dynamic>? sideEffectIds;
  List<String>? customSideEffects;

  DataTuberculosis({
    this.id,
    this.patientId,
    required this.treatmentBeginDate,
    required this.treatmentEndDate,
    required this.createdOn,
    this.drugs,
    this.drugIds,
    this.sideEffects,
    this.sideEffectIds,
    required this.customSideEffects,
  });

  // factory DataTuberculosis.fromJson(Map<String, dynamic> json) => DataTuberculosis(
  //   id: json["Id"],
  //   patientId: json["PatientId"],
  //   treatmentBeginDate: DateTime.parse(json["TreatmentBeginDate"]),
  //   treatmentEndDate: DateTime.parse(json["TreatmentEndDate"]),
  //   createdOn: DateTime.parse(json["CreatedOn"]),
  //   drugs: List<Drug>.from(json["Drugs"].map((x) => Drug.fromJson(x))),
  //   drugIds: List<String>.from(json["drugIds"].map((x) => x)),
  //   sideEffects: List<SideEffect>.from(json["SideEffects"].map((x) => SideEffect.fromJson(x))),
  //   sideEffectIds: List<String>.from(json["sideEffectIds"].map((x) => x)),
  //   customSideEffects: List<String>.from(json["CustomSideEffects"].map((x) => x)),
  // );


  factory DataTuberculosis.fromJson(Map<String, dynamic> json) => DataTuberculosis(
    id: json["Id"] as String?,
    patientId: json["PatientId"] as String?,
    treatmentBeginDate: json["TreatmentBeginDate"] != null
        ? DateTime.tryParse(json["TreatmentBeginDate"] as String)
        : null,
    treatmentEndDate: json["TreatmentEndDate"] != null
        ? DateTime.tryParse(json["TreatmentEndDate"] as String)
        : null,
    createdOn: json["CreatedOn"] != null
        ? DateTime.tryParse(json["CreatedOn"] as String)
        : null,
    drugs: json["Drugs"] != null && json["Drugs"] is List
        ? List<Drug>.from((json["Drugs"] as List).map((x) => Drug.fromJson(x as Map<String, dynamic>)))
        : null,
    drugIds: json["drugIds"] != null && json["drugIds"] is List
        ? List<String>.from((json["drugIds"] as List).map((x) => x as String))
        : null,
    sideEffects: json["SideEffects"] != null && json["SideEffects"] is List
        ? List<SideEffect>.from(
        (json["SideEffects"] as List).map((x) => SideEffect.fromJson(x as Map<String, dynamic>)))
        : null,
    sideEffectIds: json["sideEffectIds"] != null && json["sideEffectIds"] is List
        ? List<String>.from((json["sideEffectIds"] as List).map((x) => x as String))
        : null,
    customSideEffects: json["CustomSideEffects"] != null && json["CustomSideEffects"] is List
        ? List<String>.from((json["CustomSideEffects"] as List).map((x) => x as String))
        : null,
  );


  Map<String, dynamic> toJson() => {
    "Id": id,
    "PatientId": patientId,
    "TreatmentBeginDate": treatmentBeginDate?.toIso8601String(),
    "TreatmentEndDate": treatmentEndDate?.toIso8601String(),
    "CreatedOn": createdOn?.toIso8601String(),
    "Drugs": drugs != null ? List<dynamic>.from(drugs!.map((x) => x.toJson())) : null,
    "drugIds": drugIds != null ? List<dynamic>.from(drugIds!.map((x) => x)) : null,
    "SideEffects": sideEffects != null ? List<dynamic>.from(sideEffects!.map((x) => x.toJson())) : null,
    "sideEffectIds": sideEffectIds != null ? List<dynamic>.from(sideEffectIds!.map((x) => x)) : null,
    "CustomSideEffects": customSideEffects != null ? List<dynamic>.from(customSideEffects!.map((x) => x)) : null,
  };
}

class Drug {
  String id;
  String? name;
  bool? isTuberculosisInfection;

  Drug({
    required this.id,
    required this.name,
    required this.isTuberculosisInfection,
  });

  factory Drug.fromJson(Map<String, dynamic> json) => Drug(
    id: json["Id"],
    name: json["Name"],
    isTuberculosisInfection: json["IsTuberculosisInfection"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
    "IsTuberculosisInfection": isTuberculosisInfection,
  };
}

class SideEffect {
  String id;
  String? name;

  SideEffect({
    required this.id,
    required this.name,
  });

  factory SideEffect.fromJson(Map<String, dynamic> json) => SideEffect(
    id: json["Id"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
  };
}
