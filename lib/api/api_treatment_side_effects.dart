import 'dart:convert';
import 'package:artrit/data/data_treatment_side_effects.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiTreatmentSideEffects{
  Future<List<DataTreatmentSideEffects>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/side_effects');
    List<DataTreatmentSideEffects>? thisData = dataTreatmentSideEffectsFromJson(response.body);

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
    required DataTreatmentSideEffects thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/side_effects', thisData.toJson());
    return response;
  }

  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataTreatmentSideEffects thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/side_effects/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/side_effects/$recordId');
    return response;
  }

}
