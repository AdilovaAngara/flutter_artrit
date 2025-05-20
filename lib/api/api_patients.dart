import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';
import '../data/data_patients.dart';


var baseClient = BaseClient();

class ApiPatients {

  Future<List<DataPatients>> get({
    required String doctorsId,
  }) async {
    var response =
    await baseClient.get('/doctors/$doctorsId/patients');
    List<DataPatients>? thisData = dataPatientsFromJson(response.body);
    thisData.sort((b, a) => a.lastName.compareTo(b.lastName));
    debugPrint(jsonEncode(thisData));
    return thisData;
  }


}
