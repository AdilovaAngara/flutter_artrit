import 'dart:convert';
import 'package:artrit/data/data_login.dart';
import 'package:flutter/material.dart';
import '../data/data_login_recovery.dart';
import '../data/data_result.dart';
import 'base_client.dart';
import '../secure_storage.dart';

var baseClient = BaseClient();

class ApiLogin {
  Future<DataLogin?> post({
    required DataLogin thisData,
  }) async {
    try {
      deleteAllSecureData();
      DataLogin? userLoginData;
      var response = await baseClient.post('/api/auth/login', thisData.toJson());

      if (response != null && response.headers != null) {
        var headers = response.headers;
        String? cookie = headers['set-cookie'];
        if (cookie != null) {
          await saveSecureData(SecureKey.cookie, cookie);
          userLoginData = dataLoginFromJson(response.body);
          debugPrint(jsonEncode(userLoginData));

          String? ssId = userLoginData.ssid;
          await saveSecureData(SecureKey.ssId, '$ssId');

          String? userId = userLoginData.id;
          await saveSecureData(SecureKey.userId, '$userId');

          int? role = userLoginData.role;
          if (role != null) {
            await saveSecureData(SecureKey.role, '$role');

            if (role == 1) {
              String? patientsId = userLoginData.patientsId;
              if (patientsId != null) {
                await saveSecureData(SecureKey.patientsId, patientsId);
              }
            }
            else if (role == 2) {
              String? doctorsId = userLoginData.id;
              if (doctorsId != null) {
                await saveSecureData(SecureKey.doctorsId, doctorsId);
              }
            }
          }
        }
      }
      return userLoginData;
    } catch (e) {
      debugPrint('Ошибка при выполнении запроса: $e');
      return null;
    }
  }





  Future<DataResult2> putEmail({
    required DataLoginRecovery thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/user/send-pswd-token',
        thisData.toJson());
    DataResult2? result = dataResult2FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }


  Future<DataResult2> putCode({
    required DataLoginCode thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/user/check-sms-token',
        thisData.toJson());
    DataResult2? result = dataResult2FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }



  Future<DataResult2> putNewPassword({
    required DataLoginNewPassword thisData,
  }) async {
    debugPrint(jsonEncode(thisData.toJson()));
    var response = await baseClient.put(
        '/api/user/reset-pswd',
        thisData.toJson());
    DataResult2? result = dataResult2FromJson(response.body);
    debugPrint(jsonEncode(result));
    return result;
  }






}
