//     final dataSprDoctors = dataSprDoctorsFromJson(jsonString);

import 'dart:convert';

List<DataSprDoctors> dataSprDoctorsFromJson(String str) => List<DataSprDoctors>.from(json.decode(str).map((x) => DataSprDoctors.fromJson(x)));

String dataSprDoctorsToJson(List<DataSprDoctors> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprDoctors {
  String id;
  String? name;

  DataSprDoctors({
    required this.id,
    required this.name,
  });

  factory DataSprDoctors.fromJson(Map<String, dynamic> json) => DataSprDoctors(
    id: json["Id"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
  };
}
