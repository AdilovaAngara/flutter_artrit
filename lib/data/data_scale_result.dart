import 'dart:convert';

DataScaleResult dataScaleResultFromJson(String str) => DataScaleResult.fromJson(json.decode(str));

String dataScaleResultToJson(DataScaleResult data) => json.encode(data.toJson());

class DataScaleResult {
  bool? success;
  dynamic userMessage; // Оставляем dynamic, если сообщение может быть разным
  Result? result; // Изменяем тип на Result?

  DataScaleResult({
    required this.success,
    required this.userMessage,
    required this.result,
  });

  factory DataScaleResult.fromJson(Map<String, dynamic> json) => DataScaleResult(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: json["Result"] != null ? Result.fromJson(json["Result"]) : null, // Преобразуем в Result
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result?.toJson(),
  };
}

class Result {
  String? id;
  String? patientId;
  DateTime? calculateDate;
  dynamic indexResult;
  DateTime? createdOn;

  Result({
    this.id,
    this.patientId,
    this.calculateDate,
    this.indexResult,
    this.createdOn,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["Id"],
    patientId: json["PatientId"],
    calculateDate: json["CalculateDate"] != null ? DateTime.parse(json["CalculateDate"]) : null,
    indexResult: json["IndexResult"],
    createdOn: json["CreatedOn"] != null ? DateTime.parse(json["CreatedOn"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PatientId": patientId,
    "CalculateDate": calculateDate?.toIso8601String(),
    "IndexResult": indexResult,
    "CreatedOn": createdOn?.toIso8601String(),
  };
}