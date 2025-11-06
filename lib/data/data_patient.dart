
//     final userData = userDataFromJson(jsonString);

import 'dart:convert';

enum EnumPatient {
  firstName,
  lastName,
  patronymic,
  birthDate,
  gender,
  regionName,
  address,
  invalid,
  hospitalName,
  doctorFio,
}

DataPatient dataPatientFromJson(String str) => DataPatient.fromJson(json.decode(str));

String dataPatientToJson(DataPatient data) => json.encode(data.toJson());

class DataPatient {
  String regionName;
  String hospitalName;
  dynamic roleName;
  String id;
  String doctor;
  String firstName;
  String? patronymic;
  String lastName;
  String? gender;
  String? address;
  dynamic invalid;
  int? notInvalidReason;
  int? birthDate;
  bool uveit;
  int notificationReceiveType;
  dynamic defaultLabProfileId;
  String? regionId;
  dynamic unknownDoctor;
  String? hospitalId;
  dynamic unknownHospital;
  String? roleId;
  String? doctorFio;
  double? questionnaireResult;
  int lastInspectionUveit;

  DataPatient({
    required this.regionName,
    required this.hospitalName,
    this.roleName,
    required this.id,
    required this.doctor,
    required this.firstName,
    this.patronymic,
    required this.lastName,
    required this.gender,
    this.address,
    required this.invalid,
    required this.notInvalidReason,
    required this.birthDate,
    required this.uveit,
    required this.notificationReceiveType,
    this.defaultLabProfileId,
    required this.regionId,
    this.unknownDoctor,
    required this.hospitalId,
    this.unknownHospital,
    required this.roleId,
    required this.doctorFio,
    required this.questionnaireResult,
    required this.lastInspectionUveit,
  });

  factory DataPatient.fromJson(Map<String, dynamic> json) => DataPatient(
    regionName: json["regionName"],
    hospitalName: json["hospitalName"],
    roleName: json["roleName"],
    id: json["id"],
    doctor: json["doctor"].toString(),
    firstName: json["first_name"],
    patronymic: json["patronymic"],
    lastName: json["last_name"],
    gender: json["gender"],
    address: json["address"],
    invalid: json["invalid"],
    notInvalidReason: json["not_invalid_reason"],
    birthDate: json["birth_date"],
    uveit: json["Uveit"],
    notificationReceiveType: json["NotificationReceiveType"],
    defaultLabProfileId: json["DefaultLabProfileId"],
    regionId: json["regionId"],
    unknownDoctor: json["unknownDoctor"],
    hospitalId: json["hospitalId"],
    unknownHospital: json["unknownHospital"],
    roleId: json["roleId"],
    doctorFio: json["DoctorFIO"],
    questionnaireResult: json["questionnaire_result"] ?? 0.0,
    lastInspectionUveit: json["LastInspectionUveit"],
  );

  Map<String, dynamic> toJson() => {
    "regionName": regionName,
    "hospitalName": hospitalName,
    "roleName": roleName,
    "id": id,
    "doctor": doctor.toString(),
    "first_name": firstName,
    "patronymic": patronymic,
    "last_name": lastName,
    "gender": gender,
    "address": address,
    "invalid": invalid,
    "not_invalid_reason": notInvalidReason,
    "birth_date": birthDate,
    "Uveit": uveit,
    "NotificationReceiveType": notificationReceiveType,
    "DefaultLabProfileId": defaultLabProfileId,
    "regionId": regionId,
    "unknownDoctor": unknownDoctor,
    "hospitalId": hospitalId,
    "unknownHospital": unknownHospital,
    "roleId": roleId,
    "DoctorFIO": doctorFio,
    "questionnaire_result": questionnaireResult,
    "LastInspectionUveit": lastInspectionUveit,
  };
}
