//     final dataSprResearchTuberculosisType = dataSprResearchTuberculosisTypeFromJson(jsonString);

import 'dart:convert';

List<DataSprResearchTuberculinType> dataSprResearchTuberculinTypeFromJson(String str) => List<DataSprResearchTuberculinType>.from(json.decode(str).map((x) => DataSprResearchTuberculinType.fromJson(x)));

String dataSprResearchTuberculinTypeToJson(List<DataSprResearchTuberculinType> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprResearchTuberculinType {
  String id;
  String? name;

  DataSprResearchTuberculinType({
    required this.id,
    required this.name,
  });

  factory DataSprResearchTuberculinType.fromJson(Map<String, dynamic> json) => DataSprResearchTuberculinType(
    id: json["id"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "Name": name,
  };
}
