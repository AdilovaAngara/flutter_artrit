import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';
import 'chat_politic.dart';
import '../widgets/banners.dart';

class ChatOptionsMenu extends StatelessWidget {
  final String chatId;
  final int role;
  final bool isChatClose;
  final VoidCallback onShowPolicy;
  final VoidCallback onCloseChat;
  final VoidCallback onOpenChat;

  const ChatOptionsMenu({
    super.key,
    required this.chatId,
    required this.role,
    required this.isChatClose,
    required this.onShowPolicy,
    required this.onCloseChat,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showMenuChat(context),
      child: const Icon(Icons.more_vert, color: Colors.white),
    );
  }

  Future<void> showMenuChat(BuildContext context) async {
    if (chatId.isEmpty) {
      debugPrint('Ошибка: chatId пустой');
      showBottomBanner(
        context: context,
        message: 'Ошибка: данные чата недоступны',
        seconds: 1,
      );
      return;
    }

    final RenderBox? button = context.findRenderObject() as RenderBox?;
    if (button == null) {
      debugPrint('Ошибка: RenderBox не найден');
      return;
    }

    final position = button.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    final result = await showMenu<String>(
      context: context,
      color: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      position: RelativeRect.fromLTRB(
        position.dy,
        position.dy + 10,
        30.0,
        screenHeight,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'politic',
          child: Row(
            children: [
              const Icon(
                Icons.playlist_add_check_circle_outlined,
                size: 21,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text('Политика чата'),
            ],
          ),
        ),
        if (Roles.asDoctor.contains(role))...[
          if (!isChatClose)
            PopupMenuItem<String>(
              value: 'close',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: redBtnColor),
                  const SizedBox(width: 8),
                  const Text('Закрыть чат'),
                ],
              ),
            ),
          if (isChatClose)
            PopupMenuItem<String>(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.block, size: 20, color: redBtnColor),
                  const SizedBox(width: 8),
                  const Text('Открыть чат'),
                ],
              ),
            ),
        ],
      ],
    );

    if (result != null) {
      switch (result) {
        case 'politic':
          ChatPolitic.showInWindow(
            context: context,
            onConfirm: onShowPolicy,
            showAgreeBtn: false,
          );
          break;
        case 'close':
          onCloseChat();
          break;
        case 'open':
          onOpenChat();
          break;
      }
    }
  }

  /// Статический метод для вызова меню
  static void show({
    required BuildContext context,
    required String chatId,
    required int role,
    required bool isChatClose,
    required VoidCallback onShowPolicy,
    required VoidCallback onCloseChat,
    required VoidCallback onOpenChat,
  }) {
    final menu = ChatOptionsMenu(
      chatId: chatId,
      role: role,
      isChatClose: isChatClose,
      onShowPolicy: onShowPolicy,
      onCloseChat: onCloseChat,
      onOpenChat: onOpenChat,
    );
    menu.showMenuChat(context);
  }
}