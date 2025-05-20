import 'package:flutter/material.dart';

class ChatFileUploadProgressWidget extends StatelessWidget {
  final double? progress;
  final int currentFileIndex;
  final int totalFiles;

  const ChatFileUploadProgressWidget({
    super.key,
    this.progress,
    required this.currentFileIndex,
    required this.totalFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
              minHeight: 25,
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              'Отправка файлов $currentFileIndex из $totalFiles',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}