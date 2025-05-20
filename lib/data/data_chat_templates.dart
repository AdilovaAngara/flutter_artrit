// To parse this JSON data, do
//
//     final dataChatTemplates = dataChatTemplatesFromJson(jsonString);

import 'dart:convert';

DataChatTemplates dataChatTemplatesFromJson(String str) => DataChatTemplates.fromJson(json.decode(str));

String dataChatTemplatesToJson(DataChatTemplates data) => json.encode(data.toJson());

class DataChatTemplates {
  bool success;
  dynamic userMessage;
  List<TemplatesResult>? result;

  DataChatTemplates({
    required this.success,
    required this.userMessage,
    required this.result,
  });

  factory DataChatTemplates.fromJson(Map<String, dynamic> json) => DataChatTemplates(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: List<TemplatesResult>.from(json["Result"].map((x) => TemplatesResult.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result != null ? List<dynamic>.from(result!.map((x) => x.toJson())) : null,
  };
}

class TemplatesResult {
  int? messageType;
  String? messageTypeStr;
  List<String> messages;

  TemplatesResult({
    required this.messageType,
    required this.messageTypeStr,
    required this.messages,
  });

  factory TemplatesResult.fromJson(Map<String, dynamic> json) => TemplatesResult(
    messageType: json["MessageType"],
    messageTypeStr: json["MessageTypeStr"],
    messages: List<String>.from(json["Messages"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "MessageType": messageType,
    "MessageTypeStr": messageTypeStr,
    "Messages": List<dynamic>.from(messages.map((x) => x)),
  };
}
