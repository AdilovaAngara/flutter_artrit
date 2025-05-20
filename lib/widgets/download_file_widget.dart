import 'package:flutter/material.dart';
import '../api/base_client.dart';
import 'banners.dart';
import 'file_utils.dart';

Future<String?> downloadFile({
  required String fileId,
  required String fileName,
  required BuildContext context,
  required bool isChatFiles,
  String? chatId,
}) async {
  final baseClient = BaseClient();

  try {
    final url = isChatFiles
        ? '${baseClient.baseUrl}/api/chat/$chatId/image?filename=$fileId'
        : '${baseClient.baseUrl}/files/$fileId/download';

    final fileData = await baseClient.getFile(url);
    if (fileData == null) {
      throw Exception('Не удалось загрузить файл');
    }
    debugPrint('Файл загружен с сервера: $fileId, размер: ${fileData.length} байт');

    return await FileUtils.saveFile(
      fileData: fileData,
      fileName: fileName,
      context: context,
    );
  } catch (e) {
    debugPrint('Ошибка при скачивании: $e');
    showBottomBanner(context: context, message: 'Ошибка при скачивании: $e');
    return null;
  }
}