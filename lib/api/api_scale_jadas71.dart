import 'dart:convert';
import 'package:artrit/data/data_scale_jadas71.dart';
import 'package:flutter/cupertino.dart';
import '../data/data_scale_result.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiScaleJadas71 {
  Future<List<DataScaleJadas71>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/jadas71scales');
    List<DataScaleJadas71>? thisData = dataScaleJadas71FromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.createdOn == null && b.createdOn == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.createdOn == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.createdOn == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.createdOn!.compareTo(b.createdOn!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<DataScaleResult> post({
    required String patientsId,
    required DataScaleJadas71 thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/jadas71scales', thisData.toJson());
    DataScaleResult? thisDataRecord = dataScaleResultFromJson(response.body);
    debugPrint(jsonEncode(thisDataRecord));
    return thisDataRecord;
  }


  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/jadas71scales/$recordId');
    return response;
  }

}
