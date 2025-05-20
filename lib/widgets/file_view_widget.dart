import 'package:artrit/widgets/future_builder_document.dart';
import 'package:artrit/widgets/viewer_video_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io'; // Для работы с File
import '../file_methods.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../theme.dart';
import 'app_bar_widget.dart';
import 'button_widget.dart';
import 'download_file_widget.dart';
import 'future_builder_image.dart';
import 'future_builder_video.dart';

class FileViewWidget extends StatelessWidget {
  final String? fileName; // Имя файла (для серверных файлов)
  final String? fileId; // ID файла на сервере (для серверных файлов)
  final String? filePath; // Путь к локальному файлу (для локальных файлов)
  final bool isLocal; // Флаг: локальный файл или серверный
  final bool isChatFiles; // Флаг: файлы из чата
  final String? chatId; // ID чата (для серверных файлов)

  const FileViewWidget({
    super.key,
    this.fileName,
    this.fileId,
    this.filePath,
    required this.isLocal,
    required this.isChatFiles,
    this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    // Проверка на наличие данных
    if ((isLocal && filePath == null) ||
        (!isLocal && (fileName == null || fileId == null))) {
      return Scaffold(
        appBar: AppBarWidget(
          title: 'Просмотр файла',
          showMenu: false,
          showChat: false,
          showNotifications: false,
        ),
        body: const Center(
          child: Text('Нет данных для отображения'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Просмотр файла',
        showMenu: false,
        showChat: false,
        showNotifications: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    isLocal ? fileName ?? filePath ?? '' : fileName ?? '',
                    style: inputTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (!isLocal &&
                    fileId != null &&
                    fileId!.isNotEmpty &&
                    fileName != null &&
                    fileName!.isNotEmpty)
                  ButtonWidget(
                    labelText: '',
                    icon: Icons.download,
                    iconColor: mainColor.withAlpha(150),
                    iconSize: 27,
                    onlyText: true,
                    listRoles: Roles.all,
                    onPressed: () {
                      downloadFile(
                        fileName: fileName!,
                        fileId: fileId!,
                        context: context,
                        isChatFiles: isChatFiles,
                        chatId: chatId,
                      );
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildFileContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFileContent(BuildContext context) {
    // Определяем расширение файла в зависимости от типа
    String finalFilePath = isLocal ? filePath ?? '' : fileName ?? '';
    final extension = isLocal
        ? FileMethods.getFileExtension(filePath!)
        : FileMethods.getFileExtension(fileName!);

    if ([FileFormat.pdf.extension].contains(extension)) {
      if (isLocal) {
        /// Локальный PDF-файл
        return LocalPDFView(filePath: filePath!);
      } else {
        /// Серверный PDF-файл
        return FutureBuilderDocument(
          fileId: fileId!,
          fileExtension: extension,
          // height: double.infinity,
          // width: double.infinity,
          isChatFiles: isChatFiles,
          chatId: chatId,
        );
      }
    } else if ([FileFormat.txt.extension].contains(extension)) {
      if (isLocal) {
        /// Локальный txt-файл
        return TextFileViewer(filePath: filePath!);
      } else {
        /// Серверный txt-файл
        return FutureBuilderDocument(
          fileId: fileId!,
          fileExtension: extension,
          // height: double.infinity,
          // width: double.infinity,
          isChatFiles: isChatFiles,
          chatId: chatId,
        );
      }
    } else if (FileMethods.isImageFile(path: finalFilePath)) {
      if (isLocal) {
        /// Локальное изображение
        return Image.file(
          File(filePath!),
          fit: BoxFit.contain,
        );
      } else {
        /// Серверное изображение
        return FutureBuilderImage(
          imageId: fileId!,
          isFullSize: true,
          isChatFiles: isChatFiles,
          chatId: chatId,
        );
      }
    } else if (FileMethods.isVideoFile(path: finalFilePath)) {
      if (isLocal) {
        /// Локальное видео
        return ViewerVideoFile(
          filePath: filePath!,
          isLocal: true,
        );
      } else {
        /// Серверное видео
        return FutureBuilderVideo(
          videoId: fileId!,
          isChatFiles: isChatFiles,
          chatId: chatId,
        );
      }
    } else {
      String message = 'Просмотр файла формата $extension не поддерживается';
      if (!isLocal) {
        message += ' Скачайте его, чтобы посмотреть содержимое';
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
  }

  static Future<void> show(
    BuildContext context, {
    String? fileName,
    String? fileId,
    String? filePath,
    required bool isLocal,
    required bool isChatFiles,
    String? chatId,
  }) async {
    if ((isLocal && filePath != null) ||
        (!isLocal && fileName != null && fileId != null)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileViewWidget(
            fileName: fileName,
            fileId: fileId,
            filePath: filePath,
            isLocal: isLocal,
            isChatFiles: isChatFiles,
            chatId: chatId,
          ),
        ),
      );
    }
  }
}

// Вспомогательный виджет для отображения локальных PDF
class LocalPDFView extends StatelessWidget {
  final String filePath;

  const LocalPDFView({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: filePath,
    );
  }
}

// Вспомогательный виджет для отображения txt файлов
class TextFileViewer extends StatelessWidget {
  final String filePath;

  const TextFileViewer({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: File(filePath).readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return errorDataWidget(snapshot.error);
        } else {
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  snapshot.data ?? 'Файл пуст',
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
