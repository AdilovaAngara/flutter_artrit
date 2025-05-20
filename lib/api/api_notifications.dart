import 'dart:convert';
import 'package:artrit/data/data_notifications_for_doctor.dart';
import 'package:flutter/cupertino.dart';
import '../data/data_notifications.dart';
import 'base_client.dart';

var baseClient = BaseClient();

class ApiNotifications {
  Future<List<DataNotificationsForPatient>> getForPatient() async {
    var response =
    await baseClient.get('/api/notifications');
    List<DataNotificationsForPatient>? thisData = dataNotificationsFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.createdOn == null && b.createdOn == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.createdOn == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.createdOn == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.createdOn!.compareTo(b.createdOn!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  Future<List<DataNotificationsForDoctor>> getForDoctor() async {
    var response =
    await baseClient.get('/api/notifications');
    List<DataNotificationsForDoctor>? thisData = dataNotificationsForDoctorFromJson(response.body);

    // Сортировка с учетом возможного null значения
    thisData.sort((b, a) {
      if (a.created == null && b.created == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.created == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.created == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.created!.compareTo(b.created!);
    });

    debugPrint(jsonEncode(thisData));
    return thisData;
  }


  // Пометить как прочитанное
  Future<void> setAsRead({
    required String recordId,
  }) async {
    var response = await baseClient.put('/api/notifications/setAsRead/$recordId',
        {});
    return response;
  }



}
