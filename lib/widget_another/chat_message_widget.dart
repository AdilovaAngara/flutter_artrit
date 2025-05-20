import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/data_chat_info.dart';
import '../data/data_chat_messages.dart';
import '../file_methods.dart';
import '../my_functions.dart';
import '../widgets/file_view_widget.dart';
import '../widgets/future_builder_image.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;
  final String userId;
  final DataChatInfo? thisDataChatInfo;
  final Function(BuildContext, Message, GlobalKey) showContextMenu;
  final bool isSelectionMode; // Режим выбора
  final bool isSelected; // Выбрано ли сообщение
  final String acceptMsg;
  final Function(int) onToggleSelection; // Обработчик выбора

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.userId,
    required this.thisDataChatInfo,
    required this.showContextMenu,
    required this.isSelectionMode,
    required this.isSelected,
    required this.acceptMsg,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final messageKey = GlobalKey();

    return GestureDetector(
      onLongPressStart: isSelectionMode
          ? null
          : (details) {
        showContextMenu(context, message, messageKey);
      },
      onTap: isSelectionMode && message.artritFromId == userId &&  acceptMsg != message.message
          ? () => onToggleSelection(message.id)
          : null,
      child: Align(
        alignment: message.artritFromId == userId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            key: messageKey,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: message.artritFromId == userId ? const Color(0xFFDCF8C6) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: (isSelectionMode && isSelected)
                  ? [
                const BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(-5, -5)),
              ]
                  : null,
            ),
            child: IntrinsicWidth(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Чекбокс для сообщений текущего пользователя в режиме выбора
                  if (isSelectionMode && message.artritFromId == userId &&  acceptMsg != message.message)
                    AnimatedOpacity(
                      opacity: isSelectionMode ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          onToggleSelection(message.id);
                        },
                      ),
                    ),
                  Expanded(
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Документы
                        if (message.files.isNotEmpty) ...[
                          for (var file in message.files) ...[
                            if (FileMethods.isDocumentFile(path: file.url))
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      FileViewWidget.show(context,
                                        fileName: file.name,
                                        fileId: file.url,
                                        isLocal: false,
                                        isChatFiles: true,
                                        chatId: thisDataChatInfo!.result.id,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(FileMethods.getDocIcon(file.url),
                                          color: FileMethods.getDocIconColor(file.url),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            file.name,
                                            style: hyperTextStyle
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            /// Изображения
                            if (FileMethods.isImageFile(path: file.url))
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      FileViewWidget.show(context,
                                        fileName: file.name,
                                        fileId: file.url,
                                        isLocal: false,
                                        isChatFiles: true,
                                        chatId: thisDataChatInfo!.result.id,
                                      );
                                    },
                                    child: SizedBox(
                                      height: 150,
                                      child: FutureBuilderImage(
                                        imageId: file.url,
                                        isFullSize: false,
                                        isChatFiles: true,
                                        chatId: thisDataChatInfo!.result.id,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            /// Видео
                            if (FileMethods.isVideoFile(path: file.url))
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      FileViewWidget.show(
                                        context,
                                        fileName: file.name,
                                        fileId: file.url,
                                        isLocal: false,
                                        isChatFiles: true,
                                        chatId: thisDataChatInfo!.result.id,
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 160,
                                            height: 100,
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
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 2),
                                              child: Text(
                                                file.name,
                                                style: captionTextStyle.copyWith(
                                                    color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            if (!FileMethods.isVideoFile(path: file.url) && !FileMethods.isImageFile(path: file.url) && !FileMethods.isDocumentFile(path: file.url))
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      FileViewWidget.show(context,
                                        fileName: file.name,
                                        fileId: file.url,
                                        isLocal: false,
                                        isChatFiles: true,
                                        chatId: thisDataChatInfo!.result.id,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.file,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                              file.name,
                                              style: hyperTextStyle
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                          ],
                        ],
                        if (message.message.isNotEmpty)
                          Text(
                            textAlign: TextAlign.left,
                            message.message,
                            style: chatMsgTextStyle,
                          ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: double.infinity, // Растягиваем SizedBox на всю ширину
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              /// Дата/время отправки сообщения
                              Text(
                                dateTimeFormat(message.created) ?? '',
                                style: chatTimeStyle,
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(width: 10,),
                              const Spacer(),

                              /// Отметка о прочтении сообщения
                              if (message.artritFromId == userId)
                              Icon(
                                message.isRead ? FontAwesomeIcons.checkDouble : Icons.check,
                                size: 13,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



}