//     final dataTreatmentSkippingReasons = dataTreatmentSkippingReasonsFromJson(jsonString);

import 'dart:convert';

List<DataSprTreatmentSkippingReasons> dataSprTreatmentSkippingReasonsFromJson(String str) => List<DataSprTreatmentSkippingReasons>.from(json.decode(str).map((x) => DataSprTreatmentSkippingReasons.fromJson(x)));

String dataSprTreatmentSkippingReasonsToJson(List<DataSprTreatmentSkippingReasons> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataSprTreatmentSkippingReasons {
  String id;
  String? name;
  bool? isHidden;

  DataSprTreatmentSkippingReasons({
    required this.id,
    required this.name,
    required this.isHidden,
  });

  factory DataSprTreatmentSkippingReasons.fromJson(Map<String, dynamic> json) => DataSprTreatmentSkippingReasons(
    id: json["id"],
    name: json["name"],
    isHidden: json["IsHidden"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "IsHidden": isHidden,
  };
}
