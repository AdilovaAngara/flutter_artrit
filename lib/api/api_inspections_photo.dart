import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';
import '../data/data_inspections_photo.dart';

var baseClient = BaseClient();

class ApiInspectionsPhoto {

  Future<List<DataInspectionsPhoto>> get({
    required String patientsId,
    required String bodyType,
    required String inspectionsId,

  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/pictures?type=$bodyType');
    List<DataInspectionsPhoto>? thisData = dataInspectionsPhotoFromJson(response.body);
    thisData = thisData
        .where((e) => e.inspectionId == inspectionsId)
        .toList();

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




  Future<List<DataInspectionsPhoto>> getAll({
    required String patientsId,
    required String bodyType,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/pictures?type=$bodyType');
    List<DataInspectionsPhoto>? thisData = dataInspectionsPhotoFromJson(response.body);
    thisData = thisData
        .toList();

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
    required String patientsId,
    required DataInspectionsPhoto thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/pictures', thisData.toJson());
    return response;
  }

  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataInspectionsPhoto thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/pictures/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/pictures/$recordId');
    return response;
  }

}