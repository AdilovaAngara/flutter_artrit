
//     final temperatureData = temperatureDataFromJson(jsonString);

import 'dart:convert';

List<DataSprTemperature> dataSprTemperatureFromJson(String str) => List<DataSprTemperature>.from(json.decode(str).map((x) => DataSprTemperature.fromJson(x)));

String dataSprTemperatureToJson(List<DataSprTemperature> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTemperature {
  String id;
  double name;
  bool isHidden;

  DataSprTemperature({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTemperature.fromJson(Map<String, dynamic> json) => DataSprTemperature(
    id: json["id"],
    name: json["name"]?.toDouble(),
    isHidden: json["IsHidden"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "IsHidden": isHidden,
  };
}
