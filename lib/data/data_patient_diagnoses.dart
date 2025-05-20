//     final diagnosesData = diagnosesDataFromJson(jsonString);

import 'dart:convert';

List<DataPatientDiagnoses> dataPatientDiagnosesFromJson(String str) => List<DataPatientDiagnoses>.from(json.decode(str).map((x) => DataPatientDiagnoses.fromJson(x)));

String dataPatientDiagnosesToJson(List<DataPatientDiagnoses> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataPatientDiagnoses {
  String id;
  String patientsId;
  String? diagnosisId;
  String? comment;
  dynamic kritpost;
  dynamic kritisc;
  int? dateCreated;

  DataPatientDiagnoses({
    required this.id,
    required this.patientsId,
    this.diagnosisId,
    this.comment,
    this.kritpost,
    this.kritisc,
    this.dateCreated,
  });

  factory DataPatientDiagnoses.fromJson(Map<String, dynamic> json) => DataPatientDiagnoses(
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
