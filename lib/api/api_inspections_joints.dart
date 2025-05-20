import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'base_client.dart';
import '../data/data_inspections_joints.dart';

var baseClient = BaseClient();

class ApiInspectionsJoints {
  Future<List<DataInspectionsJoints>> get({
    required String patientsId,
    required String bodyType,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/joints?type=$bodyType');
    List<DataInspectionsJoints>? thisData = dataInspectionsJointsFromJson(response.body);
    thisData.sort((b, a) => a.numericId.compareTo(b.numericId));
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


}
