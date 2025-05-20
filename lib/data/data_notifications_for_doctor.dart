// To parse this JSON data, do
//
//     final dataNotificationsForDoctor = dataNotificationsForDoctorFromJson(jsonString);

import 'dart:convert';

List<DataNotificationsForDoctor> dataNotificationsForDoctorFromJson(String str) => List<DataNotificationsForDoctor>.from(json.decode(str).map((x) => DataNotificationsForDoctor.fromJson(x)));

String dataNotificationsForDoctorToJson(List<DataNotificationsForDoctor> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataNotificationsForDoctor {
  String id;
  String? patientId;
  String? patientFio;
  String? testId;
  String? parameter;
  String? unit;
  double? value;
  String? limits;
  DateTime? created;
  bool? seen;

  DataNotificationsForDoctor({
    required this.id,
    required this.patientId,
    required this.patientFio,
    required this.testId,
    required this.parameter,
    required this.unit,
    required this.value,
    required this.limits,
    required this.created,
    required this.seen,
  });

  factory DataNotificationsForDoctor.fromJson(Map<String, dynamic> json) => DataNotificationsForDoctor(
    id: json["Id"],
    patientId: json["patient_id"],
    patientFio: json["patient_fio"],
    testId: json["test_id"],
    parameter: json["parameter"],
    unit: json["unit"],
    value: json["value"]?.toDouble(),
    limits: json["limits"],
    created: DateTime.parse(json["created"]),
    seen: json["seen"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "patient_id": patientId,
    "patient_fio": patientFio,
    "test_id": testId,
    "parameter": parameter,
    "unit": unit,
    "value": value,
    "limits": limits,
    "created": created?.toIso8601String(),
    "seen": seen,
  };
}




