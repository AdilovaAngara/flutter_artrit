import 'dart:convert';
import 'blood_test_items.dart';

enum Enum{
  date,
  rheumatoidFactor,
  cReactiveProtein,
  antinuclearFactor,
  antiCcp,
}

DataTestsImmunology dataTestsImmunologyFromJson(String str) => DataTestsImmunology.fromJson(json.decode(str));

String dataTestsImmunologyToJson(DataTestsImmunology data) => json.encode(data.toJson());

class DataTestsImmunology {
  Items items;
  String patientId;
  int? date;
  bool isCreate;

  DataTestsImmunology({
    required this.items,
    required this.patientId,
    required this.date,
    required this.isCreate,
  });

  factory DataTestsImmunology.fromJson(Map<String, dynamic> json) => DataTestsImmunology(
    items: Items.fromJson(json["items"]),
    patientId: json["patientId"],
    date: json["date"],
    isCreate: json["isCreate"],
  );

  Map<String, dynamic> toJson() => {
    "items": items.toJson(),
    "patientId": patientId,
    "date": date,
    "isCreate": isCreate,
  };
}

class Items {
  BloodTestItems rheumatoidFactor;
  BloodTestItems cReactiveProtein;
  BloodTestItems antinuclearFactor;
  BloodTestItems antiCcp;

  Items({
    required this.rheumatoidFactor,
    required this.cReactiveProtein,
    required this.antinuclearFactor,
    required this.antiCcp,
  });

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    rheumatoidFactor: BloodTestItems.fromJson(json["RheumatoidFactor"]),
    cReactiveProtein: BloodTestItems.fromJson(json["C_ReactiveProtein"]),
    antinuclearFactor: BloodTestItems.fromJson(json["AntinuclearFactor"]),
    antiCcp: BloodTestItems.fromJson(json["AntiCCP"]),
  );

  Map<String, dynamic> toJson() => {
    "RheumatoidFactor": rheumatoidFactor.toJson(),
    "C_ReactiveProtein": cReactiveProtein.toJson(),
    "AntinuclearFactor": antinuclearFactor.toJson(),
    "AntiCCP": antiCcp.toJson(),
  };
}

