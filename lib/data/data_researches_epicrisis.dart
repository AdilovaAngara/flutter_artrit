import 'dart:convert';

enum Enum{
  date,
  institution,
  filename,
  comment,
}

List<DataResearchesEpicrisis> dataResearchesEpicrisisFromJson(String str) => List<DataResearchesEpicrisis>.from(json.decode(str).map((x) => DataResearchesEpicrisis.fromJson(x)));

String dataResearchesEpicrisisToJson(List<DataResearchesEpicrisis> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataResearchesEpicrisis {
  String? id;
  String? patientId;
  String? name;
  int? date;
  String? institution;
  String? comment;
  List<String>? fileIds;
  int? creationDate;
  List<String>? filename;

  DataResearchesEpicrisis({
    this.id,
    required this.patientId,
    this.name,
    required this.date,
    required this.institution,
    required this.comment,
    required this.fileIds,
    required this.creationDate,
    this.filename,
  });

  factory DataResearchesEpicrisis.fromJson(Map<String, dynamic> json) => DataResearchesEpicrisis(
    id: json["id"],
    patientId: json["patient_id"],
    name: json["name"],
    date: json["date"],
    institution: json["institution"],
    comment: json["comment"],
    fileIds: json["file_ids"] != null ? List<String>.from(json["file_ids"].map((x) => x)) : null,
    creationDate: json["creation_date"],
    filename: json["filename"] != null ? List<String>.from(json["filename"].map((x) => x)) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient_id": patientId,
    "name": name,
    "date": date,
    "institution": institution,
    "comment": comment,
    "file_ids": fileIds != null ? List<dynamic>.from(fileIds!.map((x) => x)) : null,
    "creation_date": creationDate,
    "filename": filename != null ? List<dynamic>.from(filename!.map((x) => x)) : null,
  };
}
