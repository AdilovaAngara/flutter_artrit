import 'dart:convert';


enum Enum {
  name,
  frequency,
  beginDate,
  endDate,
  isDisabled,
  sectionIds,
  patientIds
}


List<DataNotificationsSettings> dataNotificationsSettingsFromJson(String str) => List<DataNotificationsSettings>.from(json.decode(str).map((x) => DataNotificationsSettings.fromJson(x)));

String dataNotificationsSettingsToJson(List<DataNotificationsSettings> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataNotificationsSettings {
  String id;
  String doctorId;
  String? name;
  int frequencyId;
  DateTime? beginDate;
  DateTime? endDate;
  bool isDisabled;
  List<int>? sectionIds;
  List<String>? patientIds;

  DataNotificationsSettings({
    required this.id,
    required this.doctorId,
    required this.name,
    required this.frequencyId,
    required this.beginDate,
    required this.endDate,
    required this.isDisabled,
    required this.sectionIds,
    required this.patientIds,
  });

  factory DataNotificationsSettings.fromJson(Map<String, dynamic> json) => DataNotificationsSettings(
    id: json["Id"],
    doctorId: json["DoctorId"],
    name: json["Name"],
    frequencyId: json["FrequencyId"],
    beginDate: DateTime.parse(json["BeginDate"]),
    endDate: DateTime.parse(json["EndDate"]),
    isDisabled: json["IsDisabled"],
    sectionIds: List<int>.from(json["SectionIds"].map((x) => x)),
    patientIds: List<String>.from(json["PatientIds"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "DoctorId": doctorId,
    "Name": name,
    "FrequencyId": frequencyId,
    "BeginDate": beginDate?.toIso8601String(),
    "EndDate": endDate?.toIso8601String(),
    "IsDisabled": isDisabled,
    "SectionIds": sectionIds != null ? List<dynamic>.from(sectionIds!.map((x) => x)) : null,
    "PatientIds": patientIds != null ? List<dynamic>.from(patientIds!.map((x) => x)) : null,
  };
}
