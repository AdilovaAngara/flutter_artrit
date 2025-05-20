// To parse this JSON data, do
//
//     final dataChatContacts = dataChatContactsFromJson(jsonString);

import 'dart:convert';

DataChatContacts dataChatContactsFromJson(String str) => DataChatContacts.fromJson(json.decode(str));

String dataChatContactsToJson(DataChatContacts data) => json.encode(data.toJson());

class DataChatContacts {
  bool success;
  dynamic userMessage;
  List<ResultContacts>? result;

  DataChatContacts({
    required this.success,
    required this.userMessage,
    required this.result,
  });

  factory DataChatContacts.fromJson(Map<String, dynamic> json) => DataChatContacts(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: List<ResultContacts>.from(json["Result"].map((x) => ResultContacts.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result != null ? List<dynamic>.from(result!.map((x) => x.toJson())) : null,
  };
}

class ResultContacts {
  String clientUserId;
  String userFio;
  int messageCount;

  ResultContacts({
    required this.clientUserId,
    required this.userFio,
    required this.messageCount,
  });

  factory ResultContacts.fromJson(Map<String, dynamic> json) => ResultContacts(
    clientUserId: json["ClientUserId"],
    userFio: json["UserFio"],
    messageCount: json["MessageCount"],
  );

  Map<String, dynamic> toJson() => {
    "ClientUserId": clientUserId,
    "UserFio": userFio,
    "MessageCount": messageCount,
  };
}
