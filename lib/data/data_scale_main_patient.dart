import 'dart:convert';

enum Enum {
  creationDate,
}

List<DataScaleMainPatient> dataScaleMainPatientFromJson(String str) =>
    List<DataScaleMainPatient>.from(
        json.decode(str).map((x) => DataScaleMainPatient.fromJson(x)));

String dataScaleMainPatientToJson(List<DataScaleMainPatient> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataScaleMainPatient {
  String? id;
  String? patientId;
  dynamic doctorId;
  int? scale;
  DateTime? scaleDate;
  int? creationDate;

  DataScaleMainPatient({
    this.id,
    required this.patientId,
    this.doctorId,
    required this.scale,
    required this.scaleDate,
    required this.creationDate,
  });

  factory DataScaleMainPatient.fromJson(Map<String, dynamic> json) =>
      DataScaleMainPatient(
        id: json["Id"],
        patientId: json["PatientId"],
        doctorId: json["DoctorId"],
        scale: json["Scale"],
        scaleDate: DateTime.parse(json["ScaleDate"]),
        creationDate: json["creation_date"],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) "Id": id,
        "PatientId": patientId,
        "DoctorId": doctorId,
        "Scale": scale,
        "ScaleDate": scaleDate?.toIso8601String(),
        "creation_date": creationDate,
      };
}
