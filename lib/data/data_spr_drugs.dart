//     final dataDrugs = dataDrugsFromJson(jsonString);

import 'dart:convert';

List<DataSprDrugs> dataSprDrugsFromJson(String str) => List<DataSprDrugs>.from(json.decode(str).map((x) => DataSprDrugs.fromJson(x)));

String dataSprDrugsToJson(List<DataSprDrugs> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprDrugs {
  String id;
  String? name;
  bool? isTuberculosisInfection;

  DataSprDrugs({
    required this.id,
    required this.name,
    required this.isTuberculosisInfection,
  });

  factory DataSprDrugs.fromJson(Map<String, dynamic> json) => DataSprDrugs(
    id: json["Id"],
    name: json["Name"],
    isTuberculosisInfection: json["IsTuberculosisInfection"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
    "IsTuberculosisInfection": isTuberculosisInfection,
  };
}
