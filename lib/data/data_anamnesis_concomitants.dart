//     final dataAnamnesisConcomitants = dataAnamnesisConcomitantsFromJson(jsonString);

import 'dart:convert';

enum Enum{
  dateStart,
  endDate,
  toThisTime,
  diagnosis,
  comment,
}

List<DataAnamnesisConcomitants> dataAnamnesisConcomitantsFromJson(String str) =>
    List<DataAnamnesisConcomitants>.from(
        json.decode(str).map((x) => DataAnamnesisConcomitants.fromJson(x)));

String dataAnamnesisConcomitantsToJson(List<DataAnamnesisConcomitants> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataAnamnesisConcomitants {
  String? id;
  String? patientsId;
  int? dateStart;
  String? diagnosis;
  EndDate? endDate;
  String? comment;
  int? creationDate;

  DataAnamnesisConcomitants({
    this.id,
    this.patientsId,
    required this.dateStart,
    required this.diagnosis,
    required this.endDate,
    required this.comment,
    required this.creationDate,
  });

  factory DataAnamnesisConcomitants.fromJson(Map<String, dynamic> json) =>
      DataAnamnesisConcomitants(
        id: json["id"],
        patientsId: json["patients_id"],
        dateStart: json["date_start"],
        diagnosis: json["diagnosis"],
        endDate: EndDate.fromJson(json["end_date"]),
        comment: json["comment"],
        creationDate: json["creation_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patients_id": patientsId,
        "date_start": dateStart,
        "diagnosis": diagnosis,
        "end_date": endDate?.toJson(),
        "comment": comment,
        "creation_date": creationDate,
      };
}

class EndDate {
  int? date;
  bool? checkbox;

  EndDate({
    required this.date,
    required this.checkbox,
  });

  factory EndDate.fromJson(Map<String, dynamic> json) => EndDate(
        date: json["date"],
        checkbox: json["checkbox"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "checkbox": checkbox,
      };
}
