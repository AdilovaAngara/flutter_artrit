
//     final parentData = parentDataFromJson(jsonString);

import 'dart:convert';

enum EnumParent {
  firstName,
  lastName,
  patronymic,
  email,
  phone,
  whoYouAreToThePatient,
}

DataParent dataParentFromJson(String str) => DataParent.fromJson(json.decode(str));

String dataParentToJson(DataParent data) => json.encode(data.toJson());

class DataParent {
  String? whoYouAreToThePatient;
  String id;
  String? lastName;
  String? firstName;
  String? patronymic;
  String? email;
  String? phone;
  String? patientsId;
  String? relationshipDegreeId;

  DataParent({
    required this.whoYouAreToThePatient,
    required this.id,
    required this.lastName,
    required this.firstName,
    this.patronymic,
    required this.email,
    required this.phone,
    required this.patientsId,
    required this.relationshipDegreeId,
  });

  factory DataParent.fromJson(Map<String, dynamic> json) => DataParent(
    whoYouAreToThePatient: json["whoYouAreToThePatient"],
    id: json["id"],
    lastName: json["last_name"],
    firstName: json["first_name"],
    patronymic: json["patronymic"],
    email: json["email"],
    phone: json["phone"],
    patientsId: json["patients_id"],
    relationshipDegreeId: json["relationshipDegreeId"],
  );

  Map<String, dynamic> toJson() => {
    "whoYouAreToThePatient": whoYouAreToThePatient,
    "id": id,
    "last_name": lastName,
    "first_name": firstName,
    "patronymic": patronymic,
    "email": email,
    "phone": phone,
    "patients_id": patientsId,
    "relationshipDegreeId": relationshipDegreeId,
  };
}
