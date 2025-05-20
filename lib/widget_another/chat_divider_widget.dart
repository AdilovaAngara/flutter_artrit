import 'package:artrit/my_functions.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class ChatDividerWidget extends StatelessWidget {
  final DateTime messageDate;

  const ChatDividerWidget({
    super.key,
    required this.messageDate,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 40,
      child: Center(child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Text(_formatDateForDivider(messageDate), style: chatDateStyle,),
          )),),
    );
  }

  String _formatDateForDivider(DateTime date) {
    final now = getMoscowDateTime();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Сегодня';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера';
    } else {
      return '${messageDate.day.toString().padLeft(2, '0')}.${messageDate.month.toString().padLeft(2, '0')}.${messageDate.year}';
    }
  }




}
