//     final dataPatientRegister = dataPatientRegisterFromJson(jsonString);

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
  unknownHospital,
  doctorFio,
  unknownDoctor,
  uveit,
  canContainCookies,
  diagnosisComment,
}

enum EnumParent {
  firstName,
  lastName,
  patronymic,
  email,
  phone,
  relationshipDegreeId,
}

DataPatientRegister dataPatientRegisterFromJson(String str) => DataPatientRegister.fromJson(json.decode(str));

String dataPatientRegisterToJson(DataPatientRegister data) => json.encode(data.toJson());

class DataPatientRegister {
  String? firstName;
  String? lastName;
  dynamic patrynomic;
  DateTime? birthDate;
  String? regionId;
  String? isMale;
  dynamic isFemale;
  String? diagnosisId;
  dynamic diagnosisComment;
  bool? uveit;
  String? doctorId;
  dynamic unknownDoctor;
  String? hospitalId;
  String? unknownHospital;
  bool canContainCookies;
  String? relationshipDegreeId;
  String? applicantFirstName;
  String? applicantLastName;
  dynamic applicantPatrynomic;
  String? applicantEmail;
  String? applicantPhone;
  int? notificationReceiveType;

  DataPatientRegister({
    required this.firstName,
    required this.lastName,
    required this.patrynomic,
    required this.birthDate,
    required this.regionId,
    required this.isMale,
    required this.isFemale,
    required this.diagnosisId,
    required this.diagnosisComment,
    required this.uveit,
    required this.doctorId,
    required this.unknownDoctor,
    required this.hospitalId,
    required this.unknownHospital,
    required this.canContainCookies,
    required this.relationshipDegreeId,
    required this.applicantFirstName,
    required this.applicantLastName,
    required this.applicantPatrynomic,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.notificationReceiveType,
  });

  factory DataPatientRegister.fromJson(Map<String, dynamic> json) => DataPatientRegister(
    firstName: json["FirstName"],
    lastName: json["LastName"],
    patrynomic: json["Patrynomic"],
    birthDate: DateTime.parse(json["BirthDate"]),
    regionId: json["RegionId"],
    isMale: json["IsMale"],
    isFemale: json["IsFemale"],
    diagnosisId: json["DiagnosisId"],
    diagnosisComment: json["DiagnosisComment"],
    uveit: json["Uveit"],
    doctorId: json["DoctorId"],
    unknownDoctor: json["UnknownDoctor"],
    hospitalId: json["HospitalId"],
    unknownHospital: json["UnknownHospital"],
    canContainCookies: json["CanContainCookies"],
    relationshipDegreeId: json["RelationshipDegreeId"],
    applicantFirstName: json["ApplicantFirstName"],
    applicantLastName: json["ApplicantLastName"],
    applicantPatrynomic: json["ApplicantPatrynomic"],
    applicantEmail: json["ApplicantEmail"],
    applicantPhone: json["ApplicantPhone"],
    notificationReceiveType: json["NotificationReceiveType"],
  );

  Map<String, dynamic> toJson() => {
    "FirstName": firstName,
    "LastName": lastName,
    "Patrynomic": patrynomic,
    "BirthDate": birthDate?.toIso8601String(),
    "RegionId": regionId,
    "IsMale": isMale,
    "IsFemale": isFemale,
    "DiagnosisId": diagnosisId,
    "DiagnosisComment": diagnosisComment,
    "Uveit": uveit,
    "DoctorId": doctorId,
    "UnknownDoctor": unknownDoctor,
    "HospitalId": hospitalId,
    "UnknownHospital": unknownHospital,
    "CanContainCookies": canContainCookies,
    "RelationshipDegreeId": relationshipDegreeId,
    "ApplicantFirstName": applicantFirstName,
    "ApplicantLastName": applicantLastName,
    "ApplicantPatrynomic": applicantPatrynomic,
    "ApplicantEmail": applicantEmail,
    "ApplicantPhone": applicantPhone,
    "NotificationReceiveType": notificationReceiveType,
  };
}
