import 'dart:convert';
import 'package:artrit/data/data_researches_other.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'base_client.dart';

var baseClient = BaseClient();

class ApiResearchesOther{
  Future<List<DataResearchesOther>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/otherResearches');
    List<DataResearchesOther>? thisData = dataResearchesOtherFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.executeDate == null && b.executeDate == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.executeDate == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.executeDate == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.executeDate!.compareTo(b.executeDate!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }




// Метод для отправки файла и полей
  Future<http.StreamedResponse?> postWithFile({
    required String requestType,
    required String patientsId,
    required String filePath,
    required String fileName,
    required String name,
    required String executeDate,
    required String comment,
  }) async {
    final fields = {
      'name': name,
      'executeDate': executeDate,
      'comment': comment,
    };

    var response = await baseClient.saveWithFile(
      requestType: requestType,
      api: '/api/patients/$patientsId/otherResearches',
      filePath: filePath,
      fileFieldName: 'files',
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
    required DataResearchesOther thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/otherResearches', thisData.toJson());
    return response;
  }



  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataResearchesOther thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/otherResearches/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/otherResearches/$recordId');
    return response;
  }

}
