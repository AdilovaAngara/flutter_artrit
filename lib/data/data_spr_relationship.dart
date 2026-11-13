import 'dart:convert';

List<DataSprRelationship> dataSprRelationshipFromJson(String str) => List<DataSprRelationship>.from(json.decode(str).map((x) => DataSprRelationship.fromJson(x)));

String dataSprRelationshipToJson(List<DataSprRelationship> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprRelationship {
  String id;
  String? name;

  DataSprRelationship({
    required this.id,
    required this.name,
  });

  factory DataSprRelationship.fromJson(Map<String, dynamic> json) => DataSprRelationship(
    id: json["Id"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
  };
}
