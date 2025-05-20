//     final dataResearchesTuberculin = dataResearchesTuberculinFromJson(jsonString);

import 'dart:convert';

enum Enum{
  date,
  researchName,
  resultName,
  value,
}


List<DataResearchesTuberculin> dataResearchesTuberculinFromJson(String str) => List<DataResearchesTuberculin>.from(json.decode(str).map((x) => DataResearchesTuberculin.fromJson(x)));

String dataResearchesTuberculinToJson(List<DataResearchesTuberculin> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataResearchesTuberculin {
  String? id;
  String? patientId;
  double? value;
  Res? researchItem;
  Res? result;
  DateTime? date;
  int? createDate;
  String? researchItemId;
  String? resultId;

  DataResearchesTuberculin({
    this.id,
    this.patientId,
    required this.value,
    this.researchItem,
    this.result,
    required this.date,
    required this.createDate,
    this.researchItemId,
    this.resultId,
  });

  factory DataResearchesTuberculin.fromJson(Map<String, dynamic> json) => DataResearchesTuberculin(
    id: json["Id"],
    patientId: json["patientId"],
    value: json["Value"]?.toDouble(),
    researchItem: Res.fromJson(json["ResearchItem"]),
    result: Res.fromJson(json["Result"]),
    date: DateTime.parse(json["Date"]),
    createDate: json["create_date"],
    researchItemId: json["researchItemId"],
    resultId: json["resultId"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "patientId": patientId,
    "Value": value,
    "ResearchItem": researchItem?.toJson(),
    "Result": result?.toJson(),
    "Date": date?.toIso8601String(),
    "create_date": createDate,
    "researchItemId": researchItemId,
    "resultId": resultId,
  };
}

class Res {
  String? id;
  String? name;

  Res({
    required this.id,
    required this.name,
  });

  factory Res.fromJson(Map<String, dynamic> json) => Res(
    id: json["Id"],
    name: json["Name"]!,
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
  };
}



