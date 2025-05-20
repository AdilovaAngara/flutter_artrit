import 'package:flutter/cupertino.dart';
import 'base_client.dart';
import '../data/data_send_file.dart';

var baseClient = BaseClient();

class ApiSendFile {
  Future<DataSendFile> sendFile({required String path}) async {
    var response = await baseClient.sendFile(path);

    if (response != null && response.statusCode == 200) {
      // Читаем тело ответа в строку
      String responseBody = await response.stream.bytesToString();
      debugPrint(responseBody);

      // Преобразуем JSON-строку в объект SendFileData
      DataSendFile sendFileData = dataSendFileFromJson(responseBody);
      return sendFileData;
    } else {
      throw Exception('Ошибка при отправке файла: ${response?.statusCode}');
    }
  }
}

