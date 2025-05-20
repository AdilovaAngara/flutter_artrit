//     final dataScaleJadas71 = dataScaleJadas71FromJson(jsonString);

import 'dart:convert';

List<DataScaleJadas71> dataScaleJadas71FromJson(String str) => List<DataScaleJadas71>.from(json.decode(str).map((x) => DataScaleJadas71.fromJson(x)));

String dataScaleJadas71ToJson(List<DataScaleJadas71> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataScaleJadas71 {
  String? id;
  String? patientId;
  DateTime? calculateDate;
  int? indexResult;
  DateTime? createdOn;

  DataScaleJadas71({
    this.id,
    this.patientId,
    this.calculateDate,
    this.indexResult,
    this.createdOn,
  });

  factory DataScaleJadas71.fromJson(Map<String, dynamic> json) => DataScaleJadas71(
    id: json["Id"],
    patientId: json["PatientId"],
    calculateDate: DateTime.parse(json["CalculateDate"]),
    indexResult: json["IndexResult"],
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



