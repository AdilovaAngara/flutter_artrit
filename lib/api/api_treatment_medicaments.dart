import 'dart:convert';
import 'package:artrit/data/data_treatment_medicaments.dart';
import 'package:flutter/cupertino.dart';
import '../data/data_result.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiTreatmentMedicaments{
  Future<List<DataTreatmentMedicaments>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/treatments');
    List<DataTreatmentMedicaments>? thisData = dataTreatmentMedicamentsFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.dnp == null && b.dnp == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.dnp == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.dnp == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.dnp!.compareTo(b.dnp!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<DataResult3> post({
    required String patientsId,
    required DataTreatmentMedicaments thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/treatments', thisData.toJson());
    DataResult3? result = dataResult3FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }

  Future<DataResult3> put({
    required String patientsId,
    required String recordId,
    required DataTreatmentMedicaments thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/treatments/$recordId',
        thisData.toJson());
    DataResult3? result = dataResult3FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/treatments/$recordId');
    return response;
  }

}
