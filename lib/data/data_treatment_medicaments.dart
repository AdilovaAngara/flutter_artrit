//     final dataSprTreatmentUnits = dataSprTreatmentUnitsFromJson(jsonString);

import 'dart:convert';

enum Enum {
  tnp,
  tlf,
  mnn,
  obesplek,
  pv,
  ei,
  dnp,
  dop,
  srd,
  krat,
  pop,
  toThisTime,
}

enum EnumSkippings {
  beginDate,
  endDate,
  reasonName,
}

List<DataTreatmentMedicaments> dataTreatmentMedicamentsFromJson(String str) =>
    List<DataTreatmentMedicaments>.from(
        json.decode(str).map((x) => DataTreatmentMedicaments.fromJson(x)));

String dataTreatmentMedicamentsToJson(List<DataTreatmentMedicaments> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTreatmentMedicaments {
  String? id;
  String? patientsId;
  String? tnp;
  String? tlf;
  String? mnn;
  String? obesplek;
  String? pv;
  String? ei;
  int? dnp;
  Dop? dop;
  double? srd;
  String? krat;
  List<Skipping>? skippings;
  String? pop;
  int? creationDate;

  DataTreatmentMedicaments({
    this.id,
    this.patientsId,
    required this.tnp,
    required this.tlf,
    required this.mnn,
    required this.obesplek,
    required this.pv,
    required this.ei,
    required this.dnp,
    required this.dop,
    required this.srd,
    required this.krat,
    required this.skippings,
    required this.pop,
    required this.creationDate,
  });

  factory DataTreatmentMedicaments.fromJson(Map<String, dynamic> json) =>
      DataTreatmentMedicaments(
        id: json["id"],
        patientsId: json["patients_id"],
        tnp: json["tnp"],
        tlf: json["tlf"],
        mnn: json["mnn"],
        obesplek: json["obesplek"],
        pv: json["pv"],
        ei: json["ei"],
        dnp: json["dnp"],
        dop: Dop.fromJson(json["dop"]),
        srd: json["srd"]?.toDouble(),
        krat: json["krat"],
        skippings: List<Skipping>.from(
            json["Skippings"].map((x) => Skipping.fromJson(x))),
        pop: json["pop"],
        creationDate: json["creation_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patients_id": patientsId,
        "tnp": tnp,
        "tlf": tlf,
        "mnn": mnn,
        "obesplek": obesplek,
        "pv": pv,
        "ei": ei,
        "dnp": dnp,
        "dop": dop?.toJson(),
        "srd": srd,
        "krat": krat,
        "Skippings": skippings != null
            ? List<dynamic>.from(skippings!.map((x) => x.toJson()))
            : null,
        "pop": pop,
        "creation_date": creationDate,
      };
}

class Dop {
  int? date;
  bool? checkbox;

  Dop({
    required this.date,
    required this.checkbox,
  });

  factory Dop.fromJson(Map<String, dynamic> json) => Dop(
        date: json["date"],
        checkbox: json["checkbox"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "checkbox": checkbox,
      };
}

class Skipping {
  String? treatmentId;
  DateTime? beginDate;
  DateTime? endDate;
  String? reasonId;
  String? reasonName;
  bool? menuBeginDate;
  bool? menuEndDate;

  Skipping({
    this.treatmentId,
    required this.beginDate,
    required this.endDate,
    required this.reasonId,
    required this.reasonName,
    required this.menuBeginDate,
    required this.menuEndDate,
  });

  factory Skipping.fromJson(Map<String, dynamic> json) => Skipping(
        treatmentId: json["TreatmentId"],
        beginDate: DateTime.parse(json["BeginDate"]),
        endDate: DateTime.parse(json["EndDate"]),
        reasonId: json["ReasonId"],
        reasonName: json["ReasonName"],
        menuBeginDate: json["MenuBeginDate"],
        menuEndDate: json["MenuEndDate"],
      );

  Map<String, dynamic> toJson() => {
        "TreatmentId": treatmentId,
        "BeginDate": beginDate?.toIso8601String(),
        "EndDate": endDate?.toIso8601String(),
        "ReasonId": reasonId,
        "ReasonName": reasonName,
        "MenuBeginDate": menuBeginDate,
        "MenuEndDate": menuEndDate,
      };
}
