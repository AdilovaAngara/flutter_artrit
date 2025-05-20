//     final dataTestsImmunology = dataTestsImmunologyFromJson(jsonString);

import 'dart:convert';

List<DataTestsImmunologyList> dataTestsImmunologyListFromJson(String str) => List<DataTestsImmunologyList>.from(json.decode(str).map((x) => DataTestsImmunologyList.fromJson(x)));

String dataTestsImmunologyListToJson(List<DataTestsImmunologyList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataTestsImmunologyList {
  int? dateNew;
  double? rheumatoidFactor;
  double? cReactiveProtein;
  double? antinuclearFactor;
  dynamic sip;
  double? antiCcp;
  bool? rheumatoidFactornorma;
  bool? cReactiveProteinnorma;
  bool? antinuclearFactornorma;
  dynamic sipnormanorma;
  bool? antiCcPnorma;
  String? rheumatoidFactorUnit;
  String? cReactiveProteinUnit;
  String? antinuclearFactorUnit;
  dynamic sipUnit;
  String? antiCcpUnit;
  String? rheumatoidFactorId;
  String? cReactiveProteinId;
  String? antinuclearFactorId;
  dynamic sipId;
  String? antiCcpId;
  String? rheumatoidFactorName;
  String? cReactiveProteinName;
  String? antinuclearFactorName;
  dynamic sipName;
  String? antiCcpName;
  int? creationDate;

  DataTestsImmunologyList({
    required this.dateNew,
    required this.rheumatoidFactor,
    required this.cReactiveProtein,
    required this.antinuclearFactor,
    required this.sip,
    required this.antiCcp,
    required this.rheumatoidFactornorma,
    required this.cReactiveProteinnorma,
    required this.antinuclearFactornorma,
    required this.sipnormanorma,
    required this.antiCcPnorma,
    required this.rheumatoidFactorUnit,
    required this.cReactiveProteinUnit,
    required this.antinuclearFactorUnit,
    required this.sipUnit,
    required this.antiCcpUnit,
    required this.rheumatoidFactorId,
    required this.cReactiveProteinId,
    required this.antinuclearFactorId,
    required this.sipId,
    required this.antiCcpId,
    required this.rheumatoidFactorName,
    required this.cReactiveProteinName,
    required this.antinuclearFactorName,
    required this.sipName,
    required this.antiCcpName,
    required this.creationDate,
  });

  factory DataTestsImmunologyList.fromJson(Map<String, dynamic> json) => DataTestsImmunologyList(
    dateNew: json["date_new"],
    rheumatoidFactor: json["RheumatoidFactor"]?.toDouble(),
    cReactiveProtein: json["C_ReactiveProtein"]?.toDouble(),
    antinuclearFactor: json["AntinuclearFactor"]?.toDouble(),
    sip: json["sip"],
    antiCcp: json["AntiCCP"]?.toDouble(),
    rheumatoidFactornorma: json["RheumatoidFactornorma"],
    cReactiveProteinnorma: json["C_ReactiveProteinnorma"],
    antinuclearFactornorma: json["AntinuclearFactornorma"],
    sipnormanorma: json["sipnormanorma"],
    antiCcPnorma: json["AntiCCPnorma"],
    rheumatoidFactorUnit: json["RheumatoidFactorUnit"],
    cReactiveProteinUnit: json["C_ReactiveProteinUnit"],
    antinuclearFactorUnit: json["AntinuclearFactorUnit"],
    sipUnit: json["sipUnit"],
    antiCcpUnit: json["AntiCCPUnit"],
    rheumatoidFactorId: json["RheumatoidFactorId"],
    cReactiveProteinId: json["C_ReactiveProteinId"],
    antinuclearFactorId: json["AntinuclearFactorId"],
    sipId: json["sipId"],
    antiCcpId: json["AntiCCPId"],
    rheumatoidFactorName: json["RheumatoidFactorName"],
    cReactiveProteinName: json["C_ReactiveProteinName"],
    antinuclearFactorName: json["AntinuclearFactorName"],
    sipName: json["sipName"],
    antiCcpName: json["AntiCCPName"],
    creationDate: json["creation_date"],
  );

  Map<String, dynamic> toJson() => {
    "date_new": dateNew,
    "RheumatoidFactor": rheumatoidFactor,
    "C_ReactiveProtein": cReactiveProtein,
    "AntinuclearFactor": antinuclearFactor,
    "sip": sip,
    "AntiCCP": antiCcp,
    "RheumatoidFactornorma": rheumatoidFactornorma,
    "C_ReactiveProteinnorma": cReactiveProteinnorma,
    "AntinuclearFactornorma": antinuclearFactornorma,
    "sipnormanorma": sipnormanorma,
    "AntiCCPnorma": antiCcPnorma,
    "RheumatoidFactorUnit": rheumatoidFactorUnit,
    "C_ReactiveProteinUnit": cReactiveProteinUnit,
    "AntinuclearFactorUnit": antinuclearFactorUnit,
    "sipUnit": sipUnit,
    "AntiCCPUnit": antiCcpUnit,
    "RheumatoidFactorId": rheumatoidFactorId,
    "C_ReactiveProteinId": cReactiveProteinId,
    "AntinuclearFactorId": antinuclearFactorId,
    "sipId": sipId,
    "AntiCCPId": antiCcpId,
    "RheumatoidFactorName": rheumatoidFactorName,
    "C_ReactiveProteinName": cReactiveProteinName,
    "AntinuclearFactorName": antinuclearFactorName,
    "sipName": sipName,
    "AntiCCPName": antiCcpName,
    "creation_date": creationDate,
  };
}

