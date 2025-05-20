import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../data/data_result.dart';
import '../data/data_settings_notification.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiSettings{
  Future<DataResult3> putNotification({
    required DataSettingsNotification thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put('/api/patients/settings',
        thisData.toJson());
    DataResult3? thisDataRecord = dataResult3FromJson(response.body);
    debugPrint(jsonEncode(thisDataRecord));
    return thisDataRecord;
  }
}