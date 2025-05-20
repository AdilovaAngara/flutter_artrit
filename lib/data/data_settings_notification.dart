// To parse this JSON data, do
//
//     final dataSettingsNotification = dataSettingsNotificationFromJson(jsonString);

import 'dart:convert';

DataSettingsNotification dataSettingsNotificationFromJson(String str) => DataSettingsNotification.fromJson(json.decode(str));

String dataSettingsNotificationToJson(DataSettingsNotification data) => json.encode(data.toJson());

class DataSettingsNotification {
  int notificationReceiveType;

  DataSettingsNotification({
    required this.notificationReceiveType,
  });

  factory DataSettingsNotification.fromJson(Map<String, dynamic> json) => DataSettingsNotification(
    notificationReceiveType: json["NotificationReceiveType"],
  );

  Map<String, dynamic> toJson() => {
    "NotificationReceiveType": notificationReceiveType,
  };
}
