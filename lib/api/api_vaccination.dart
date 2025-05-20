import 'dart:convert';
import 'package:artrit/data/data_vaccination.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'base_client.dart';

var baseClient = BaseClient();

class ApiVaccination{
  Future<List<DataVaccination>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/vaccinations');
    List<DataVaccination>? thisData = dataVaccinationFromJson(response.body);

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


  // метод для отправки файла и полей
  Future<http.StreamedResponse?> postWithFile({
    required String requestType,
    required String patientsId,
    required String filePath,
    required String fileName,
    required String vaccinationId,
    required String executeDate,
    required String comment,

  }) async {
    final fields = {
      'vaccinationid': vaccinationId,
      'executeDate': executeDate,
      'comment': comment,
    };
    var response = await baseClient.saveWithFile(
      requestType: requestType,
      api: '/api/patients/$patientsId/vaccinations',
      filePath: filePath,
      fileFieldName: 'file',
      fileName: fileName,
      fields: fields,
    );

    if (response != null) {
      final responseBody = await response.stream.bytesToString();
      debugPrint("Ответ сервера: $responseBody");
    }

    return response;
  }



  Future<void> post({
    required String patientsId,
    required DataVaccination thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/vaccinations', thisData.toJson());
    return response;
  }

  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataVaccination thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/vaccinations/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/vaccinations/$recordId');
    return response;
  }

}

