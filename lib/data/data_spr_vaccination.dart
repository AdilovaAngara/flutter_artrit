//     final dataSprVaccination = dataSprVaccinationFromJson(jsonString);

import 'dart:convert';

List<DataSprVaccination> dataSprVaccinationFromJson(String str) => List<DataSprVaccination>.from(json.decode(str).map((x) => DataSprVaccination.fromJson(x)));

String dataSprVaccinationToJson(List<DataSprVaccination> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprVaccination {
  String? id;
  String? name;
  bool? isHidden;

  DataSprVaccination({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprVaccination.fromJson(Map<String, dynamic> json) => DataSprVaccination(
    id: json["id"],
    name: json["name"],
    isHidden: json["IsHidden"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "IsHidden": isHidden,
  };
}
