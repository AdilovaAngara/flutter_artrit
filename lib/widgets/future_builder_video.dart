import 'package:artrit/widgets/viewer_video_file.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../api/base_client.dart';
import '../pages/page_settings.dart';


class FutureBuilderVideo extends StatefulWidget {
  final String videoId;
  final bool isChatFiles;
  final String? chatId;

  const FutureBuilderVideo({
    super.key,
    required this.videoId,
    required this.isChatFiles,
    this.chatId,
  });

  @override
  State<FutureBuilderVideo> createState() => _FutureBuilderVideoState();
}

class _FutureBuilderVideoState extends State<FutureBuilderVideo> {
  var baseClient = BaseClient();

  // Отдельный кеш для видеофайлов
  static final Map<String, Uint8List> _videoCache = CacheManager.fullImageCache;

  Future<Uint8List?> _fetchVideo(String url, String videoId) async {
    // Проверка в кеше
    if (_videoCache.containsKey(videoId)) {
      return _videoCache[videoId];
    }

    try {
      final videoData = await baseClient.getFile(url);
      if (videoData != null) {
        /// Сохранение в кеш
        _videoCache[videoId] = videoData;
        setState(() {});
      }
      return videoData;
    } catch (e) {
      debugPrint("Ошибка загрузки видео: $e");
      return null;
    }
  }

  String _getUrl() {
    if (widget.isChatFiles) {
      return '${baseClient.baseUrl}/api/chat/${widget.chatId}/image?filename=${widget.videoId}';
    } else {
      return '${baseClient.baseUrl}/files/${widget.videoId}/download';
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _getUrl();

    return FutureBuilder<Uint8List?>(
      future: _fetchVideo(url, widget.videoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_videoCache.containsKey(widget.videoId)) {
          return const Center(child: RefreshProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Icon(Icons.error, color: Colors.red, size: 50));
        } else {
          final videoData = snapshot.data ?? _videoCache[widget.videoId];
          return ViewerVideoFile(
            isLocal: false,
            videoData: videoData!,
          );
        }
      },
    );
  }
}


