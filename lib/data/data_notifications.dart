// To parse this JSON data, do
//
//     final dataNotifications = dataNotificationsFromJson(jsonString);

import 'dart:convert';

List<DataNotificationsForPatient> dataNotificationsFromJson(String str) => List<DataNotificationsForPatient>.from(json.decode(str).map((x) => DataNotificationsForPatient.fromJson(x)));

String dataNotificationsToJson(List<DataNotificationsForPatient> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataNotificationsForPatient {
  String id;
  String? userId;
  int? typeId;
  Data? data;
  DateTime? createdOn;
  bool? isRead;

  DataNotificationsForPatient({
    required this.id,
    required this.userId,
    required this.typeId,
    required this.data,
    required this.createdOn,
    required this.isRead,
  });

  factory DataNotificationsForPatient.fromJson(Map<String, dynamic> json) => DataNotificationsForPatient(
    id: json["Id"],
    userId: json["UserId"],
    typeId: json["TypeId"],
    data: json["Data"] != null ? Data.fromJson(json["Data"]) : null, // Проверка на null
    createdOn: DateTime.parse(json["CreatedOn"]),
    isRead: json["IsRead"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "UserId": userId,
    "TypeId": typeId,
    "Data": data?.toJson(),
    "CreatedOn": createdOn?.toIso8601String(),
    "IsRead": isRead,
  };
}

class Data {
  List<String>? sections;

  Data({
    required this.sections,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    sections: List<String>.from(json["Sections"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "Sections": sections != null ? List<dynamic>.from(sections!.map((x) => x)) : null,
  };
}
