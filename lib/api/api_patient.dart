import 'dart:convert';
import 'package:artrit/data/data_patient_register.dart';
import 'package:flutter/cupertino.dart';
import '../data/data_result.dart';
import 'base_client.dart';
import '../data/data_patient.dart';


var baseClient = BaseClient();

class ApiPatient {

  Future<DataPatient> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId');
    DataPatient thisData = dataPatientFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<void> post({
    required DataPatient thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/patients', thisData.toJson());
    return response;
  }

  Future<DataResult1> postRegister({
    required DataPatientRegister thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/user/register', thisData.toJson());
    DataResult1? result = dataResult1FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }



  Future<void> put({
    required String patientsId,
    required DataPatient thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/patients/$patientsId',
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

  Future<DataResult4> deleteUser({
    required String userId,
  }) async {
    var response = await baseClient
        .put('/api/users/$userId/delete', {});
    DataResult4 result = dataResult4FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }



}
