import 'dart:convert';
import 'package:artrit/data/data_tests_clinical_list.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';
import '../data/data_tests_clinical.dart';


var baseClient = BaseClient();

class ApiTestsClinical {

  Future<List<DataTestsClinicalList>> getList({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/analysispatient/getClinicalBloodCount?patientId=$patientsId');
    List<DataTestsClinicalList>? thisData = dataTestsClinicalListFromJson(response.body);

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


  Future<DataTestsClinical> getForNew({
    required String patientsId,
  }) async {
    var response = await baseClient.get(
        '/api/analysispatient/GetClinicalBloodCountByDateNew/$patientsId/0');
    DataTestsClinical thisData = dataTestsClinicalFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<DataTestsClinical> getForEdit({
    required String patientsId,
    required int recordId,
  }) async {
    var response = await baseClient.get(
        '/api/analysispatient/GetClinicalBloodCountByDate/$patientsId/$recordId');
    DataTestsClinical thisData = dataTestsClinicalFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<void> post({
    required String patientsId,
    required DataTestsClinical thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/analysispatient/SaveClinicalBloodCount', thisData.toJson());
    return response;
  }


  Future<void> delete({
    required String patientsId,
    required int? recordId,
  }) async {
    var response = await baseClient
        .delete('/api/analysispatient/DeleteClinicalBloodCount/$patientsId/$recordId');
    return response;
  }

}
