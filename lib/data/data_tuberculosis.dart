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
  String id;
  String patientId;
  DateTime? treatmentBeginDate;
  DateTime? treatmentEndDate;
  DateTime? createdOn;
  List<Drug>? drugs;
  List<SideEffect>? sideEffects;
  List<String>? drugIds;
  List<String>? sideEffectIds;
  List<String> customSideEffects;

  DataTuberculosis({
    required this.id,
    required this.patientId,
    required this.treatmentBeginDate,
    required this.treatmentEndDate,
    required this.createdOn,
    this.drugs,
    this.sideEffects,
    this.drugIds,
    this.sideEffectIds,
    required this.customSideEffects,
  });

  factory DataTuberculosis.fromJson(Map<String, dynamic> json) => DataTuberculosis(
    id: json["Id"],
    patientId: json["PatientId"],
    treatmentBeginDate: DateTime.parse(json["TreatmentBeginDate"]),
    treatmentEndDate: DateTime.parse(json["TreatmentEndDate"]),
    createdOn: DateTime.parse(json["CreatedOn"]),
    drugs: json["Drugs"] != null ? List<Drug>.from(json["Drugs"].map((x) => Drug.fromJson(x))) : null,
    sideEffects: json["SideEffects"] != null ? List<SideEffect>.from(json["SideEffects"].map((x) => SideEffect.fromJson(x))) : null,
    drugIds: json["drugIds"] != null ? List<String>.from(json["drugIds"].map((x) => x)) : null,
    sideEffectIds: json["sideEffectIds"] != null ? List<String>.from(json["sideEffectIds"].map((x) => x)) : null,
    customSideEffects: List<String>.from(json["CustomSideEffects"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PatientId": patientId,
    "TreatmentBeginDate": treatmentBeginDate?.toIso8601String(),
    "TreatmentEndDate": treatmentEndDate?.toIso8601String(),
    "CreatedOn": createdOn?.toIso8601String(),
    "Drugs": drugs != null ? List<dynamic>.from(drugs!.map((x) => x.toJson())) : null,
    "SideEffects": sideEffects != null ? List<dynamic>.from(sideEffects!.map((x) => x.toJson())) : null,
    "drugIds": drugIds != null ? List<dynamic>.from(drugIds!.map((x) => x)) : null,
    "sideEffectIds": sideEffectIds != null ? List<dynamic>.from(sideEffectIds!.map((x) => x)) : null,
    "CustomSideEffects": List<dynamic>.from(customSideEffects.map((x) => x)),
  };
}

class Drug {
  String id;
  String name;
  bool isTuberculosisInfection;

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
  String name;

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

