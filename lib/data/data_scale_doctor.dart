// To parse this JSON data, do
//
//     final dataScaleDoctor = dataScaleDoctorFromJson(jsonString);

import 'dart:convert';

enum Enum {
  creationDate,
}

List<DataScaleDoctor> dataScaleDoctorFromJson(String str) => List<DataScaleDoctor>.from(json.decode(str).map((x) => DataScaleDoctor.fromJson(x)));

String dataScaleDoctorToJson(List<DataScaleDoctor> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataScaleDoctor {
  String? id;
  String? patientId;
  String? doctorId;
  int? scale;
  DateTime? scaleDate;
  int? creationDate;

  DataScaleDoctor({
    this.id,
    this.patientId,
    this.doctorId,
    required this.scale,
    required this.scaleDate,
    required this.creationDate,
  });

  factory DataScaleDoctor.fromJson(Map<String, dynamic> json) => DataScaleDoctor(
    id: json["Id"],
    patientId: json["PatientId"],
    doctorId: json["DoctorId"],
    scale: json["Scale"],
    scaleDate: DateTime.parse(json["ScaleDate"]),
    creationDate: json["creation_date"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PatientId": patientId,
    "DoctorId": doctorId,
    "Scale": scale,
    "ScaleDate": scaleDate?.toIso8601String(),
    "creation_date": creationDate,
  };
}
