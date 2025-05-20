//     final dataDoctor = dataDoctorFromJson(jsonString);

import 'dart:convert';


enum Enum{
  firstName,
  lastName,
  patronymic,
  email,
  phone,
  regionName,
  hospitalName,
}

DataDoctor dataDoctorFromJson(String str) => DataDoctor.fromJson(json.decode(str));

String dataDoctorToJson(DataDoctor data) => json.encode(data.toJson());

class DataDoctor {
  String? id;
  dynamic substitutionalId;
  dynamic substitutionalName;
  String? positionId;
  String? positionName;
  String? departmentId;
  String? departmentName;
  int? patientsCount;
  String? roleId;
  String? roleName;
  String? regionId;
  String? regionName;
  String? hospitalId;
  String? hospitalName;
  String? lastName;
  String? firstName;
  String? patronymic;
  dynamic fullName;
  String? email;
  String? phone;

  DataDoctor({
    required this.id,
    this.substitutionalId,
    this.substitutionalName,
    this.positionId,
    this.positionName,
    this.departmentId,
    this.departmentName,
    this.patientsCount,
    this.roleId,
    this.roleName,
    required this.regionId,
    required this.regionName,
    required this.hospitalId,
    required this.hospitalName,
    required this.lastName,
    required this.firstName,
    required this.patronymic,
    this.fullName,
    required this.email,
    required this.phone,
  });

  factory DataDoctor.fromJson(Map<String, dynamic> json) => DataDoctor(
    id: json["id"],
    substitutionalId: json["substitutional_Id"],
    substitutionalName: json["substitutionalName"],
    positionId: json["positionId"],
    positionName: json["positionName"],
    departmentId: json["departmentId"],
    departmentName: json["departmentName"],
    patientsCount: json["patients_count"],
    roleId: json["roleId"],
    roleName: json["roleName"],
    regionId: json["regionId"],
    regionName: json["regionName"],
    hospitalId: json["hospitalId"],
    hospitalName: json["hospitalName"],
    lastName: json["last_name"],
    firstName: json["first_name"],
    patronymic: json["patronymic"],
    fullName: json["full_name"],
    email: json["email"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "substitutional_Id": substitutionalId,
    "substitutionalName": substitutionalName,
    "positionId": positionId,
    "positionName": positionName,
    "departmentId": departmentId,
    "departmentName": departmentName,
    "patients_count": patientsCount,
    "roleId": roleId,
    "roleName": roleName,
    "regionId": regionId,
    "regionName": regionName,
    "hospitalId": hospitalId,
    "hospitalName": hospitalName,
    "last_name": lastName,
    "first_name": firstName,
    "patronymic": patronymic,
    "full_name": fullName,
    "email": email,
    "phone": phone,
  };
}
