//     final dataSprHospitals = dataSprHospitalsFromJson(jsonString);

import 'dart:convert';

List<DataSprHospitals> dataSprHospitalsFromJson(String str) => List<DataSprHospitals>.from(json.decode(str).map((x) => DataSprHospitals.fromJson(x)));

String dataSprHospitalsToJson(List<DataSprHospitals> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprHospitals {
  String id;
  String? name;

  DataSprHospitals({
    required this.id,
    required this.name,
  });

  factory DataSprHospitals.fromJson(Map<String, dynamic> json) => DataSprHospitals(
    id: json["id"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "Name": name,
  };
}
