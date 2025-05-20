import 'dart:convert';
import 'package:artrit/data/data_doctor.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';


var baseClient = BaseClient();

class ApiDoctor {

  Future<DataDoctor> get({
    required String doctorsId,
  }) async {
    var response =
    await baseClient.get('/doctors/$doctorsId');
    DataDoctor thisData = dataDoctorFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<void> post({
    required DataDoctor thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/doctors', thisData.toJson());
    return response;
  }

  Future<void> put({
    required String doctorsId,
    required DataDoctor thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/doctors/$doctorsId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String doctorsId,
  }) async {
    var response = await baseClient
        .delete('/doctors/$doctorsId');
    return response;
  }

}
