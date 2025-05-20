//     final dataVaccination = dataVaccinationFromJson(jsonString);

import 'dart:convert';

enum Enum{
  createdOn,
  name,
  filename,
  comment,
}


List<DataVaccination> dataVaccinationFromJson(String str) => List<DataVaccination>.from(json.decode(str).map((x) => DataVaccination.fromJson(x)));

String dataVaccinationToJson(List<DataVaccination> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataVaccination {
  String? id;
  String? patientId;
  String? name;
  DateTime? executeDate;
  String? comment;
  String? fileId;
  String? fileName;
  DateTime? createdOn;
  String? vaccinationId;

  DataVaccination({
    this.id,
    this.patientId,
    this.name,
    required this.executeDate,
    required this.comment,
    this.fileId,
    this.fileName,
    this.createdOn,
    this.vaccinationId,
  });

  factory DataVaccination.fromJson(Map<String, dynamic> json) => DataVaccination(
    id: json["Id"],
    patientId: json["PatientId"],
    name: json["Name"],
    executeDate: DateTime.parse(json["ExecuteDate"]),
    comment: json["Comment"],
    fileId: json["FileId"],
    fileName: json["FileName"],
    createdOn: DateTime.parse(json["CreatedOn"]),
    vaccinationId: json["VaccinationId"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PatientId": patientId,
    "Name": name,
    "ExecuteDate": executeDate?.toIso8601String(),
    "Comment": comment,
    "FileId": fileId,
    "FileName": fileName,
    "CreatedOn": createdOn?.toIso8601String(),
    "VaccinationId": vaccinationId,
  };
}
