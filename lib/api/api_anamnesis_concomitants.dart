import 'dart:convert';
import 'package:artrit/data/data_anamnesis_concomitants.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiAnamnesisConcomitants {
  Future<List<DataAnamnesisConcomitants>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/concomitants');
    List<DataAnamnesisConcomitants>? thisData = dataAnamnesisConcomitantsFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.dateStart == null && b.dateStart == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.dateStart == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.dateStart == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.dateStart!.compareTo(b.dateStart!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<void> post({
    required String patientsId,
    required DataAnamnesisConcomitants thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/concomitants', thisData.toJson());
    return response;
  }

  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataAnamnesisConcomitants thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/concomitants/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/concomitants/$recordId');
    return response;
  }

}
