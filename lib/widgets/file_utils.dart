import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/banners.dart';

class FileUtils {
  /// Сохраняет файл во временную директорию и возвращает путь к файлу.
  static Future<String> saveTempFile(Uint8List data, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(data);
    debugPrint('Файл сохранён во временную директорию: ${tempFile.path}');
    return tempFile.path;
  }

  /// Сохраняет файл в постоянное хранилище (Downloads на Android, Documents на iOS).
  /// Возвращает путь к сохранённому файлу или null в случае ошибки.
  static Future<String?> saveFile({
    required Uint8List fileData,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      String? filePath;
      if (Platform.isAndroid) {
        final mediaStore = MediaStore();
        final tempFilePath = await saveTempFile(fileData, fileName);
        debugPrint('Сохраняем файл в Downloads...');
        final uri = await mediaStore.saveFile(
          tempFilePath: tempFilePath,
          dirType: DirType.download,
          dirName: DirName.download,
        );
        debugPrint('URI после сохранения: $uri');
        filePath = '/storage/emulated/0/Download/$fileName';
        if (uri == null) {
          debugPrint('URI пустой, файл остался во временной папке');
          filePath = tempFilePath;
        } else {
          debugPrint('Проверяем, сохранён ли файл в Downloads...');
          final downloadedFile = File(filePath);
          if (await downloadedFile.exists()) {
            debugPrint('Файл найден в Downloads: $filePath');
          } else {
            debugPrint('Файл не найден в Downloads, URI: $uri');
            filePath = tempFilePath;
          }
        }
        showBottomBanner(context: context, message: 'Файл сохранён в Downloads: $fileName');
      } if (Platform.isIOS) {
        final tempFilePath = await saveTempFile(fileData, fileName);
        await Share.shareXFiles(
          [XFile(tempFilePath, mimeType: 'application/octet-stream')],
          subject: fileName,
          text: 'Сохраните файл или поделитесь им:',
        );
        showBottomBanner(context: context, message: 'Откройте диалог сохранения файла');
      }

      // else if (Platform.isIOS) {
      //   final tempFilePath = await saveTempFile(fileData, fileName);
      //   debugPrint('Открываем диалог сохранения на iOS...');
      //   await Share.share(
      //     tempFilePath,
      //     subject: fileName,
      //   );
      //   filePath = tempFilePath;
      //   debugPrint('Файл подготовлен для сохранения на iOS: $filePath');
      //   //showBottomBanner(context: context, message: 'Выберите место для сохранения файла: $fileName');
      // }
      return filePath;
    } catch (e) {
      debugPrint('Ошибка при сохранении файла: $e');
      showBottomBanner(context: context, message: 'Ошибка при сохранении файла: $e');
      return null;
    }
  }
}