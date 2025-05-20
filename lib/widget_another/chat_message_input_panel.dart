import 'package:flutter/material.dart';
import '../theme.dart';

/// Виджет панели ввода сообщения
class ChatMessageInputPanel extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onAddFile;
  final VoidCallback onShowTemplates;
  final VoidCallback onSend;
  final ValueNotifier<bool> sendVisibility;
  final VoidCallback scrollToBottom;

  const ChatMessageInputPanel({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onAddFile,
    required this.onShowTemplates,
    required this.onSend,
    required this.sendVisibility,
    required this.scrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /// Иконка добавления файлов и возврат информации о выбранных файлах
          IconButton(
            onPressed: () => onAddFile(),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add,
                size: 30, color: Colors.deepPurple),
          ),

          /// Иконка вызова шаблонных сообщений
          IconButton(
            onPressed: onShowTemplates,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.menu,
              color: Colors.deepPurple,
              size: 30,
            ),
          ),
          /// Поле ввода сообщения
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              maxLines: MediaQuery.of(context).orientation == Orientation.portrait ? 5 : 2,
              minLines: 1,
              autofocus: false,
              style: inputTextStyle,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Введите сообщение',
                hintStyle: subtitleTextStyle,
                filled: true,
                fillColor: Colors.white,
                counterText: "",
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              // Прокручиваем вниз только при явном нажатии на TextField
              onTap: scrollToBottom,
            ),
          ),
          /// Иконка отправки сообщения
          ValueListenableBuilder<bool>(
            valueListenable: sendVisibility,
            builder: (context, isVisible, child) {
              return isVisible
                  ? IconButton(
                onPressed: onSend,
                icon: const Icon(
                  Icons.send,
                  color: Colors.deepPurple,
                  size: 30,
                ),
              )
                  : const SizedBox.shrink();
            },
          ),

        ],
      ),
    );
  }
}

