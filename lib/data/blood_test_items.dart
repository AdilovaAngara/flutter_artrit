import 'data_tests_options.dart';

class BloodTestItems {
  double? analysisPatientValue;
  bool norma;
  String analysisPatientId;
  int analysisPatientDate;
  String? analysisPatientUnitId;
  String analysisId;
  String? analysisName;
  String analysisKeyName;
  int? creationDate;
  DataTestsOptions? minmax;

  BloodTestItems({
    required this.analysisPatientValue,
    required this.norma,
    required this.analysisPatientId,
    required this.analysisPatientDate,
    required this.analysisPatientUnitId,
    required this.analysisId,
    required this.analysisName,
    required this.analysisKeyName,
    required this.creationDate,
    this.minmax,
  });

  factory BloodTestItems.fromJson(Map<String, dynamic> json) => BloodTestItems(
    analysisPatientValue: json["AnalysisPatientValue"]?.toDouble(),
    norma: json["norma"],
    analysisPatientId: json["AnalysisPatientId"],
    analysisPatientDate: json["AnalysisPatientDate"].toInt(),
    analysisPatientUnitId: json["AnalysisPatientUnitId"],
    analysisId: json["AnalysisId"],
    analysisName: json["AnalysisName"],
    analysisKeyName: json["AnalysisKeyName"],
    creationDate: json["creation_date"],
    minmax: json["minmax"] == null ? null : DataTestsOptions.fromJson(json["minmax"]),
  );

  Map<String, dynamic> toJson() => {
    "AnalysisPatientValue": analysisPatientValue,
    "norma": norma,
    "AnalysisPatientId": analysisPatientId,
    "AnalysisPatientDate": analysisPatientDate,
    "AnalysisPatientUnitId": analysisPatientUnitId,
    "AnalysisId": analysisId,
    "AnalysisName": analysisName,
    "AnalysisKeyName": analysisKeyName,
    "creation_date": creationDate,
    "minmax": minmax?.toJson(),
  };
}
