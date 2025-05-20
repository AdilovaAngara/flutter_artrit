import 'package:flutter/material.dart';
import '../data/data_chat_messages.dart';

class ChatDividerNewMessageWidget extends StatelessWidget {
  final List<Message> messages;
  final int messageIndex;
  final bool isRead;
  final String userId;

  const ChatDividerNewMessageWidget({
    super.key,
    required this.messages,
    required this.messageIndex,
    required this.isRead,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    bool showDivider = _showDivider(messageIndex, isRead);

    return showDivider
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: Text(
          'Непрочитанные сообщения',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    )
        : SizedBox.shrink();
  }

  bool _showDivider(int messageIndex, bool isRead) {
    // Если текущее сообщение прочитано, разделитель не нужен
    if (isRead) {
      return false;
    }

    // Находим индекс первого непрочитанного сообщения
    int? firstUnreadIndex;
    for (int i = 0; i < messages.length; i++) {
      if (!messages[i].isRead && messages[i].artritFromId != userId) {
        firstUnreadIndex = i;
         debugPrint('Индекс первого непрочитанного сообщения $firstUnreadIndex');
         debugPrint('Текст первого непрочитанного сообщения ${messages[firstUnreadIndex].message}');
        break;
      }
    }

    // Показываем разделитель, только если текущий индекс — первый непрочитанный
    return firstUnreadIndex == messageIndex;
  }
}