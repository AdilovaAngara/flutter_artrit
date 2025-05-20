//     final dataSprResearchTuberculosisResult = dataSprResearchTuberculosisResultFromJson(jsonString);

import 'dart:convert';

List<DataSprResearchTuberculinResult> dataSprResearchTuberculinResultFromJson(String str) => List<DataSprResearchTuberculinResult>.from(json.decode(str).map((x) => DataSprResearchTuberculinResult.fromJson(x)));

String dataSprResearchTuberculinResultToJson(List<DataSprResearchTuberculinResult> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprResearchTuberculinResult {
  String id;
  String? name;

  DataSprResearchTuberculinResult({
    required this.id,
    required this.name,
  });

  factory DataSprResearchTuberculinResult.fromJson(Map<String, dynamic> json) => DataSprResearchTuberculinResult(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
