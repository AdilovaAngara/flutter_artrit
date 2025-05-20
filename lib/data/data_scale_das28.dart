//     final DataScaleDas28 = DataScaleDas28FromJson(jsonString);

import 'dart:convert';

List<DataScaleDas28> dataScaleDas28FromJson(String str) => List<DataScaleDas28>.from(json.decode(str).map((x) => DataScaleDas28.fromJson(x)));

String dataScaleDas28ToJson(List<DataScaleDas28> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataScaleDas28 {
  String? id;
  String? patientId;
  DateTime? calculateDate;
  double? indexResult;
  DateTime? createdOn;

  DataScaleDas28({
    this.id,
    this.patientId,
    this.calculateDate,
    this.indexResult,
    this.createdOn,
  });

  factory DataScaleDas28.fromJson(Map<String, dynamic> json) => DataScaleDas28(
    id: json["Id"],
    patientId: json["PatientId"],
    calculateDate: DateTime.parse(json["CalculateDate"]),
    indexResult: json["IndexResult"]?.toDouble(),
    createdOn: DateTime.parse(json["CreatedOn"]),
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PatientId": patientId,
    "CalculateDate": calculateDate?.toIso8601String(),
    "IndexResult": indexResult,
    "CreatedOn": createdOn?.toIso8601String(),
  };
}
