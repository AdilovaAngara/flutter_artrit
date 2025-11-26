import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:artrit/secure_storage.dart';
import "package:path/path.dart" as path;

class BaseClient {
  bool isTest = false;
  //bool isTest = true;

  String get baseUrl {
    /// Релиз
    if (!isTest) return 'https://api.aspirre-russia.ru/ja';
    /// Тест
    return 'https://artritdevapi.nitrosbase.com';
  }

  var client = http.Client();

  Future<Map<String, String>> _getHeaders() async {
    String? cookie = await readSecureData(SecureKey.cookie);

    return {
      'Content-type': 'application/json',
      if (cookie.isNotEmpty) 'Cookie': cookie,
    };
  }



  Future<dynamic> get(String api) async {
    try {
      var url = Uri.parse(baseUrl + api);
      var headers = await _getHeaders();

      var response = await client.get(url, headers: headers);
      debugPrint("GET $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response;
      } else {
        debugPrint(
            "Ошибка GET запроса: статус ${response.statusCode}, тело ответа: ${response.body}");
        return response;
      }
    } catch (e) {
      debugPrint('Ошибка выполнения GET запроса: $e');
      return null;
    }
  }

  Future<dynamic> post(String api, dynamic object) async {
    try {
      var url = Uri.parse(baseUrl + api);
      var headers = await _getHeaders();
      var payload = json.encode(object);

      var response = await client.post(url, body: payload, headers: headers);
      debugPrint("POST $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response;
      } else {
        debugPrint(
            "Ошибка POST запроса: статус ${response.statusCode}, тело ответа: ${response.body}");
        return response;
      }
    } catch (e) {
      debugPrint('Ошибка выполнения POST запроса: $e');
      return null;
    }
  }

  Future<dynamic> put(String api, dynamic object) async {
    try {
      var url = Uri.parse(baseUrl + api);
      var headers = await _getHeaders();
      var payload = json.encode(object);

      var response = await client.put(url, body: payload, headers: headers);
      debugPrint("PUT $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response;
      } else {
        debugPrint(
            "Ошибка PUT запроса: статус ${response.statusCode}, тело ответа: ${response.body}");
        return response;
      }
    } catch (e) {
      debugPrint('Ошибка выполнения PUT запроса: $e');
      return null;
    }
  }


  Future<dynamic> delete(String api, {dynamic object}) async {
    try {
      var url = Uri.parse(baseUrl + api);
      var headers = await _getHeaders();
      var payload = object != null ? json.encode(object) : null;

      var response = await client.delete(url, body: payload, headers: headers);
      debugPrint("DELETE $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response;
      } else {
        debugPrint(
            "Ошибка DELETE запроса: статус ${response.statusCode}, тело ответа: ${response.body}");
        return response;
      }
    } catch (e) {
      debugPrint('Ошибка выполнения DELETE запроса: $e');
      return null;
    }
  }






  Future<http.StreamedResponse?> sendFile(String filePath) async {
    try {
      String api = '/files/send';
      var url = Uri.parse(baseUrl + api);
      var request = http.MultipartRequest('POST', url);
      var headers = await _getHeaders();

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.headers.addAll(headers);

      var response = await request.send();
      debugPrint("UPLOAD $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response;
      } else {
        debugPrint(
            "Ошибка UPLOAD запроса: статус ${response.statusCode}, тело ответа: ${response.stream}");
        return response;
      }
    } catch (e) {
      debugPrint('Ошибка загрузки файла: $e');
      return null;
    }
  }

  Future<Uint8List?> getFile(String url) async {
    try {
      var headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint("DOWNLOAD $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response.bodyBytes;
      } else {
        debugPrint("Ошибка загрузки файла: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Ошибка выполнения getFile: $e");
      return null;
    }
  }



  Future<Uint8List?> getTextFile(String url) async {
    try {
      var headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint("DOWNLOAD $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response.bodyBytes; // Возвращаем сырые байты
      } else {
        debugPrint("Ошибка загрузки файла: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Ошибка выполнения getTextFile: $e");
      return null;
    }
  }


  Future<http.StreamedResponse?> saveWithFile({
    required String requestType,
    required String api,
    required String filePath,
    required String fileFieldName, // Имя поля для файла (например, "files")
    required String fileName, // Имя файла (например, "Проверка Минздрава.jpg")
    required Map<String, String>
        fields, // Текстовые поля (name, executeDate, comment)
  }) async {
    try {
      var url = Uri.parse(baseUrl + api);
      var request = http.MultipartRequest(requestType, url);
      var headers = await _getHeaders();

      // Удаляем Content-type: application/json, так как это multipart/form-data
      headers.remove('Content-type');
      request.headers.addAll(headers);

      // Добавляем файл
      request.files.add(
        await http.MultipartFile.fromPath(
          fileFieldName,
          filePath,
          filename: fileName,
        ),
      );

      // Добавляем текстовые поля
      request.fields.addAll(fields);

      var response = await request.send();
      debugPrint("MULTIPART $requestType $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response;
      } else {
        debugPrint("Ошибка MULTIPART запроса: статус ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint('Ошибка отправки multipart/form-data: $e');
      return null;
    }
  }



  Future<dynamic> postReportData({
    required String api,
    required String patientId,
    required int startDate,
    required int endDate,
    required bool isDoctor,
    required bool isPatient,
    required bool download,
  }) async {
    try {
      var url = Uri.parse(baseUrl + api).replace(queryParameters: {
        'patientId': patientId,
        'startDate': startDate.toString(),
        'endDate': endDate.toString(),
        'isDoctor': isDoctor.toString(),
        'isPatient': isPatient.toString(),
        'download': download.toString(),
      });
      var headers = await _getHeaders();

      var response = await client.post(url,
          headers: headers); // Тело пустое, так как данные в URL
      debugPrint("POST $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response;
      } else {
        debugPrint(
            "Ошибка POST запроса: статус ${response.statusCode}, тело ответа: ${response.body}");
        return response;
      }
    } catch (e) {
      debugPrint('Ошибка выполнения POST запроса: $e');
      return null;
    }
  }







  Future<dynamic> uploadFileToServer({
    required String filePath,
    required String api,
  }) async {
    try {
      var url = Uri.parse(baseUrl + api);
      var request = http.MultipartRequest('POST', url);
      var headers = await _getHeaders();

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.headers.addAll(headers);

      var file = await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: path.basename(filePath),
      );
      request.files.add(file);


      var response = await request.send();

      debugPrint("MULTIPART 'POST' $url -> ${response.statusCode}");

      if ([200, 201].contains(response.statusCode)) {
        return response;
      } else {
        debugPrint("Ошибка MULTIPART запроса: статус ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint('Ошибка отправки multipart/form-data: $e');
      return null;
    }
  }







}
