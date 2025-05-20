// To parse this JSON data, do
//
//     final dataChatMessages = dataChatMessagesFromJson(jsonString);

import 'dart:convert';

DataChatMessages dataChatMessagesFromJson(String str) => DataChatMessages.fromJson(json.decode(str));

String dataChatMessagesToJson(DataChatMessages data) => json.encode(data.toJson());

class DataChatMessages {
  bool success;
  dynamic userMessage;
  ResultMessages result;

  DataChatMessages({
    required this.success,
    this.userMessage,
    required this.result,
  });

  factory DataChatMessages.fromJson(Map<String, dynamic> json) => DataChatMessages(
    success: json["Success"],
    userMessage: json["UserMessage"],
    result: ResultMessages.fromJson(json["Result"]),
  );

  Map<String, dynamic> toJson() => {
    "Success": success,
    "UserMessage": userMessage,
    "Result": result.toJson(),
  };
}

class ResultMessages {
  int? firstMessageId;
  List<Message> messages;
  String? errorMessage;
  int? lastMessageId;

  ResultMessages({
    required this.firstMessageId,
    required this.messages,
    this.errorMessage,
    required this.lastMessageId,
  });

  factory ResultMessages.fromJson(Map<String, dynamic> json) => ResultMessages(
    firstMessageId: json["FirstMessageId"],
    messages: List<Message>.from(json["Messages"].map((x) => Message.fromJson(x))),
    errorMessage: json["ErrorMessage"],
    lastMessageId: json["LastMessageId"],
  );

  Map<String, dynamic> toJson() => {
    "FirstMessageId": firstMessageId,
    "Messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    "ErrorMessage": errorMessage,
    "LastMessageId": lastMessageId,
  };
}

class Message {
  int id;
  String fromId;
  String toId;
  String artritFromId;
  String artritToId;
  String message;
  bool isRead;
  DateTime created;
  List<FileElement> files;

  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.artritFromId,
    required this.artritToId,
    required this.message,
    required this.isRead,
    required this.created,
    required this.files,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["Id"],
    fromId: json["FromId"],
    toId: json["ToId"],
    artritFromId: json["ArtritFromId"],
    artritToId: json["ArtritToId"],
    message: json["Message"],
    isRead: json["IsRead"],
    created: DateTime.parse(json["Created"]),
    files: List<FileElement>.from(json["Files"].map((x) => FileElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "FromId": fromId,
    "ToId": toId,
    "ArtritFromId": artritFromId,
    "ArtritToId": artritToId,
    "Message": message,
    "IsRead": isRead,
    "Created": created.toIso8601String(),
    "Files": List<dynamic>.from(files.map((x) => x.toJson())),
  };


  Message copyWith({bool? isRead}) {
    return Message(
      id: id,
      artritFromId: artritFromId,
      artritToId: artritToId,
      fromId: fromId,
      toId: toId,
      message: message,
      files: files,
      created: created,
      isRead: isRead ?? this.isRead,
    );
  }

}

class FileElement {
  int? messageId;
  String name;
  String url;

  FileElement({
    this.messageId,
    required this.name,
    required this.url,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
    messageId: json["MessageId"],
    name: json["Name"],
    url: json["Url"],
  );

  Map<String, dynamic> toJson() => {
    "MessageId": messageId,
    "Name": name,
    "Url": url,
  };
}








