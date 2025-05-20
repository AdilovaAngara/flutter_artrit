import 'dart:convert';
import 'package:artrit/data/data_scale_das28.dart';
import 'package:flutter/cupertino.dart';
import '../data/data_scale_result.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiScaleDas28 {
  Future<List<DataScaleDas28>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/das28scales');
    List<DataScaleDas28>? thisData = dataScaleDas28FromJson(response.body);

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
    required DataScaleDas28 thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/das28scales', thisData.toJson());
    DataScaleResult? thisDataRecord = dataScaleResultFromJson(response.body);
    debugPrint(jsonEncode(thisDataRecord));
    return thisDataRecord;
  }

  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataScaleDas28 thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/das28scales/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/das28scales/$recordId');
    return response;
  }

}
