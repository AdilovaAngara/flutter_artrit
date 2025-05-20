import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';


enum SecureKey {
  cookie,
  login,
  password,
  role,
  ssId,
  userId,
  doctorsId,
  patientsId,
  fullAge,
  doubleAge,
}


extension SecureStorageKeyExtension on SecureKey {
  String get key {
    switch (this) {
      case SecureKey.cookie:
        return 'set-cookie';
      case SecureKey.login:
        return 'login';
      case SecureKey.password:
        return 'password';
      case SecureKey.role:
        return 'role';
      case SecureKey.ssId:
        return 'ssId';
      case SecureKey.userId:
        return 'userId';
      case SecureKey.doctorsId:
        return 'doctorsId';
      case SecureKey.patientsId:
        return 'patientsId';
      case SecureKey.fullAge:
        return 'fullAge';
      case SecureKey.doubleAge:
        return 'doubleAge';
    }
  }
}


final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// Сохранение данных
Future<void> saveSecureData(SecureKey key, String value) async {
  await secureStorage.write(key: key.key, value: value);
}

// Чтение данных
Future<String> readSecureData(SecureKey key) async {
  var value = await secureStorage.read(key: key.key);
  if (value == null) {
    String ex = 'Ошибка: ${key.key} не найден';
    debugPrint(ex);
    return '';
  }
  return value;
}

// Вызывать при выходе из приложения или его закрытии?
Future<void> deleteSecureData(SecureKey key) async {
  await secureStorage.delete(key: key.key);
}

Future<Map<String, String>> readAllSecureData() async {
  return await secureStorage.readAll();
}

// Вызывать при выходе из приложения или его закрытии?
Future<void> deleteAllSecureData() async {
  await secureStorage.deleteAll();
}








