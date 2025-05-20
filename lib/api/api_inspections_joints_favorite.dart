import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../data/data_inspections_joints_favorite.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiInspectionsJointsFavorite {
  Future<List<DataInspectionsJointsFavorite>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/joints_favorite');
    List<DataInspectionsJointsFavorite>? thisData = dataInspectionsJointsFavoriteFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<void> post({
    required String patientsId,
    required String recordId,
    required DataInspectionsJointsFavorite thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients/$patientsId/joints_favorite?joint_id=$recordId', thisData.toJson());
    return response;
  }


  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/joints_favorite?joint_id=$recordId');
    return response;
  }
}
