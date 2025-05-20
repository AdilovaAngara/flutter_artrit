import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../data/data_tests_biochemical.dart';
import '../data/data_tests_biochemical_list.dart';
import 'base_client.dart';



var baseClient = BaseClient();

class ApiTestsBiochemical {

  Future<List<DataTestsBiochemicalList>> getList({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/analysispatient/GetBiochemicalBloodTestData?patientId=$patientsId');
    List<DataTestsBiochemicalList>? thisData = dataTestsBiochemicalListFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.dateNew == null && b.dateNew == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.dateNew == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.dateNew == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.dateNew!.compareTo(b.dateNew!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<DataTestsBiochemical> getForNew({
    required String patientsId,
  }) async {
    var response = await baseClient.get(
        '/api/analysispatient/GetBiochemicalBloodTestByDateNew/$patientsId/0');
    DataTestsBiochemical thisData = dataTestsBiochemicalFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<DataTestsBiochemical> getForEdit({
    required String patientsId,
    required int recordId,
  }) async {
    var response = await baseClient.get(
        '/api/analysispatient/GetBiochemicalBloodTestByDate/$patientsId/$recordId');
    DataTestsBiochemical thisData = dataTestsBiochemicalFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<void> post({
    required String patientsId,
    required DataTestsBiochemical thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/analysispatient/SaveBiochemicalBloodTest', thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required int? recordId,
  }) async {
    var response = await baseClient
        .delete('/api/analysispatient/DeleteBiochemicalBloodTest/$patientsId/$recordId');
    return response;
  }

}


