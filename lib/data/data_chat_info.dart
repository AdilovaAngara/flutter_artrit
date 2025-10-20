// To parse this JSON data, do
//
//     final dataChatInfo = dataChatInfoFromJson(jsonString);

import 'dart:convert';

DataChatInfo dataChatInfoFromJson(String str) => DataChatInfo.fromJson(json.decode(str));

String dataChatInfoToJson(DataChatInfo data) => json.encode(data.toJson());

class DataChatInfo {
  bool success;
  dynamic userMessage;
  ResultChatInfo? result;

  DataChatInfo({
    required this.success,
    required this.userMessage,
    required this.result,
  });

  factory DataChatInfo.fromJson(Map<String, dynamic> json) => DataChatInfo(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: json["Result"] != null ? ResultChatInfo.fromJson(json["Result"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result?.toJson(),
  };
}

class ResultChatInfo {
  String id;
  String doctorId;
  String patientId;
  bool isNew;
  bool allowByDoctor;
  bool allowByPatient;
  bool isClosed;

  ResultChatInfo({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.isNew,
    required this.allowByDoctor,
    required this.allowByPatient,
    required this.isClosed,
  });

  factory ResultChatInfo.fromJson(Map<String, dynamic> json) => ResultChatInfo(
    id: json["Id"],
    doctorId: json["DoctorId"],
    patientId: json["PatientId"],
    isNew: json["IsNew"],
    allowByDoctor: json["AllowByDoctor"],
    allowByPatient: json["AllowByPatient"],
    isClosed: json["IsClosed"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "DoctorId": doctorId,
    "PatientId": patientId,
    "IsNew": isNew,
    "AllowByDoctor": allowByDoctor,
    "AllowByPatient": allowByPatient,
    "IsClosed": isClosed,
  };
}
