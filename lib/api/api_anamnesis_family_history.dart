import 'dart:convert';
import 'package:artrit/data/data_anamnesis_family_history.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';


var baseClient = BaseClient();

class ApiAnamnesisFamilyHistory {

  Future<DataAnamnesisFamilyHistory> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/famhistory');
    DataAnamnesisFamilyHistory thisData = dataAnamnesisFamilyHistoryFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  // Future<void> post({
  //   required DataAnamnesis thisData,
  // }) async {
  //   debugPrint(jsonEncode(thisData.toJson()));
  //   var response = await baseClient.post(
  //       '/api/patients', thisData.toJson());
  //   return response;
  // }

  Future<void> put({
    required String patientsId,
    required DataAnamnesisFamilyHistory thisData,
  }) async {
    var response = await baseClient.put(
        '/api/patients/$patientsId/famhistory',
        thisData.toJson());
    debugPrint(jsonEncode(thisData.toJson()));
    return response;
  }

  // Future<void> delete({
  //   required String patientsId,
  // }) async {
  //   var response = await baseClient
  //       .delete('/api/patients/$patientsId');
  //   return response;
  // }


}
