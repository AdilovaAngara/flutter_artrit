//     final dataInspectionsJointsFavorite = dataInspectionsJointsFavoriteFromJson(jsonString);

import 'dart:convert';

List<DataInspectionsJointsFavorite> dataInspectionsJointsFavoriteFromJson(String str) => List<DataInspectionsJointsFavorite>.from(json.decode(str).map((x) => DataInspectionsJointsFavorite.fromJson(x)));

String dataInspectionsJointsFavoriteToJson(List<DataInspectionsJointsFavorite> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataInspectionsJointsFavorite {
  String? patientId;
  String? jointId;
  String? jointName;

  DataInspectionsJointsFavorite({
    required this.patientId,
    required this.jointId,
    required this.jointName,
  });

  factory DataInspectionsJointsFavorite.fromJson(Map<String, dynamic> json) => DataInspectionsJointsFavorite(
    patientId: json["patient_id"],
    jointId: json["joint_id"],
    jointName: json["jointName"],
  );

  Map<String, dynamic> toJson() => {
    "patient_id": patientId,
    "joint_id": jointId,
    "jointName": jointName,
  };
}
