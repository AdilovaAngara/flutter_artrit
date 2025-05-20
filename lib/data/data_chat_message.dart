// To parse this JSON data, do
//
//     final dataChatMessage = dataChatMessageFromJson(jsonString);

import 'dart:convert';
import 'data_chat_messages.dart';

DataChatMessage dataChatMessageFromJson(String str) => DataChatMessage.fromJson(json.decode(str));

String dataChatMessageToJson(DataChatMessage data) => json.encode(data.toJson());

class DataChatMessage {
  bool success;
  dynamic userMessage;
  Message result;

  DataChatMessage({
    required this.success,
    required this.userMessage,
    required this.result,
  });

  factory DataChatMessage.fromJson(Map<String, dynamic> json) => DataChatMessage(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: Message.fromJson(json["Result"]),
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result.toJson(),
  };
}

