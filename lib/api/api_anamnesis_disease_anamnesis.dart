import 'dart:convert';
import 'package:artrit/data/data_anamnesis_disease_anamnesis.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';


var baseClient = BaseClient();

class ApiAnamnesisDiseaseAnamnesis {

  Future<DataAnamnesisDiseaseAnamnesis?> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/patients/$patientsId/anamnesis');
    DataAnamnesisDiseaseAnamnesis? thisData = dataAnamnesisDiseaseAnamnesisFromJson(response.body);
    debugPrint(jsonEncode(thisData));
    return thisData;
  }



  Future<void> put({
    required String patientsId,
    required DataAnamnesisDiseaseAnamnesis thisData,
  }) async {
    var response = await baseClient.put(
        '/api/patients/$patientsId/anamnesis',
        thisData.toJson());
    debugPrint(jsonEncode(thisData.toJson()));
    return response;
  }



}
