// To parse this JSON data, do
//
//     final dataSprFrequency = dataSprFrequencyFromJson(jsonString);

import 'dart:convert';

List<DataSprFrequency> dataSprFrequencyFromJson(String str) => List<DataSprFrequency>.from(json.decode(str).map((x) => DataSprFrequency.fromJson(x)));

String dataSprFrequencyToJson(List<DataSprFrequency> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprFrequency {
  int id;
  String name;

  DataSprFrequency({
    required this.id,
    required this.name,
  });

  factory DataSprFrequency.fromJson(Map<String, dynamic> json) => DataSprFrequency(
    id: json["Id"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
  };
}
