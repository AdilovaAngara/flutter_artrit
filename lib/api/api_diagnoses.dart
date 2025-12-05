import 'dart:convert';
import 'package:artrit/data/data_diagnoses.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';



var baseClient = BaseClient();

class ApiDiagnoses {

  Future<List<DataDiagnoses>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/diagnoses');
    List<DataDiagnoses> thisData = dataDiagnosesFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }



  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataDiagnoses thisData,
  }) async {
    var response = await baseClient.put(
        '/api/patients/$patientsId/diagnoses/$recordId',
        thisData.toJson());
    debugPrint(jsonEncode(thisData.toJson()));
    return response;
  }


}