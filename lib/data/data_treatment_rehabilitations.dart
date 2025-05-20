//     final dataTreatmentRehabilitations = dataTreatmentRehabilitationsFromJson(jsonString);

import 'dart:convert';

enum Enum {
  dateStart,
  dateEnd,
  toThisTime,
  type,
  fizcomment,
}

List<DataTreatmentRehabilitations> dataTreatmentRehabilitationsFromJson(String str) => List<DataTreatmentRehabilitations>.from(json.decode(str).map((x) => DataTreatmentRehabilitations.fromJson(x)));

String dataTreatmentRehabilitationsToJson(List<DataTreatmentRehabilitations> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTreatmentRehabilitations {
  String? id;
  String? patientsId;
  int? dateStart;
  DateEnd? dateEnd;
  TypeRehabil? typeRehabil;
  int? creationDate;

  DataTreatmentRehabilitations({
    this.id,
    this.patientsId,
    required this.dateStart,
    required this.dateEnd,
    required this.typeRehabil,
    required this.creationDate,
  });

  factory DataTreatmentRehabilitations.fromJson(Map<String, dynamic> json) => DataTreatmentRehabilitations(
    id: json["id"],
    patientsId: json["patients_id"],
    dateStart: json["date_start"],
    dateEnd: DateEnd.fromJson(json["date_end"]),
    typeRehabil: TypeRehabil.fromJson(json["type_rehabil"]),
    creationDate: json["creation_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patients_id": patientsId,
    "date_start": dateStart,
    "date_end": dateEnd?.toJson(),
    "type_rehabil": typeRehabil?.toJson(),
    "creation_date": creationDate,
  };
}

class DateEnd {
  int? date;
  bool? checkbox;

  DateEnd({
    required this.date,
    required this.checkbox,
  });

  factory DateEnd.fromJson(Map<String, dynamic> json) => DateEnd(
    date: json["date"],
    checkbox: json["checkbox"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "checkbox": checkbox,
  };
}

class TypeRehabil {
  String? type;
  String? fizcomment;

  TypeRehabil({
    required this.type,
    required this.fizcomment,
  });

  factory TypeRehabil.fromJson(Map<String, dynamic> json) => TypeRehabil(
    type: json["type"],
    fizcomment: json["fizcomment"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "fizcomment": fizcomment,
  };
}
