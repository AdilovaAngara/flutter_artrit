import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../file_methods.dart';
import '../widgets/file_picker_widget.dart';
import '../widgets/file_view_widget.dart';

class ChatFilePreviewWidget extends StatefulWidget {
  final List<FileItems> fileItems;
  final bool isFileSendLoading;
  final ValueNotifier<bool> sendVisibilityNotifier;
  final String? controllerText;
  final void Function(int) onRemoveFile; // Callback для удаления

  const ChatFilePreviewWidget({
    super.key,
    required this.fileItems,
    required this.isFileSendLoading,
    required this.sendVisibilityNotifier,
    this.controllerText,
    required this.onRemoveFile,
  });

  @override
  _ChatFilePreviewWidgetState createState() => _ChatFilePreviewWidgetState();
}

class _ChatFilePreviewWidgetState extends State<ChatFilePreviewWidget> {
  late List<FileItems> _localFileItems;
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _localFileItems = List.from(widget.fileItems);
  }

  @override
  void didUpdateWidget(covariant ChatFilePreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('didUpdateWidget: widget.fileItems = ${widget.fileItems}');
    /// Проверяем длину или содержимое, а не ссылку
    if (widget.fileItems.length != _localFileItems.length ||
        widget.fileItems.any((item) => !_localFileItems.contains(item))) {
      setState(() {
        _localFileItems = List.from(widget.fileItems);
        debugPrint('Updated _localFileItems: $_localFileItems');
      });
    }
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  void _removeFile(int index) {
    setState(() {
      _localFileItems.removeAt(index);
      widget.onRemoveFile(index); // Уведомляем родителя
      widget.sendVisibilityNotifier.value =
          (widget.controllerText?.isNotEmpty ?? false) ||
              _localFileItems.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_localFileItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  debugPrint('Rendering file items: ${_localFileItems.length}');
                  return Row(
                    children: List.generate(
                      _localFileItems.length,
                      (index) {
                        return FileItemWidget(
                          key: ValueKey(_localFileItems[index].file.path),
                          fileItem: _localFileItems[index],
                          isFileSendLoading: widget.isFileSendLoading,
                          onRemove: () => _removeFile(index),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FileItemWidget extends StatelessWidget {
  final FileItems fileItem;
  final bool isFileSendLoading;
  final VoidCallback onRemove;

  const FileItemWidget({
    super.key,
    required this.fileItem,
    required this.isFileSendLoading,
    required this.onRemove,
  });




  @override
  Widget build(BuildContext context) {
    final file = File(fileItem.file.path);
    final fileExists = file.existsSync();

    return GestureDetector(
      onTap: () {
        FileViewWidget.show(
          context,
          fileName: fileItem.fileName,
          filePath: file.path,
          isLocal: true,
          isChatFiles: false,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Stack(
          children: [
            Builder(
              builder: (context) {
                if (!fileExists) {
                  debugPrint('File does not exist: ${fileItem.file.path}');
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                /// Изображения
                if (FileMethods.isImageFile(path: fileItem.file.path)) {
                  try {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        fileItem.file,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        // cacheWidth: 160,
                        // cacheHeight: 160,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Image.file error: $error');
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } catch (e) {
                    debugPrint('Image.file exception: $e');
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                }
                /// Видео
                else if (FileMethods.isVideoFile(path: fileItem.file.path)) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const Icon(
                          Icons.play_circle,
                          size: 40,
                          color: Colors.white,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withAlpha(100),
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              fileItem.fileName,
                              style: errorStyle.copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                /// Документы
                else {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Spacer(),
                        Center(
                          child: Icon(FileMethods.getDocIcon(fileItem.file.path),
                            size: 40,
                            color: FileMethods.getDocIconColor(fileItem.file.path),
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          fileItem.fileName,
                          style: errorStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  );
                }
              },
            ),
            if (!isFileSendLoading)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            if (fileItem.isSendSuccess != null && !fileItem.isSendSuccess!)
            Positioned(
              bottom: 20,
              right: 0,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.error_outlined,
                    size: 21,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
            if (fileItem.isSendSuccess != null && fileItem.isSendSuccess!)
              Positioned(
                bottom: 20,
                right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }






}
