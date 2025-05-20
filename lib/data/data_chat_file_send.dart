// To parse this JSON data, do
//
//     final dataChatFileSend = dataChatFileSendFromJson(jsonString);

import 'dart:convert';

DataChatFileSend dataChatFileSendFromJson(String str) => DataChatFileSend.fromJson(json.decode(str));

String dataChatFileSendToJson(DataChatFileSend data) => json.encode(data.toJson());

class DataChatFileSend {
  bool success;
  dynamic userMessage;
  ResultFileSend result;

  DataChatFileSend({
    required this.success,
    required this.userMessage,
    required this.result,
  });

  factory DataChatFileSend.fromJson(Map<String, dynamic> json) => DataChatFileSend(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: ResultFileSend.fromJson(json["Result"]),
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result.toJson(),
  };
}

class ResultFileSend {
  String id;
  String idStr;
  String filename;
  String filetype;
  int filesize;
  String filedate;

  ResultFileSend({
    required this.id,
    required this.idStr,
    required this.filename,
    required this.filetype,
    required this.filesize,
    required this.filedate,
  });

  factory ResultFileSend.fromJson(Map<String, dynamic> json) => ResultFileSend(
    id: json["id"],
    idStr: json["IdStr"],
    filename: json["filename"],
    filetype: json["filetype"],
    filesize: json["filesize"],
    filedate: json["filedate"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "IdStr": idStr,
    "filename": filename,
    "filetype": filetype,
    "filesize": filesize,
    "filedate": filedate,
  };
}
