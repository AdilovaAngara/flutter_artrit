import 'dart:convert';
import 'package:artrit/data/data_patient_diagnoses.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';

enum EnumDiagnoses {
  mkbCode,
  mkbName,
  diagnosisComment
}

var baseClient = BaseClient();

class ApiPatientDiagnoses {
  Future<List<DataPatientDiagnoses>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/diagnoses');
    List<DataPatientDiagnoses> thisData = dataPatientDiagnosesFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


}