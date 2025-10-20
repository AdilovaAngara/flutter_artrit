//     final dataTestsOther = dataTestsOtherFromJson(jsonString);

import 'dart:convert';

enum Enum{
  date,
  analys,
  znachNum,
}


List<DataTestsOther> dataTestsOtherFromJson(String str) => List<DataTestsOther>.from(json.decode(str).map((x) => DataTestsOther.fromJson(x)));

String dataTestsOtherToJson(List<DataTestsOther> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTestsOther {
  String? id;
  String? patientsId;
  int? date;
  String? parametersId;
  String? analys;
  Znach znach;
  String? unitsId;
  int? creationDate;
  bool? norma;

  DataTestsOther({
    this.id,
    this.patientsId,
    required this.date,
    required this.parametersId,
    required this.analys,
    required this.znach,
    required this.unitsId,
    required this.creationDate,
    this.norma,
  });

  factory DataTestsOther.fromJson(Map<String, dynamic> json) => DataTestsOther(
    id: json["id"],
    patientsId: json["patients_id"],
    date: json["date"],
    parametersId: json["parameters_id"],
    analys: json["analys"],
    znach: Znach.fromJson(json["znach"]),
    unitsId: json["units_id"],
    creationDate: json["creation_date"],
    norma: json["norma"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patients_id": patientsId,
    "date": date,
    "parameters_id": parametersId,
    "analys": analys,
    "znach": znach.toJson(),
    "units_id": unitsId,
    "creation_date": creationDate,
    "norma": norma,
  };
}


class Znach {
  double? num;
  String? sel;

  Znach({
    required this.num,
    required this.sel,
  });

  factory Znach.fromJson(Map<String, dynamic> json) => Znach(
    num: json["num"],
    sel: json["sel"],
  );

  Map<String, dynamic> toJson() => {
    "num": num,
    "sel": sel,
  };
}
