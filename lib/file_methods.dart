import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;

enum FileFormat {
  pdf,
  docx,
  doc,
  txt,
  rtf,
  xlsx,
  xls,
  jpg,
  jpeg,
  png,
  bmp,
  //svg,
  mp4,
  mov,
  avi;

  String get extension => '.${name.toLowerCase()}';
  String get rawExtension => name.toLowerCase(); // Добавляем геттер без точки
}

class FileMethods {

  // Получаем расширение файла
  static String getFileExtension(String filePath) {
    String extension = path.extension(filePath).toLowerCase();
    //debugPrint('Формат файла $extension');
    return extension;
  }





  static bool isImageFile({required String path}) {
    final extension = getFileExtension(path);
    return ([
      FileFormat.jpg.extension,
      FileFormat.jpeg.extension,
      FileFormat.png.extension,
      FileFormat.bmp.extension,
      //FileFormat.svg.extension,
    ].contains(extension));
  }

  static bool isVideoFile({required String path}) {
    final extension = getFileExtension(path);
    return ([
      FileFormat.mp4.extension,
      FileFormat.mov.extension,
      FileFormat.avi.extension,
    ].contains(extension));
  }

  static bool isDocumentFile({required String path}) {
    final extension = getFileExtension(path);
    return ([
      FileFormat.pdf.extension,
      FileFormat.docx.extension,
      FileFormat.doc.rawExtension,
      FileFormat.xlsx.extension,
      FileFormat.xls.extension,
      FileFormat.txt.extension,
      FileFormat.rtf.extension,
    ].contains(extension));
  }

  static List<String> documentAllowedExtensions = [
    FileFormat.pdf.rawExtension,
    FileFormat.docx.rawExtension,
    FileFormat.doc.rawExtension,
    FileFormat.xlsx.rawExtension,
    FileFormat.xls.rawExtension,
    FileFormat.txt.rawExtension,
    FileFormat.rtf.rawExtension,
  ];

  static bool isAvailableViewIcon(String fileName) {
    return ([
      FileFormat.jpg.extension,
      FileFormat.jpeg.extension,
      FileFormat.png.extension,
      FileFormat.bmp.extension,
      FileFormat.pdf.extension,
      FileFormat.txt.extension,
      FileFormat.rtf.extension,
    ].contains(getFileExtension(fileName.toLowerCase())));
  }



  static IconData getDocIcon(String path) {
    String extension = getFileExtension(path);
    return extension == FileFormat.pdf.extension
        ? FontAwesomeIcons.filePdf
        : [FileFormat.docx.extension, FileFormat.doc.extension].contains(
        extension)
        ? FontAwesomeIcons.fileWord
        : [FileFormat.xlsx.extension, FileFormat.xls.extension].contains(
        extension)
        ? FontAwesomeIcons.fileExcel
        : FontAwesomeIcons.fileLines;
  }


  static Color getDocIconColor(String path) {
    String extension = getFileExtension(path);
    return extension == FileFormat.pdf.extension
        ? Colors.red.shade300
        : [FileFormat.docx.extension, FileFormat.doc.extension].contains(
        extension)
        ? Colors.blueAccent
        : [FileFormat.xlsx.extension, FileFormat.xls.extension].contains(
        extension)
        ? Colors.green
        : Colors.black45;
  }



}
