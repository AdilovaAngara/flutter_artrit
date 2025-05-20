import 'dart:convert';

import 'package:artrit/data/data_parent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiParent {
  Future<DataParent> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/parent');
    DataParent thisData = dataParentFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<void> put({
    required String patientsId,
    required DataParent thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId/parent',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String patientsId,
  }) async {
    var response = await baseClient
        .delete('/api/patients/$patientsId/parent');
    return response;
  }
}
