import 'dart:convert';

import 'package:artrit/data/data_questionnaire.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';


var baseClient = BaseClient();

class ApiQuestionnaire {
  Future<List<DataQuestionnaire>> get({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('//patients/$patientsId/questionnaire');
    List<DataQuestionnaire>? thisData = dataQuestionnaireFromJson(response.body);
    thisData.sort((b, a) => a.creationDate!.compareTo(b.creationDate!));
    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<DataQuestionnaire> post({
    required String patientsId,
    required DataQuestionnaire thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/patients/$patientsId/questionnaire', thisData.toJson());
    DataQuestionnaire? result = dataQuestionnaireRecFromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }

  Future<DataQuestionnaire> postAnonymous({
    required DataQuestionnaire thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/patients/anonymous/questionnaire', thisData.toJson());
    DataQuestionnaire? result = dataQuestionnaireRecFromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }

  Future<DataQuestionnaire> put({
    required String patientsId,
    required String recordId,
    required DataQuestionnaire thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/patients/$patientsId/questionnaire/$recordId',
        thisData.toJson());
    DataQuestionnaire? result = dataQuestionnaireRecFromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }

  Future<void> delete({
    required String patientsId,
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/patients/$patientsId/questionnaire/$recordId');
    return response;
  }




}