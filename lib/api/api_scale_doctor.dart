import 'dart:convert';
import 'package:artrit/data/data_scale_doctor.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiScaleDoctor {
  Future<List<DataScaleDoctor>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/patients/$patientsId/doctorsscales');
    List<DataScaleDoctor>? thisData = dataScaleDoctorFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.creationDate == null && b.creationDate == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.creationDate == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.creationDate == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.creationDate!.compareTo(b.creationDate!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }



  Future<void> post({
    required String patientsId,
    required DataScaleDoctor thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/patients/$patientsId/doctorsscales', thisData.toJson());
    return response;
  }




  Future<void> put({
    required String patientsId,
    required String recordId,
    required DataScaleDoctor thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/patients/$patientsId/doctorsscales/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/patients/$patientsId/doctorsscales/$recordId');
    return response;
  }

}
