import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ViewerVideoFile extends StatefulWidget {
  final String? filePath; // путь к локальному видео
  final Uint8List? videoData; // URL серверного видео
  final bool isLocal;

  const ViewerVideoFile({
    super.key,
    this.filePath,
    this.videoData,
    required this.isLocal,
  });

  @override
  State<ViewerVideoFile> createState() => ViewerVideoFileState();
}

class ViewerVideoFileState extends State<ViewerVideoFile> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    if (widget.isLocal && widget.filePath != null) {
      _controller = VideoPlayerController.file(File(widget.filePath!));
    } else if (!widget.isLocal && widget.videoData != null) {
      // Сохраняем видео во временный файл для воспроизведения
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4');
      await tempFile.writeAsBytes(widget.videoData!);
      _controller = VideoPlayerController.file(tempFile);
    } else {
      return;
    }

    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          GestureDetector(
            onTap: _togglePlayPause,
            child: AnimatedOpacity(
              opacity: _isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(70),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 64.0,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: const EdgeInsets.all(10.0),
              colors: VideoProgressColors(
                playedColor: Theme.of(context).colorScheme.primary,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.black12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
