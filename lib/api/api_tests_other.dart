import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../data/data_tests_other.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiTestsOther {

  Future<List<DataTestsOther>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/other_blood_tests');
    List<DataTestsOther>? thisData = dataTestsOtherFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.date == null && b.date == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.date == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.date == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.date!.compareTo(b.date!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }



  Future<void> post({
    required String patientsId,
    required DataTestsOther thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/other_blood_tests', thisData.toJson());
    return response;
  }


  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataTestsOther thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/other_blood_tests/$recordId', thisData.toJson());
    return response;
  }


  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/other_blood_tests/$recordId');
    return response;
  }

}
