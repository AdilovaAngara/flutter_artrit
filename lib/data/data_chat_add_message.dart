// To parse this JSON data, do
//
//     final dataChatAddMessage = dataChatAddMessageFromJson(jsonString);

import 'dart:convert';

DataChatAddMessage dataChatAddMessageFromJson(String str) => DataChatAddMessage.fromJson(json.decode(str));

String dataChatAddMessageToJson(DataChatAddMessage data) => json.encode(data.toJson());

class DataChatAddMessage {
  String toId;
  String message;
  List<dynamic> files;

  DataChatAddMessage({
    required this.toId,
    required this.message,
    required this.files,
  });

  factory DataChatAddMessage.fromJson(Map<String, dynamic> json) => DataChatAddMessage(
    toId: json["ToId"],
    message: json["Message"],
    files: List<dynamic>.from(json["Files"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "ToId": toId,
    "Message": message,
    "Files": List<dynamic>.from(files.map((x) => x)),
  };
}
