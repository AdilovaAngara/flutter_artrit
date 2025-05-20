import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../data/data_tuberculosis.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiTuberculosis{
  Future<List<DataTuberculosis>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/tuberculosisInfections');
    List<DataTuberculosis>? thisData = dataTuberculosisFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.treatmentBeginDate == null && b.treatmentBeginDate == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.treatmentBeginDate == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.treatmentBeginDate == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.treatmentBeginDate!.compareTo(b.treatmentBeginDate!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<void> post({
    required String patientsId,
    required DataTuberculosis thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/tuberculosisInfections', thisData.toJson());
    return response;
  }

  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataTuberculosis thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/tuberculosisInfections/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/tuberculosisInfections/$recordId');
    return response;
  }

}
