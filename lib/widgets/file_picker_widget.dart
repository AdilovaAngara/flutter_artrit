import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import '../file_methods.dart';


class FileItems {
  final String fileName;
  final File file;
  bool? isSendSuccess;

  FileItems({
    required this.fileName,
    required this.file,
    this.isSendSuccess,
  });
}

class FilePickerWidget {
  final Function(List<FileItems>) onFileUploaded;
  final Function(bool)? onLoadingChanged;
  final bool isCamera;
  final bool isGalery;
  final bool isDocument;
  final bool isVideo;
  final bool onlyOneFile;

  FilePickerWidget({
    required this.onFileUploaded,
    this.onLoadingChanged,
    this.isCamera = true,
    this.isGalery = true,
    this.isDocument = true,
    this.isVideo = false,
    this.onlyOneFile = true, // По умолчанию разрешено несколько файлов
  });

  // Показать диалог выбора источника файла
  void showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(5.0)),
          if (isCamera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () {
                Navigator.pop(context);
                isVideo ? _showCameraOptions(context)
                : _pickFileFromCamera(isVideo: false);
              },
            ),
          if (isGalery)
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.pop(context);
                isVideo
                ? _showGalleryOptions(context)
                : _pickFileFromGallery(isVideo: false);
              },
            ),
          if (isDocument)
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Документ'),
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
          const Padding(padding: EdgeInsets.all(10.0)),
        ],
      ),
    );
  }


  // Показать диалог выбора типа съёмки (фото или видео)
  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(5.0)),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Фото'),
            onTap: () {
              Navigator.pop(context);
              _pickFileFromCamera(isVideo: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Видео'),
            onTap: () {
              Navigator.pop(context);
              _pickFileFromCamera(isVideo: true);
            },
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
        ],
      ),
    );
  }


  // Съёмка фото или видео с камеры (только один файл, так как камера не поддерживает множественный выбор)
  Future<void> _pickFileFromCamera({required bool isVideo}) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    if (isVideo) {
      pickedFile = await picker.pickVideo(source: ImageSource.camera);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    }

    if (pickedFile != null) {
      _setLoading(true);
      File file = File(pickedFile.path);
      if (!isVideo) {
        // Поворачиваем только фото
        file = await FlutterExifRotation.rotateImage(path: pickedFile.path);
      }
      List<FileItems> files = [
        FileItems(
          fileName: pickedFile.path.split('/').last,
          file: file,
        )
      ];
      await _uploadFiles(files);
      _setLoading(false);
    }
  }


  // Показать диалог выбора типа медиа (фото или видео) для галереи
  void _showGalleryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(5.0)),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Фото'),
            onTap: () {
              Navigator.pop(context);
              _pickFileFromGallery(isVideo: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Видео'),
            onTap: () {
              Navigator.pop(context);
              _pickFileFromGallery(isVideo: true);
            },
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
        ],
      ),
    );
  }

  // Выбор фото или видео из галереи
  Future<void> _pickFileFromGallery({required bool isVideo}) async {
    final picker = ImagePicker();
    List<FileItems> files = [];

    try {
      if (isVideo) {
        // Выбор одного видео
        final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
        if (pickedFile != null) {
          _setLoading(true);
          files.add(FileItems(
            fileName: pickedFile.path.split('/').last,
            file: File(pickedFile.path),
          ));
          await _uploadFiles(files);
        }
      } else {
        // Выбор фото
        if (onlyOneFile) {
          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            _setLoading(true);
            File rotatedFile = await FlutterExifRotation.rotateImage(path: pickedFile.path);
            files.add(FileItems(
              fileName: pickedFile.path.split('/').last,
              file: rotatedFile,
            ));
            await _uploadFiles(files);
          }
        } else {
          final pickedFiles = await picker.pickMultiImage();
          if (pickedFiles.isNotEmpty) {
            _setLoading(true);
            for (var pickedFile in pickedFiles) {
              File rotatedFile = await FlutterExifRotation.rotateImage(path: pickedFile.path);
              files.add(FileItems(
                fileName: pickedFile.path.split('/').last,
                file: rotatedFile,
              ));
            }
            await _uploadFiles(files);
          }
        }
      }
    } catch (e) {
      debugPrint('Ошибка выбора ${isVideo ? 'видео' : 'фото'} из галереи: $e');
    } finally {
      _setLoading(false);
    }
  }



  // Выбор документов
  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: FileMethods.documentAllowedExtensions,
      allowMultiple: !onlyOneFile,
    );
    if (result != null && result.files.isNotEmpty) {
      _setLoading(true);
      List<FileItems> files = [];
      for (var file in result.files.where((file) => file.path != null)) {
        File f = File(file.path!);
        if (file.extension == FileFormat.txt.extension) {
          // Читаем и перезаписываем как UTF-8
          try {
            String content = await f.readAsString(encoding: utf8);
            f = await f.writeAsString(content, encoding: utf8);
          } catch (e) {
            debugPrint("Ошибка обработки TXT в UTF-8: $e");
            // Пробуем Windows-1251 для русского текста
            try {
              // Читаем файл как сырые байты
              List<int> bytes = await f.readAsBytes();
              // Декодируем как Windows-1251
              String content = await CharsetConverter.decode("windows-1251", Uint8List.fromList(bytes));
              // Перезаписываем как UTF-8
              f = await f.writeAsString(content, encoding: utf8);
            } catch (e) {
              debugPrint("Не удалось перекодировать TXT из Windows-1251: $e");
              continue; // Пропускаем файл, если не удалось декодировать
            }
          }
        }
        files.add(FileItems(
          fileName: file.name,
          file: f,
        ));
      }
      await _uploadFiles(files);
      _setLoading(false);
    }
  }

  // Возвращаем список файлов на страницу вызова
  Future<void> _uploadFiles(List<FileItems> files) async {
    onFileUploaded(files);
  }

  // Управление состоянием загрузки
  void _setLoading(bool value) {
    if (onLoadingChanged != null) {
      onLoadingChanged!(value);
    }
  }
}