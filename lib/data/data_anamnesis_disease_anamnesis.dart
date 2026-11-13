import 'dart:convert';

enum Enum {
  dateDisease,
  dateDiagnosis,
}

DataAnamnesisDiseaseAnamnesis dataAnamnesisDiseaseAnamnesisFromJson(
        String str) =>
    DataAnamnesisDiseaseAnamnesis.fromJson(json.decode(str));

String dataAnamnesisDiseaseAnamnesisToJson(
        DataAnamnesisDiseaseAnamnesis data) =>
    json.encode(data.toJson());

class DataAnamnesisDiseaseAnamnesis {
  String? id;
  String? patientsId;
  int? dateDisease;
  int? dateDiagnosis;

  DataAnamnesisDiseaseAnamnesis({
    this.id,
    required this.patientsId,
    this.dateDisease,
    this.dateDiagnosis,
  });

  factory DataAnamnesisDiseaseAnamnesis.fromJson(Map<String?, dynamic>? json) =>
      DataAnamnesisDiseaseAnamnesis(
        id: json?["id"],
        patientsId: json?["patients_id"],
        dateDisease: json?["date_disease"],
        dateDiagnosis: json?["date_diagnosis"],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) "id": id,
        "patients_id": patientsId,
        "date_disease": dateDisease,
        "date_diagnosis": dateDiagnosis,
      };
}
