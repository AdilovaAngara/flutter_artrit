//     final diagnosesData = diagnosesDataFromJson(jsonString);

import 'dart:convert';

List<DataDiagnoses> dataDiagnosesFromJson(String str) => List<DataDiagnoses>.from(json.decode(str).map((x) => DataDiagnoses.fromJson(x)));

String dataDiagnosesToJson(List<DataDiagnoses> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataDiagnoses {
  String id;
  String patientsId;
  String? diagnosisId;
  String? comment;
  dynamic kritpost;
  dynamic kritisc;
  int? dateCreated;

  DataDiagnoses({
    required this.id,
    required this.patientsId,
    required this.diagnosisId,
    this.comment,
    this.kritpost,
    this.kritisc,
    this.dateCreated,
  });

  factory DataDiagnoses.fromJson(Map<String, dynamic> json) => DataDiagnoses(
    id: json["id"],
    patientsId: json["patients_id"],
    diagnosisId: json["diagnosis_id"],
    comment: json["comment"],
    kritpost: json["kritpost"],
    kritisc: json["kritisc"],
    dateCreated: json["date_created"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patients_id": patientsId,
    "diagnosis_id": diagnosisId,
    "comment": comment,
    "kritpost": kritpost,
    "kritisc": kritisc,
    "date_created": dateCreated,
  };
}
