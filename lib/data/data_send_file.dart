//     final sendFileData = sendFileDataFromJson(jsonString);

import 'dart:convert';

DataSendFile dataSendFileFromJson(String str) => DataSendFile.fromJson(json.decode(str));

String dataSendFileToJson(DataSendFile data) => json.encode(data.toJson());

class DataSendFile {
  String id;
  String filename;
  String filetype;
  int filesize;
  String filedate;

  DataSendFile({
    required this.id,
    required this.filename,
    required this.filetype,
    required this.filesize,
    required this.filedate,
  });

  factory DataSendFile.fromJson(Map<String, dynamic> json) => DataSendFile(
    id: json["id"],
    filename: json["filename"],
    filetype: json["filetype"],
    filesize: json["filesize"],
    filedate: json["filedate"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "filename": filename,
    "filetype": filetype,
    "filesize": filesize,
    "filedate": filedate,
  };
}
