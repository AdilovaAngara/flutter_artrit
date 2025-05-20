//     final dataAnamnesisFamilyHistory = dataAnamnesisFamilyHistoryFromJson(jsonString);

import 'dart:convert';

enum Enum {
  radioart,
  radiopsor,
  radiokron,
  radioyazkol,
  radiobolbeh,
  radiobobolrey,
  radiobouveit,
  valueart,
  valuepsor,
  valuekron,
  valueyazkol,
  valuebolbeh,
  valuebouveit,
  valuebobolrey,
}

DataAnamnesisFamilyHistory dataAnamnesisFamilyHistoryFromJson(String str) =>
    DataAnamnesisFamilyHistory.fromJson(json.decode(str));

String dataAnamnesisFamilyHistoryToJson(DataAnamnesisFamilyHistory data) => json.encode(data.toJson());

class DataAnamnesisFamilyHistory {
  String? patientId;
  String? radioart;
  String? radiopsor;
  String? radiokron;
  String? radioyazkol;
  String? radiobolbeh;
  String? radiobobolrey;
  String? radiobouveit;
  List<String>? valueart;
  List<String>? valuepsor;
  List<String>? valuekron;
  List<String>? valueyazkol;
  List<String>? valuebolbeh;
  List<String>? valuebouveit;
  List<String>? valuebobolrey;

  DataAnamnesisFamilyHistory({
    this.patientId,
    required this.radioart,
    required this.radiopsor,
    required this.radiokron,
    required this.radioyazkol,
    required this.radiobolbeh,
    required this.radiobobolrey,
    required this.radiobouveit,
    required this.valueart,
    required this.valuepsor,
    required this.valuekron,
    required this.valueyazkol,
    required this.valuebolbeh,
    required this.valuebouveit,
    required this.valuebobolrey,
  });

  factory DataAnamnesisFamilyHistory.fromJson(Map<String, dynamic> json) => DataAnamnesisFamilyHistory(
        patientId: json["PatientId"],
        radioart: json["radioart"],
        radiopsor: json["radiopsor"],
        radiokron: json["radiokron"],
        radioyazkol: json["radioyazkol"],
        radiobolbeh: json["radiobolbeh"],
        radiobobolrey: json["radiobobolrey"],
        radiobouveit: json["radiobouveit"],
        valueart: List<String>.from(json["valueart"].map((x) => x)),
        valuepsor: List<String>.from(json["valuepsor"].map((x) => x)),
        valuekron: List<String>.from(json["valuekron"].map((x) => x)),
        valueyazkol: List<String>.from(json["valueyazkol"].map((x) => x)),
        valuebolbeh: List<String>.from(json["valuebolbeh"].map((x) => x)),
        valuebobolrey: List<String>.from(json["valuebobolrey"].map((x) => x)),
        valuebouveit: List<String>.from(json["valuebouveit"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "PatientId": patientId,
        "radioart": radioart,
        "radiopsor": radiopsor,
        "radiokron": radiokron,
        "radioyazkol": radioyazkol,
        "radiobolbeh": radiobolbeh,
        "radiobobolrey": radiobobolrey,
        "radiobouveit": radiobouveit,
        "valueart": valueart != null
            ? List<dynamic>.from(valueart!.map((x) => x))
            : null,
        "valuepsor": valuepsor != null
            ? List<dynamic>.from(valuepsor!.map((x) => x))
            : null,
        "valuekron": valuekron != null
            ? List<dynamic>.from(valuekron!.map((x) => x))
            : null,
        "valueyazkol": valueyazkol != null
            ? List<dynamic>.from(valueyazkol!.map((x) => x))
            : null,
        "valuebolbeh": valuebolbeh != null
            ? List<dynamic>.from(valuebolbeh!.map((x) => x))
            : null,
        "valuebobolrey": valuebobolrey != null
            ? List<dynamic>.from(valuebobolrey!.map((x) => x))
            : null,
        "valuebouveit": valuebouveit != null
            ? List<dynamic>.from(valuebouveit!.map((x) => x))
            : null,
      };
}
