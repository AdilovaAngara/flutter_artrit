//     final dataTestsOtherTestsNames = dataTestsOtherTestsNamesFromJson(jsonString);

import 'dart:convert';

List<DataSprOtherTestsNames> dataSprOtherTestsNamesFromJson(String str) => List<DataSprOtherTestsNames>.from(json.decode(str).map((x) => DataSprOtherTestsNames.fromJson(x)));

String dataSprOtherTestsNamesToJson(List<DataSprOtherTestsNames> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprOtherTestsNames {
  String id;
  String name;
  String keyName;
  String analysisGroupId;

  DataSprOtherTestsNames({
    required this.id,
    required this.name,
    required this.keyName,
    required this.analysisGroupId,
  });

  factory DataSprOtherTestsNames.fromJson(Map<String, dynamic> json) => DataSprOtherTestsNames(
    id: json["id"],
    name: json["name"],
    keyName: json["KeyName"],
    analysisGroupId: json["AnalysisGroupId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "KeyName": keyName,
    "AnalysisGroupId": analysisGroupId,
  };
}
