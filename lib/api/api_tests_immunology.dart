import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../data/data_tests_immunology.dart';
import '../data/data_tests_immunology_list.dart';
import 'base_client.dart';



var baseClient = BaseClient();

class ApiTestsImmunology {

  Future<List<DataTestsImmunologyList>> getList({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/analysispatient/GetImmunology?patientId=$patientsId');
    List<DataTestsImmunologyList>? thisData = dataTestsImmunologyListFromJson(response.body);

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


  Future<DataTestsImmunology> getForNew({
    required String patientsId,
  }) async {
    var response = await baseClient.get(
        '/api/analysispatient/GetImmunologyByDateNew/$patientsId/0');
    DataTestsImmunology thisData = dataTestsImmunologyFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<DataTestsImmunology> getForEdit({
    required String patientsId,
    required int recordId,
  }) async {
    var response = await baseClient.get(
        '/api/analysispatient/GetImmunologyByDate/$patientsId/$recordId');
    DataTestsImmunology thisData = dataTestsImmunologyFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<void> post({
    required String patientsId,
    required DataTestsImmunology thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/analysispatient/SaveImmunology', thisData.toJson());
    return response;
  }


  Future<void> delete({
    required String patientsId,
    required int? recordId,
  }) async {
    var response = await baseClient
        .delete('/api/analysispatient/Deleteimmunology/$patientsId/$recordId');
    return response;
  }

}
