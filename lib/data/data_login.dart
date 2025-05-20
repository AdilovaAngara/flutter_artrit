
//     final loginData = loginDataFromJson(jsonString);
import 'dart:convert';

enum Enum {
  login,
  password
}

DataLogin dataLoginFromJson(String str) => DataLogin.fromJson(json.decode(str));

String dataLoginToJson(DataLogin data) => json.encode(data.toJson());

class DataLogin {
  String? id;
  int? role;
  String? ssid;
  String login;
  String? password;
  String? patientsId;
  int? agreement;
  String? passwordHash;
  String? passwordSalt;
  String? fio;
  dynamic roleId;
  dynamic canRead;
  dynamic canSet;
  dynamic personalInformation;
  dynamic positionName;

  DataLogin({
    this.id,
    this.role,
    this.ssid,
    required this.login,
    this.password,
    this.patientsId,
    this.agreement,
    this.passwordHash,
    this.passwordSalt,
    this.fio,
    this.roleId,
    this.canRead,
    this.canSet,
    this.personalInformation,
    this.positionName,
  });

  factory DataLogin.fromJson(Map<String, dynamic> json) => DataLogin(
    id: json["id"],
    role: json["role"],
    ssid: json["ssid"],
    login: json["login"],
    password: json["password"],
    patientsId: json["patients_id"],
    agreement: json["agreement"],
    passwordHash: json["PasswordHash"],
    passwordSalt: json["PasswordSalt"],
    fio: json["fio"],
    roleId: json["roleId"],
    canRead: json["CanRead"],
    canSet: json["CanSet"],
    personalInformation: json["PersonalInformation"],
    positionName: json["positionName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": role,
    "ssid": ssid,
    "login": login,
    "password": password,
    "patients_id": patientsId,
    "agreement": agreement,
    "PasswordHash": passwordHash,
    "PasswordSalt": passwordSalt,
    "fio": fio,
    "roleId": roleId,
    "CanRead": canRead,
    "CanSet": canSet,
    "PersonalInformation": personalInformation,
    "positionName": positionName,
  };
}