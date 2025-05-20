import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../api/base_client.dart';
import '../pages/page_settings.dart';
import 'package:path/path.dart' as path;

class FutureBuilderImage extends StatefulWidget {
  final String imageId;
  final bool isFullSize;
  final bool isChatFiles;
  final String? chatId;

  const FutureBuilderImage({
    super.key,
    required this.imageId,
    required this.isFullSize,
    required this.isChatFiles,
    this.chatId,
  });

  @override
  _FutureBuilderImageState createState() => _FutureBuilderImageState();
}

class _FutureBuilderImageState extends State<FutureBuilderImage> {
  late Future<Uint8List?> _imageFuture;
  final baseClient = BaseClient();

  /// Раздельные кеши для миниатюр и полноразмерных изображений
  final Map<String, Uint8List> _thumbnailCache = CacheManager.thumbnailCache;
  final Map<String, Uint8List> _fullImageCache = CacheManager.fullImageCache;

  @override
  void initState() {
    super.initState();
    // Инициализация Future один раз
    _imageFuture = _fetchImage(_getUrl(widget.isFullSize), widget.imageId, widget.isFullSize);
  }

  Future<Uint8List?> _fetchImage(String url, String imageId, bool isFullSize) async {
    /// Проверка в нужном кеше
    if (isFullSize && _fullImageCache.containsKey(imageId)) {
      return _fullImageCache[imageId];
    } else if (!isFullSize && _thumbnailCache.containsKey(imageId)) {
      return _thumbnailCache[imageId];
    }

    try {
      final imageData = await baseClient.getFile(url);
      if (imageData != null) {
        /// Сохранение в соответствующий кеш
        if (isFullSize) {
          _fullImageCache[imageId] = imageData;
        } else {
          _thumbnailCache[imageId] = imageData;
        }
      }
      return imageData;
    } catch (e) {
      debugPrint("Ошибка загрузки изображения: $e");
      return null;
    }
  }

  String _getUrl(bool isFullSize) {
    if (widget.isChatFiles) {
      return isFullSize
          ? '${baseClient.baseUrl}/api/chat/${widget.chatId}/image?filename=${widget.imageId}'
          : '${baseClient.baseUrl}/api/chat/${widget.chatId}/image?filename=${addThumbnailToFileName(widget.imageId)}';
    } else {
      return isFullSize
          ? '${baseClient.baseUrl}/files/${widget.imageId}/download'
          : '${baseClient.baseUrl}/files/${widget.imageId}/download-thumb';
    }
  }

  /// Добавляем текст _thumbnail перед расширением файла
  String addThumbnailToFileName(String fileName) {
    /// Получаем имя файла без пути
    String baseName = path.basename(fileName);
    /// Разделяем на основную часть и расширение
    String nameWithoutExtension = path.withoutExtension(baseName);
    String extension = path.extension(baseName);
    /// Собираем новое имя
    return '${nameWithoutExtension}_thumbnail$extension';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture, // Используем сохраненный Future
      builder: (context, snapshot) {
        // Проверяем, есть ли данные в кэше, чтобы избежать отображения индикатора
        if (snapshot.connectionState == ConnectionState.waiting &&
            (widget.isFullSize
                ? _fullImageCache.containsKey(widget.imageId)
                : _thumbnailCache.containsKey(widget.imageId))) {
          final imageData = widget.isFullSize
              ? _fullImageCache[widget.imageId]
              : _thumbnailCache[widget.imageId];
          return _buildImage(imageData!);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: RefreshProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Icon(Icons.error, color: Colors.red, size: 50));
        } else {
          return _buildImage(snapshot.data!);
        }
      },
    );
  }

  Widget _buildImage(Uint8List imageData) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: InteractiveViewer(
        panEnabled: widget.isFullSize, // Разрешает перетаскивание изображения
        minScale: 1.0,
        maxScale: widget.isFullSize ? 10.0 : 1.0,
        child: Image.memory(
          imageData,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../api/base_client.dart';
// import 'package:path/path.dart' as path;
//
// class FutureBuilderImage extends StatelessWidget {
//   final String imageId;
//   final bool isFullSize;
//   final bool isChatFiles;
//   final String? chatId;
//
//   FutureBuilderImage({
//     super.key,
//     required this.imageId,
//     required this.isFullSize,
//     required this.isChatFiles,
//     this.chatId,
//   });
//
//   final baseClient = BaseClient();
//
//   String _getUrl(bool isFullSize) {
//     if (isChatFiles) {
//       return isFullSize
//           ? '${baseClient.baseUrl}/api/chat/$chatId/image?filename=$imageId'
//           : '${baseClient.baseUrl}/api/chat/$chatId/image?filename=${addThumbnailToFileName(imageId)}';
//     } else {
//       return isFullSize
//           ? '${baseClient.baseUrl}/files/$imageId/download'
//           : '${baseClient.baseUrl}/files/$imageId/download-thumb';
//     }
//   }
//
//   /// Добавляем текст _thumbnail перед расширением файла
//   String addThumbnailToFileName(String fileName) {
//     /// Получаем имя файла без пути
//     String baseName = path.basename(fileName);
//     /// Разделяем на основную часть и расширение
//     String nameWithoutExtension = path.withoutExtension(baseName);
//     String extension = path.extension(baseName);
//     /// Собираем новое имя
//     return '${nameWithoutExtension}_thumbnail$extension';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final url = _getUrl(isFullSize);
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(8),
//       child: InteractiveViewer(
//         panEnabled: isFullSize, // Разрешает перетаскивание изображения
//         minScale: 1.0,
//         maxScale: isFullSize ? 10.0 : 1.0,
//         child: CachedNetworkImage(
//           imageUrl: url,
//           fit: BoxFit.contain,
//           placeholder: (context, url) => const Center(child: RefreshProgressIndicator()),
//           errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.red, size: 50)),
//           fadeInDuration: const Duration(milliseconds: 200), // Длительность анимации
//           //httpHeaders: {'Cookie': cookie!}, // Если требуется
//         ),
//       ),
//     );
//   }
// }