import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart'; // Добавляем для открытия .doc файлов
import '../api/base_client.dart';
import '../file_methods.dart';
import '../pages/page_settings.dart';
import 'package:charset_converter/charset_converter.dart';

class FutureBuilderDocument extends StatefulWidget {
  final String fileId;
  final String fileExtension; // параметр для расширения
  final double? height;
  final double? width;
  final bool isChatFiles;
  final String? chatId;

  const FutureBuilderDocument({
    super.key,
    required this.fileId,
    required this.fileExtension,
    this.height = 300,
    this.width,
    required this.isChatFiles,
    this.chatId,
  });

  @override
  State<FutureBuilderDocument> createState() => _FutureBuilderDocumentState();
}

class _FutureBuilderDocumentState extends State<FutureBuilderDocument> {
  var baseClient = BaseClient();
  String? _filePath;
  Future<dynamic>? _fileFuture; // Используем dynamic для поддержки разных типов

  // Кеши для разных типов файлов
  final Map<String, Uint8List> _pdfCache = CacheManager.pdfCache;
  final Map<String, String> _textCache = CacheManager.txtCache;
  final Map<String, Uint8List> _docCache = CacheManager.docCache;

  @override
  void initState() {
    super.initState();
    _fileFuture = _loadFile();
  }

  /// Выбор метода загрузки в зависимости от расширения
  Future<dynamic> _loadFile() async {
    final extension = widget.fileExtension.toLowerCase();
    if (extension == FileFormat.pdf.extension) {
      return _loadPdf(extension);
    } else if (extension == FileFormat.txt.extension) {
      return _loadTextFile(extension);
    } else if (extension == FileFormat.docx.extension || extension == FileFormat.doc.extension) {
      return _loadDocFile(extension);
    } else {
      debugPrint("Неподдерживаемое расширение: $extension");
      return null;
    }
  }

  /// Загрузка PDF
  Future<String?> _loadPdf(String extension) async {
    final url = widget.isChatFiles
        ? '${baseClient.baseUrl}/api/chat/${widget.chatId}/image?filename=${widget.fileId}'
        : '${baseClient.baseUrl}/files/${widget.fileId}/download';

    if (_pdfCache.containsKey(widget.fileId)) {
      debugPrint("PDF найден в кеше: ${widget.fileId}");
      return _saveToFile(_pdfCache[widget.fileId]!, extension);
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${widget.fileId}$extension';
    final file = File(filePath);
    if (_filePath != null && await file.exists()) {
      debugPrint("Используем существующий PDF: $_filePath");
      return _filePath;
    }

    try {
      debugPrint("Загрузка PDF с $url");
      final pdfData = await baseClient.getFile(url);
      if (pdfData == null || pdfData.isEmpty) {
        debugPrint("PDF данные пусты для ${widget.fileId}");
        return null;
      }
      _pdfCache[widget.fileId] = pdfData;
      return await _saveToFile(pdfData, extension);
    } catch (e) {
      debugPrint("Ошибка загрузки PDF: $e");
      return null;
    }
  }

  /// Загрузка текстового файла
  Future<String?> _loadTextFile(String extension) async {
    final url = widget.isChatFiles
        ? '${baseClient.baseUrl}/api/chat/${widget.chatId}/image?filename=${widget.fileId}'
        : '${baseClient.baseUrl}/files/${widget.fileId}/download';

    if (_textCache.containsKey(widget.fileId)) {
      debugPrint("TXT найден в кеше: ${widget.fileId}");
      return _textCache[widget.fileId];
    }

    try {
      debugPrint("Загрузка TXT с $url");
      final fileData = await baseClient.getFile(url);
      if (fileData == null || fileData.isEmpty) {
        debugPrint("TXT данные пусты для ${widget.fileId}");
        return null;
      }

      // Пробуем декодировать как UTF-8
      try {
        String textData = utf8.decode(fileData);
        _textCache[widget.fileId] = textData;
        return textData;
      } catch (e) {
        debugPrint("Ошибка декодирования UTF-8: $e");
        // Пробуем Windows-1251
        try {
          String textData = await CharsetConverter.decode("windows-1251", fileData);
          _textCache[widget.fileId] = textData;
          return textData;
        } catch (e) {
          debugPrint("Ошибка декодирования Windows-1251: $e");
          return null;
        }
      }
    } catch (e) {
      debugPrint("Ошибка загрузки TXT: $e");
      return null;
    }
  }


  /// Загрузка DOC файла
  Future<String?> _loadDocFile(String extension) async {
    final url = widget.isChatFiles
        ? '${baseClient.baseUrl}/api/chat/${widget.chatId}/file?filename=${widget.fileId}'
        : '${baseClient.baseUrl}/files/${widget.fileId}/download';

    if (_docCache.containsKey(widget.fileId)) {
      debugPrint("DOC найден в кеше: ${widget.fileId}");
      return _saveToFile(_docCache[widget.fileId]!, extension);
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${widget.fileId}$extension';
    final file = File(filePath);
    if (await file.exists()) {
      debugPrint("Используем существующий DOC: $filePath");
      return filePath;
    }

    try {
      debugPrint("Загрузка DOC с $url");
      final docData = await baseClient.getFile(url);
      if (docData == null || docData.isEmpty) {
        debugPrint("DOC данные пусты для ${widget.fileId}");
        return null;
      }
      _docCache[widget.fileId] = docData;
      return await _saveToFile(docData, extension);
    } catch (e) {
      debugPrint("Ошибка загрузки DOC: $e");
      return null;
    }
  }

  /// Сохранение файла на устройство
  Future<String?> _saveToFile(Uint8List data, String extension) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${widget.fileId}$extension';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.writeAsBytes(data);
      debugPrint("$extension сохранён локально: $filePath");
    } else {
      debugPrint("$extension уже существует: $filePath");
    }

    setState(() {
      _filePath = filePath;
    });
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _fileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_pdfCache.containsKey(widget.fileId) &&
            !_textCache.containsKey(widget.fileId) &&
            !_docCache.containsKey(widget.fileId)) {
          debugPrint("Ожидание загрузки файла для ${widget.fileId}");
          return SizedBox(
            height: widget.height,
            width: widget.width,
            child: const Center(child: RefreshProgressIndicator()),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          debugPrint("Ошибка в FutureBuilder: ${snapshot.error}");
          return SizedBox(
            height: widget.height,
            width: widget.width,
            child: const Center(child: Icon(Icons.error, color: Colors.red, size: 50)),
          );
        } else {
          final extension = widget.fileExtension.toLowerCase();
          if (extension == FileFormat.pdf.extension) {
            debugPrint("PDF готов к отображению: ${snapshot.data}");
            return SizedBox(
              height: widget.height,
              width: widget.width,
              child: PDFView(
                filePath: snapshot.data as String,
                autoSpacing: true,
                pageFling: true,
                onRender: (pages) => debugPrint("PDF отрендерен, страниц: $pages"),
                onError: (error) => debugPrint("Ошибка отображения PDF: $error"),
                onPageError: (page, error) => debugPrint("Ошибка на странице $page: $error"),
              ),
            );
          } else if (extension == FileFormat.txt.extension) {
            debugPrint("TXT готов к отображению: ${snapshot.data}");
            return SizedBox(
              height: widget.height,
              width: widget.width,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(snapshot.data as String),
                ),
              ),
            );
          } else if (extension == FileFormat.docx.extension || extension == FileFormat.doc.extension) {
            debugPrint("DOC готов к отображению: ${snapshot.data}");
            return SizedBox(
              height: widget.height,
              width: widget.width,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => OpenFile.open(snapshot.data as String),
                  child: const Text("Открыть .doc файл"),
                ),
              ),
            );
          } else {
            return SizedBox(
              height: widget.height,
              width: widget.width,
              child: const Center(child: Text("Неподдерживаемый формат")),
            );
          }
        }
      },
    );
  }
}