//     final dataTreatmentSideEffects = dataTreatmentSideEffectsFromJson(jsonString);

import 'dart:convert';

enum Enum {
  date,
  dateEnd,
  toThisTime,
  ny,
  comment,
  treatOut,
  treatAdvEv,
}

List<DataTreatmentSideEffects> dataTreatmentSideEffectsFromJson(String str) =>
    List<DataTreatmentSideEffects>.from(
        json.decode(str).map((x) => DataTreatmentSideEffects.fromJson(x)));

String dataTreatmentSideEffectsToJson(List<DataTreatmentSideEffects> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTreatmentSideEffects {
  String? id;
  String? patientsId;
  int? date;
  String? ny;
  String? comment;
  String? treatOut;
  int? creationDate;
  String? treatAdvEv;
  DateEnd? dateEnd;

  DataTreatmentSideEffects({
    this.id,
    this.patientsId,
    required this.date,
    required this.ny,
    required this.comment,
    required this.treatOut,
    required this.creationDate,
    required this.treatAdvEv,
    required this.dateEnd,
  });

  factory DataTreatmentSideEffects.fromJson(Map<String, dynamic> json) =>
      DataTreatmentSideEffects(
        id: json["id"],
        patientsId: json["patients_id"],
        date: json["date"],
        ny: json["ny"],
        comment: json["comment"],
        treatOut: json["treat_out"],
        creationDate: json["creation_date"],
        treatAdvEv: json["treat_adv_ev"],
        dateEnd: DateEnd.fromJson(json["date_end"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patients_id": patientsId,
        "date": date,
        "ny": ny,
        "comment": comment,
        "treat_out": treatOut,
        "creation_date": creationDate,
        "treat_adv_ev": treatAdvEv,
        "date_end": dateEnd?.toJson(),
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
