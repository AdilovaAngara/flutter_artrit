import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../data/data_researches_tuberculin.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiResearchesTuberculin{
  Future<List<DataResearchesTuberculin>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/tuberculinTests/byPatientId/$patientsId');
    List<DataResearchesTuberculin>? thisData = dataResearchesTuberculinFromJson(response.body);

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
    required DataResearchesTuberculin thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/tuberculinTests/add', thisData.toJson());
    return response;
  }

  Future<void> put({
    required String recordId,
    required DataResearchesTuberculin thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/tuberculinTests/update/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/tuberculinTests/delete/$recordId');
    return response;
  }

}
