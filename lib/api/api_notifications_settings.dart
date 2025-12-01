import 'dart:convert';
import 'package:artrit/data/data_notifications_settings.dart';
import 'package:flutter/cupertino.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiNotificationsSettings {
  Future<List<DataNotificationsSettings>> getAll() async {
    var response =
    await baseClient.get('/api/notificationSettings');
    List<DataNotificationsSettings>? thisData = dataNotificationsSettingsFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.beginDate == null && b.beginDate == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.beginDate == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.beginDate == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.beginDate!.compareTo(b.beginDate!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<List<DataNotificationsSettings>> getForPatient({
    required String patientsId,
  }) async {
    var response =
    await baseClient.get('/api/notificationSettings/patient/$patientsId');
    List<DataNotificationsSettings>? thisData = dataNotificationsSettingsFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.beginDate == null && b.beginDate == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.beginDate == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.beginDate == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.beginDate!.compareTo(b.beginDate!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }

  Future<void> post({
    required DataNotificationsSettings thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.post(
        '/api/notificationSettings/', thisData.toJson());
    return response;
  }

  Future<void> put({
    required String recordId,
    required DataNotificationsSettings thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/notificationSettings/$recordId',
        thisData.toJson());
    return response;
  }

  Future<void> delete({
    required String recordId,
  }) async {
    var response = await baseClient
        .delete('/api/notificationSettings/$recordId');
    return response;
  }

}
