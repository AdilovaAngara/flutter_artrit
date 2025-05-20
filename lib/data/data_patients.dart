import 'dart:convert';

List<DataPatients> dataPatientsFromJson(String str) => List<DataPatients>.from(json.decode(str).map((x) => DataPatients.fromJson(x)));

String dataPatientsToJson(List<DataPatients> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataPatients {
  dynamic unknownHospital;
  dynamic unknownDoctor;
  String roleId;
  dynamic roleName;
  String regionId;
  String regionName;
  String hospitalId;
  String hospitalName;
  String userid;
  String id;
  int birthDate;
  String? gender;
  String? address;
  String doctor;
  dynamic doctorFio;
  bool? invalid;
  String? notInvalidReason;
  bool uveit;
  int notificationReceiveType;
  String? diag;
  dynamic defaultLabProfileId;
  String lastName;
  String firstName;
  String? patronymic;
  dynamic fullName;
  String email;
  String phone;

  DataPatients({
    required this.unknownHospital,
    required this.unknownDoctor,
    required this.roleId,
    required this.roleName,
    required this.regionId,
    required this.regionName,
    required this.hospitalId,
    required this.hospitalName,
    required this.userid,
    required this.id,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.doctor,
    required this.doctorFio,
    required this.invalid,
    required this.notInvalidReason,
    required this.uveit,
    required this.notificationReceiveType,
    required this.diag,
    required this.defaultLabProfileId,
    required this.lastName,
    required this.firstName,
    required this.patronymic,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory DataPatients.fromJson(Map<String, dynamic> json) => DataPatients(
    unknownHospital: json["UnknownHospital"],
    unknownDoctor: json["UnknownDoctor"],
    roleId: json["roleId"],
    roleName: json["roleName"],
    regionId: json["regionId"],
    regionName: json["regionName"],
    hospitalId: json["hospitalId"],
    hospitalName: json["hospitalName"],
    userid: json["userid"],
    id: json["id"],
    birthDate: json["birth_date"],
    gender: json["gender"],
    address: json["address"],
    doctor: json["doctor"],
    doctorFio: json["doctor_fio"],
    invalid: json["invalid"],
    notInvalidReason: json["not_invalid_reason"],
    uveit: json["Uveit"],
    notificationReceiveType: json["NotificationReceiveType"],
    diag: json["diag"],
    defaultLabProfileId: json["DefaultLabProfileId"],
    lastName: json["last_name"],
    firstName: json["first_name"],
    patronymic: json["patronymic"],
    fullName: json["full_name"],
    email: json["email"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "UnknownHospital": unknownHospital,
    "UnknownDoctor": unknownDoctor,
    "roleId": roleId,
    "roleName": roleName,
    "regionId": regionId,
    "regionName": regionName,
    "hospitalId": hospitalId,
    "hospitalName": hospitalName,
    "userid": userid,
    "id": id,
    "birth_date": birthDate,
    "gender": gender,
    "address": address,
    "doctor": doctor,
    "doctor_fio": doctorFio,
    "invalid": invalid,
    "not_invalid_reason": notInvalidReason,
    "Uveit": uveit,
    "NotificationReceiveType": notificationReceiveType,
    "diag": diag,
    "DefaultLabProfileId": defaultLabProfileId,
    "last_name": lastName,
    "first_name": firstName,
    "patronymic": patronymic,
    "full_name": fullName,
    "email": email,
    "phone": phone,
  };
}



