import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';
import '../data/data_inspections.dart';

var baseClient = BaseClient();

class ApiInspections {
  Future<List<DataInspections>> get({
    required String patientsId,
  }) async {
    var response =
        await baseClient.get('/api/patients/$patientsId/inspections');
    List<DataInspections>? thisData = dataInspectionsFromJson(response.body);

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

  Future<String> post({
    required String patientsId,
    required DataInspections thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/inspections', thisData.toJson());
    DataInspections? data = dataInspectionsRecFromJson(response.body);
    return data.id ?? '';
  }

  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataInspections thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/inspections/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/inspections/$recordId');
    return response;
  }

}
